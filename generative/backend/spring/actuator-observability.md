# Spring (Boot MVC) — Actuator and Observability

Scope
- Operational readiness for non-reactive Spring Boot MVC services using Actuator, Micrometer metrics, and OpenTelemetry tracing.
- Covers endpoint exposure, security posture, health/readiness/liveness, metrics and tracing configuration, logging and correlation, graceful shutdown, and validation in tests.
- Aligns with platform guidance: ../../platform/observability/README.md and secrets/config: ../../platform/secrets-config/README.md

Dependencies
- spring-boot-starter-actuator
- Micrometer registry exporters per environment (e.g., micrometer-registry-prometheus)
- Optional tracing via Micrometer Tracing or OTel SDK:
  - micrometer-tracing-bridge-otel
  - opentelemetry-exporter-otlp, opentelemetry-sdk (if not using Spring Boot OTel starters)

Endpoint exposure policy
- Default: expose minimal endpoints publicly (health, ready, live). Keep admin/diagnostic endpoints restricted.
- Use per-environment configuration to tighten exposure in production.

application.yml (baseline)
```yaml
management:
  endpoints:
    web:
      exposure:
        include: "health,info,metrics,prometheus"
  endpoint:
    health:
      probes:
        enabled: true
  server:
    port: 8081 # optional separate port for management traffic
```

application-prod.yml (restricted)
```yaml
management:
  endpoints:
    web:
      exposure:
        include: "health,metrics,prometheus"
  endpoint:
    health:
      show-details: when_authorized
  server:
    port: 8081
```

Security posture
- Permit /actuator/health, /actuator/ready, /actuator/live to unauthenticated callers for k8s/infra probes.
- Restrict all other actuator endpoints to an ops role or private network.
- Do not expose /actuator/env, /actuator/configprops publicly; consider disabling them in production.
- Wire SecurityFilterChain rules accordingly. See: ./security-mvc.md

Health, readiness, and liveness
- Health: basic service health; include DB, messaging brokers, downstream dependencies.
- Liveness: app is not in a broken state (e.g., deadlocked).
- Readiness: app can serve traffic (DB up, migrations finished, caches warm if required).

DB health (auto)
- Spring Boot auto-configures DataSourceHealthIndicator for JDBC. Ensure it is included and fast.

Custom HealthIndicator example (external dependency)
```java
// com.example.ops.ExternalApiHealth.java
package com.example.ops;

import org.springframework.boot.actuate.health.*;
import org.springframework.stereotype.Component;

@Component
public class ExternalApiHealth implements HealthIndicator {
  @Override
  public Health health() {
    // Replace with a fast, cached check. Avoid slow network calls on every probe.
    boolean reachable = true; // result from a cached ping scheduler
    return reachable ? Health.up().withDetail("ext", "ok").build()
                     : Health.down().withDetail("ext", "unreachable").build();
  }
}
```

Readiness state gate
- Delay ready signal until critical startup tasks complete (e.g., migrations successful, caches seeded).
- Emit ApplicationReadiness events or maintain a readiness flag guarded by listeners.

Metrics (Micrometer)
- Export HTTP server metrics (latency, status codes), JVM, system, thread, GC, and DB pool metrics (Hikari).
- Tag metrics with service name, version, environment, and correlation where appropriate.

Prometheus (example)
```yaml
management:
  metrics:
    tags:
      application: ${spring.application.name}
  endpoints:
    web:
      exposure:
        include: "health,metrics,prometheus"
```

Custom meters
- Create counters/timers for domain events and critical operations.

Timer example
```java
// com.example.ops.MetricsConfig.java
package com.example.ops;

import io.micrometer.core.instrument.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class MetricsConfig {

  @Bean
  MeterRegistryCustomizer<MeterRegistry> commonTags() {
    return registry -> registry.config().commonTags(
        "application", System.getProperty("spring.application.name", "app"),
        "env", System.getenv().getOrDefault("ENV", "dev")
    );
  }

  static Timer timer(MeterRegistry registry, String name, String... tags) {
    return Timer.builder(name).tags(tags).register(registry);
  }
}
```

