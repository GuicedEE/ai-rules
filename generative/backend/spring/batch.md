# Spring (Boot MVC) — Batch Processing (Spring Batch)

Scope
- Production-grade batch jobs for non-reactive Spring Boot MVC services using Spring Batch.
- Covers job/step design, chunk vs tasklet, restartability, idempotency, transaction boundaries, paging readers/writers, job repository posture, scheduling/partitioning, observability, and testing.

When to use
- Large ETL-style data movement/transformations
- Periodic reconciliation/calculations
- Backfills and reprocessing with checkpoints
- Export/import pipelines

Dependencies
- org.springframework.boot:spring-boot-starter-batch
- Database driver for JobRepository (PostgreSQL recommended)
- Optional: Testcontainers, Micrometer, Resilience4j

Enable Spring Batch
- Starter auto-configures JobRepository and job infrastructure.
- Initialize Spring Batch schema into your application database (or a dedicated ops database).

PostgreSQL schema initialization
- Option A: Let Spring Boot initialize the schema (dev only):
  - spring.batch.jdbc.initialize-schema=always
- Option B (recommended): Manage via migrations (Flyway/Liquibase) using the official Spring Batch DDL for your DB version.

Recommended posture
- Use a dedicated schema or database for Spring Batch tables when traffic isolation is desired.
- Prefer migrations-managed schema for repeatable, controlled environments.

Core abstractions
- Job: a composed unit of work with Steps.
- Step: a phase of a Job, either chunk-oriented or tasklet.
- ItemReader / ItemProcessor / ItemWriter: chunk-oriented components.
- JobRepository: stores executions, steps, and checkpoints for restartability.
- JobLauncher: starts jobs programmatically.
- JobParameters: identify job instances and drive idempotency.

Chunk-oriented processing
- Preferred for record-by-record processing with checkpointing.
- Reader → Processor → Writer in chunks (e.g., 100-1000) within a transaction per chunk.
- Restartable with last committed checkpoint.

Example chunk job (JPA paging reader, simple processor, JDBC writer)
```java
// com.example.batch.BatchConfig.java
package com.example.batch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.*;
import org.springframework.batch.item.database.*;
import org.springframework.batch.item.database.builder.*;
import org.springframework.batch.item.jdbc.JdbcBatchItemWriter;
import org.springframework.batch.item.jdbc.builder.JdbcBatchItemWriterBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

import javax.sql.DataSource;

@Configuration
class BatchConfig {

  @Bean
  Job sampleJob(JobRepository jobRepository, Step sampleStep) {
    return new JobBuilder("sampleJob", jobRepository)
        .start(sampleStep)
        .build();
  }

  @Bean
  Step sampleStep(JobRepository jobRepository,
                  PlatformTransactionManager txManager,
                  ItemReader<UserEntity> reader,
                  ItemProcessor<UserEntity, UserDto> processor,
                  ItemWriter<UserDto> writer) {
    return new StepBuilder("sampleStep", jobRepository)
        .<UserEntity, UserDto>chunk(500, txManager)
        .reader(reader)
        .processor(processor)
        .writer(writer)
        .build();
  }

  @Bean
  JpaPagingItemReader<UserEntity> reader(jakarta.persistence.EntityManagerFactory emf) {
    return new JpaPagingItemReaderBuilder<UserEntity>()
        .name("userReader")
        .entityManagerFactory(emf)
        .queryString("select u from UserEntity u where u.active = true order by u.id")
        .pageSize(500)
        .build();
  }

  @Bean
  ItemProcessor<UserEntity, UserDto> processor() {
    return user -> new UserDto(user.getId(), user.getEmail(), user.getName());
  }

  @Bean
  JdbcBatchItemWriter<UserDto> writer(DataSource ds) {
    return new JdbcBatchItemWriterBuilder<UserDto>()
        .dataSource(ds)
        .sql("insert into active_users (id,email,name) values (:id,:email,:name) " +
             "on conflict (id) do update set email = excluded.email, name = excluded.name")
        .beanMapped()
        .build();
  }

  public record UserDto(Long id, String email, String name) {}
}
```

Tasklet vs chunk
- Use Tasklet for one-off actions (filesystem ops, single SQL), or control flows not fitting chunk semantics.
- Prefer chunk for scalable, restartable item processing.

Job parameters and idempotency
- Pass JobParameters to uniquely identify logical runs (e.g., date, version, tenant).
- Do not include timestamps solely to make parameters unique (hurts restartability). Use logical keys (e.g., businessDate=2025-11-01).
- For upserts, ensure downstream writes are idempotent (unique constraints, upsert semantics).

