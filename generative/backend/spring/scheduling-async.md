# Spring (Boot MVC) — Scheduling and Async

Scope
- Non-reactive scheduling and background execution for Spring Boot MVC using @EnableScheduling, @Scheduled, and @Async.
- Covers cron/rate scheduling, idempotency, retries/backoff, thread pool sizing (platform vs virtual threads), MDC/tracing propagation, leader election/distributed locks, metrics, and graceful shutdown.
- Aligns with observability and security posture:
  - Observability — ../../platform/observability/README.md
  - Security & Auth — ../../platform/security-auth/README.md

Guiding principles
- Idempotent jobs: every scheduled action should be safe to re-run or detect duplicates.
- Bounded resources: tune executors; no unbounded growth.
- Visibility: metrics, logs, and tracing around job lifecycle.
- Deterministic timing: avoid drift; document cron in one place; externalize via configuration.
- Single-writer in distributed deployments: use leader election or distributed locks (e.g., ShedLock).

Enable scheduling and async
```java
// com.example.app.SchedulingConfig.java
package com.example.app;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.EnableAsync;

@Configuration
@EnableScheduling
@EnableAsync
class SchedulingConfig {}
```

Threading model and executors
- Default task executors are limited; define explicit executors for scheduling and async workloads.

Platform threads (default)
```java
// com.example.app.ExecutorsConfig.java
package com.example.app;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

@Configuration
class ExecutorsConfig {

  @Bean
  ThreadPoolTaskScheduler scheduler() {
    var s = new ThreadPoolTaskScheduler();
    s.setPoolSize(4);           // tune per workload and cores
    s.setThreadNamePrefix("sched-");
    s.setAwaitTerminationSeconds(30);
    s.setWaitForTasksToCompleteOnShutdown(true);
    return s;
  }

  @Bean(name = "asyncExecutor")
  ThreadPoolTaskExecutor asyncExecutor() {
    var ex = new ThreadPoolTaskExecutor();
    ex.setCorePoolSize(8);
    ex.setMaxPoolSize(32);
    ex.setQueueCapacity(1000);
    ex.setThreadNamePrefix("async-");
    ex.initialize();
    return ex;
  }
}
```

Virtual threads (Java 21+) — optional
- For IO-heavy tasks, consider virtual threads to simplify blocking code at scale. Do not mix with event-loop frameworks in the same module.
```java
// com.example.app.VirtualExecutorsConfig.java
package com.example.app;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.TaskScheduler;
import org.springframework.scheduling.concurrent.ConcurrentTaskScheduler;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Configuration
class VirtualExecutorsConfig {

  @Bean(destroyMethod = "shutdown")
  ExecutorService asyncExecutor() {
    return Executors.newVirtualThreadPerTaskExecutor();
  }

  @Bean
  TaskScheduler scheduler() {
    // Scheduler wheel still uses platform threads; keep small pool
    return new ConcurrentTaskScheduler(Executors.newScheduledThreadPool(2));
  }
}
```

Scheduling patterns
- Fixed rate: @Scheduled(fixedRateString = "30000")
- Fixed delay: @Scheduled(fixedDelayString = "30000")
- Cron: @Scheduled(cron = "${jobs.cleanup.cron:0 0 * * * *}", zone = "UTC")

Example cron job with idempotency and metrics
```java
// com.example.jobs.CleanupJob.java
package com.example.jobs;

import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.MDC;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
class CleanupJob {
  private final MeterRegistry metrics;
  private final CleanupService cleanup;

  CleanupJob(MeterRegistry metrics, CleanupService cleanup) {
    this.metrics = metrics;
    this.cleanup = cleanup;
  }

  @Scheduled(cron = "${jobs.cleanup.cron:0 0 * * * *}", zone = "UTC")
  void run() {
    String runId = UUID.randomUUID().toString();
    MDC.put("job", "cleanup");
    MDC.put("runId", runId);
    var sample = io.micrometer.core.instrument.Timer.start(metrics);
    String result = "ok";
    try {
      cleanup.execute(runId); // idempotent: runId guards repeat work
    } catch (Exception e) {
      result = "error";
      throw e;
    } finally {
      sample.stop(io.micrometer.core.instrument.Timer.builder("jobs.cleanup")
          .tag("result", result)
          .register(metrics));
      MDC.remove("runId");
      MDC.remove("job");
    }
  }
}
```