Usage example
```java
// com.example.domain.PaymentService.java
package com.example.domain;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.stereotype.Service;

@Service
public class PaymentService {
  private final MeterRegistry registry;

  public PaymentService(MeterRegistry registry) {
    this.registry = registry;
  }

  public void process(String id) {
    Timer.Sample sample = Timer.start(registry);
    try {
      // ... do work ...
    } finally {
      sample.stop(Timer.builder("payments.process")
          .tag("result", "ok")
          .register(registry));
    }
  }
}
```

HTTP metrics and path normalization
- Enable server request metrics; normalize templated paths (/api/users/{id}) to reduce label cardinality.
- Avoid tagging with unbounded values (no user IDs in tags).

Tracing (OpenTelemetry)
- Prefer Micrometer Tracing bridge for Spring Boot integration with OTel.
- Configure W3C traceparent propagation; ensure MDC includes trace/span IDs for logs.

Tracing configuration (properties)
```yaml
management:
  tracing:
    sampling:
      probability: 0.1 # tune per environment (higher in staging, lower in prod)
```

OTLP exporter (example)
```yaml
otel:
  exporter:
    otlp:
      endpoint: https://otel.example.com:4317
```

Log correlation and JSON logs
- Emit structured logs (JSON) with trace/span IDs and MDC keys (requestId, userId when available).
- Include a servlet filter to set correlation IDs when missing.

Correlation filter
```java
// com.example.web.CorrelationFilter.java
package com.example.web;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.UUID;

@Component
public class CorrelationFilter implements Filter {

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    try {
      HttpServletRequest req = (HttpServletRequest) request;
      String cid = req.getHeader("X-Correlation-Id");
      if (cid == null || cid.isBlank()) {
        cid = UUID.randomUUID().toString();
      }
      MDC.put("correlationId", cid);
      chain.doFilter(request, response);
    } finally {
      MDC.remove("correlationId");
    }
  }
}
```

Logback JSON sample (snippet)
```xml
<!-- src/main/resources/logback-spring.xml -->
<configuration>
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder class="net.logstash.logback.encoder.LogstashEncoder">
      <fieldNames>
        <timestamp>time</timestamp>
        <level>level</level>
        <logger>logger</logger>
        <thread>thread</thread>
        <message>message</message>
      </fieldNames>
      <customFields>{"service":"${spring.application.name:-app}"}</customFields>
      <mdcFields>
        <mdcFieldName>correlationId</mdcFieldName>
        <mdcFieldName>traceId</mdcFieldName>
        <mdcFieldName>spanId</mdcFieldName>
      </mdcFields>
    </encoder>
  </appender>
  <root level="INFO">
    <appender-ref ref="STDOUT"/>
  </root>
</configuration>
```

HikariCP metrics
- Auto-bound if Micrometer is on the classpath.
- Alert on high utilization, connection timeout rates, and long borrow durations.

Shutdown and readiness drain
- Enable graceful shutdown to stop accepting new requests and wait for in-flight completion.
```yaml
server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s
```
- Consider pausing traffic (readiness probe fail) before shutdown during deployments.

Validation in tests
- Write a smoke test that hits /actuator/health and verifies UP.
- For metrics presence, assert common meters are registered (e.g., jvm.threads.live, http.server.requests).
- For tracing, verify trace headers flow in integration tests with MockMvc or RestTemplate.

Example health smoke test
```java
// com.example.ops.HealthSmokeTest.java
package com.example.ops;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.web.client.RestTemplate;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
class HealthSmokeTest {

  @Test
  void healthIsUp() {
    var rt = new RestTemplate();
    var res = rt.getForEntity("http://localhost:8081/actuator/health", String.class);
    assertThat(res.getStatusCode().is2xxSuccessful()).isTrue();
    assertThat(res.getBody()).contains("\"status\":\"UP\"");
  }
}
```

Checklist
- Actuator endpoints exposed per environment; health/ready/live public, admin endpoints restricted.
- Health indicators include DB and critical dependencies; checks are fast and cached when needed.
- Metrics exported and tagged consistently; avoid unbounded label cardinality.
- Tracing configured with sampling and propagation; logs include correlation and trace IDs.
- Graceful shutdown enabled; readiness gates traffic during deploys.
- Smoke tests validate probes and basic metrics.

See also
- Security (non-reactive) — ./security-mvc.md
- Observability platform — ../../platform/observability/README.md
- Secrets & Config — ../../platform/secrets-config/README.md
- Spring topic index — ./README.md