Launching jobs
- Programmatic with JobLauncher
- Command-line (Spring Boot run) with parameters: --job.name=sampleJob businessDate=2025-11-01
- Scheduled via @Scheduled (see scheduling-async.md) or via orchestration (e.g., CI/k8s CronJob)

Programmatic launch example
```java
// com.example.batch.JobLaunchController.java
package com.example.batch;

import org.springframework.batch.core.*;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/internal/batch")
class JobLaunchController {
  private final JobLauncher launcher;
  private final Job sampleJob;

  JobLaunchController(JobLauncher launcher, Job sampleJob) {
    this.launcher = launcher;
    this.sampleJob = sampleJob;
  }

  @PostMapping("/sample")
  ResponseEntity<String> run(@RequestParam String businessDate) throws Exception {
    var params = new JobParametersBuilder()
        .addString("businessDate", businessDate)
        .addString("runVersion", "v1")
        .toJobParameters();
    JobExecution exec = launcher.run(sampleJob, params);
    return ResponseEntity.accepted().body(exec.getStatus().toString());
  }
}
```

Partitioning and parallelism
- PartitionStep: split input by ranges (e.g., id ranges) and run slave steps in parallel.
- Multi-threaded steps: set taskExecutor on step; ensure ItemReader and Writer are thread-safe (often not for JPA readers).
- Prefer stateless readers/writers for parallelism. For JPA, partition by ranges and use separate EntityManagers per thread.

Transactions and performance
- Chunk-size drives transaction scope; larger chunks reduce overhead but increase rollback volume.
- Use JDBC batch writing (configure writers appropriately).
- Avoid excessive flushes in JPA; prefer JDBC writers for heavy writes.
- Monitor lock contention; consider lower isolation where safe.

I/O boundaries and retries
- Wrap external calls with resilience (resilience4j) and circuit breaking. Prefer retry with backoff for transient failures.
- Keep slow I/O out of the same transaction where possible; stage results then commit.

JobRepository and cleanup
- Periodically purge old JobExecution/StepExecution data to keep repo small; provide a maintenance task.
- Protect JobRepository from long-running TX holding locks in shared DBs.

Observability and metrics
- Spring Batch exposes metrics via Micrometer (if on classpath). Validate:
  - spring.batch.job: active, completed, failed
  - step execution timers and item counts
- Add domain metrics around processed/failed counts, lag, and throughput.
- Correlate runs with parameters (businessDate, tenant) via tags.

Logging and correlation
- Include Job/Step names and execution IDs in logs. Set MDC keys in listeners.
- Prefer JSON logs with stable fields; see actuator-observability.md for Logback JSON example.

Listeners and notifications
- Register JobExecutionListener/StepExecutionListener to collect run stats and send notifications on completion/failure (email/Slack).
- Avoid sending from inside transactions; notify after commit.

Testing
- @SpringBatchTest for utilities (JobLauncherTestUtils)
- Unit-test ItemProcessor logic directly.
- Integration-test full jobs with Testcontainers; seed DB and assert outputs.

Example test
```java
// com.example.batch.SampleJobTest.java
package com.example.batch;

import org.junit.jupiter.api.Test;
import org.springframework.batch.core.*;
import org.springframework.batch.test.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@org.springframework.batch.test.EnableBatchTesting
class SampleJobTest {

  @Autowired JobLauncherTestUtils utils;

  @Test
  void jobCompletes() throws Exception {
    JobParameters params = new JobParametersBuilder()
        .addString("businessDate", "2025-11-01")
        .addString("runVersion", "v1")
        .toJobParameters();
    JobExecution exec = utils.launchJob(params);
    assertThat(exec.getStatus()).isEqualTo(BatchStatus.COMPLETED);
  }
}
```

Operational guidance
- Use k8s CronJob or scheduler to trigger; ensure single-writer semantics via leader-election/locks when needed (see scheduling-async.md).
- Backfills: prefer parametrized reruns over code forks.
- Throttling: bound concurrency and IO; apply rate limits to downstream services.

Common pitfalls
- Using current timestamp as the only parameter → breaks restartability.
- Non-idempotent writers causing duplicates on retry.
- Very large chunk sizes leading to long lock holds and big rollbacks.
- JPA readers with multi-threaded steps without safe partitioning.

Checklist
- Batch schema managed by migrations; JobRepository healthy.
- Jobs restartable; parameters encode logical runs.
- Chunk sizes tuned; writers batched; transactions bounded.
- Metrics and logs include job/step/run identifiers.
- Tests cover processors and end-to-end happy path + failure cases.

See also
- Scheduling & Async — rules/generative/backend/spring/scheduling-async.md
- Data JPA & Transactions — rules/generative/backend/spring/data-jpa-transactions.md
- Observability — rules/generative/platform/observability/README.md
- Database reference — rules/generative/data/database/README.md