Async execution
- Use @Async on methods returning void, CompletableFuture, or similar; inject the right executor.
```java
// com.example.service.MailService.java
package com.example.service;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class MailService {

  @Async("asyncExecutor")
  public void send(String to, String subject, String body) {
    // blocking SMTP call; execute off-request thread
  }
}
```

Retries and backoff
- Prefer resilience4j or Spring Retry for transient failures with bounded retries.
```java
// com.example.support.RetryingService.java
package com.example.support;

import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.stereotype.Service;

@Service
class RetryingService {

  @Retry(name = "ext-call", fallbackMethod = "fallback")
  String call() {
    // remote call
    return "ok";
  }

  String fallback(Exception ex) {
    return "fallback";
  }
}
```

Distributed scheduling and locks
- In multi-instance deployments, avoid duplicate execution:
  - Leader election (k8s lease, Spring Cloud Cluster — if available)
  - Distributed lock libraries (e.g., ShedLock) with DB/Redis backing
- ShedLock example (conceptual; add dependency):
```java
// com.example.jobs.LockedJob.java
package com.example.jobs;

import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
class LockedJob {

  @Scheduled(cron = "0 */5 * * * *")
  @SchedulerLock(name = "lockedJob", lockAtLeastFor = "PT30S", lockAtMostFor = "PT2M")
  void run() {
    // executed by one node at a time
  }
}
```

Graceful shutdown
- Enable graceful shutdown to finish in-flight tasks:
```yaml
server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s
```
- Configure scheduler to wait for tasks to complete on shutdown (see ThreadPoolTaskScheduler above).

MDC and tracing propagation
- Propagate MDC keys (correlationId, trace/span) in async tasks:
  - For platform threads: wrap Runnable/Callable to copy MDC from caller, or use Spring’s TaskDecorator.
```java
// com.example.app.MdcTaskDecorator.java
package com.example.app;

import org.slf4j.MDC;
import org.springframework.core.task.TaskDecorator;

import java.util.Map;

class MdcTaskDecorator implements TaskDecorator {
  @Override
  public Runnable decorate(Runnable runnable) {
    Map<String, String> contextMap = MDC.getCopyOfContextMap();
    return () -> {
      Map<String, String> previous = MDC.getCopyOfContextMap();
      if (contextMap != null) MDC.setContextMap(contextMap);
      try { runnable.run(); }
      finally {
        if (previous != null) MDC.setContextMap(previous); else MDC.clear();
      }
    };
  }
}
```
```java
// in ExecutorsConfig.asyncExecutor()
ex.setTaskDecorator(new MdcTaskDecorator());
```

Configuration anchors
- Externalize cron and pool sizes:
```yaml
jobs:
  cleanup:
    cron: "0 0 * * * *" # hourly
async:
  core-pool-size: 8
  max-pool-size: 32
  queue-capacity: 1000
```

Metrics and alerts
- Emit timers and counters: jobs.<name> with result tags.
- Alert on consecutive failures, long runtimes, and queue saturation.
- Export JVM and thread metrics to detect executor exhaustion.

Testing
- For @Scheduled methods, extract logic into services and test directly.
- For timing, inject Clock or now() supplier; avoid Thread.sleep in tests.
- For @Async, use AsyncUncaughtExceptionHandler to capture errors in tests or override executor with synchronous executor during tests.

Common pitfalls
- Non-idempotent jobs causing double-processing in distributed deployments.
- Unbounded executors leading to resource exhaustion.
- Hard-coded cron without documentation or externalization.
- Long-running IO inside the same executor as short periodic jobs.

Checklist
- Cron expressions externalized and documented.
- Jobs idempotent; locks/leader election in multi-node envs.
- Executors sized and bounded; MDC/tracing propagated.
- Metrics and alerts in place; failures visible.
- Graceful shutdown waits for tasks to complete.

See also
- Topic index — ./README.md
- Observability — ../../platform/observability/README.md
- Mail — ./mail.md
- Messaging — ./messaging.md