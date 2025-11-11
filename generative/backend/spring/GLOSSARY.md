# Spring (Boot MVC) — Topic Glossary (Non-reactive)

Purpose
- Topic-first glossary for non-reactive Spring Boot MVC services. When this topic is active, these terms take precedence over the root glossary. Route to the Spring topic index and modular guides for details.

Routing (index and modules)
- Topic index — [README.md](./README.md)
- Overview & setup — [overview-setup.md](./overview-setup.md)
- Configuration & profiles — [configuration-profiles.md](./configuration-profiles.md)
- MVC REST & validation — [mvc-rest-validation.md](./mvc-rest-validation.md)
- Data JPA & transactions — [data-jpa-transactions.md](./data-jpa-transactions.md)
- Security (non-reactive) — [security-mvc.md](./security-mvc.md)
- Actuator & observability — [actuator-observability.md](./actuator-observability.md)
- OpenAPI (springdoc) — [openapi-springdoc.md](./openapi-springdoc.md)
- Testing (JUnit/MockMvc/Testcontainers) — [testing.md](./testing.md)
- Caching (Caffeine/Redis) — [caching.md](./caching.md)
- Scheduling & Async — [scheduling-async.md](./scheduling-async.md)
- Batch — [batch.md](./batch.md)
- Mail — [mail.md](./mail.md)
- Messaging (Kafka/RabbitMQ) — [messaging.md](./messaging.md)
- Database migrations (Flyway/Liquibase) — [database-migrations.md](./database-migrations.md)
- Packaging & deployment — [packaging-deployment.md](./packaging-deployment.md)

Precedence & scope
- Scope: Servlet-based, thread-per-request Spring Boot MVC (non-reactive). For reactive stacks, use Vert.x/Hibernate Reactive topics instead.
- Precedence: Terms here override the root glossary within the Spring topic. Where persistence is involved, consult Hibernate ORM topic for deeper ORM-specific terms.

Canonical terms

- Spring Boot MVC
  - Meaning: Non-reactive web stack built on Servlet containers (Tomcat/Jetty/Undertow).
  - LLM: use @RestController, Spring MVC annotations, and blocking JDBC (via Data JPA) within bounded thread pools.

- Controller (@RestController)
  - Meaning: Web adapter handling HTTP requests and responses.
  - LLM: keep lean; delegate to services; return representation DTOs; validate inputs; avoid business logic in controllers.

- Service (@Service)
  - Meaning: Application/service layer containing business logic and transactions.
  - LLM: annotate transactional methods at this layer; orchestrate repositories; enforce invariants.

- Repository (@Repository, Spring Data)
  - Meaning: Data access abstraction (typically Spring Data JPA repositories).
  - LLM: expose intent-revealing methods; avoid leaking entities across boundaries; prefer DTO projections for read models.

- DTO (Data Transfer Object)
  - Meaning: API/representation model distinct from persistence entities.
  - LLM: prefer Java records for DTOs; map via MapStruct; never expose entities directly.

- Validation (Bean Validation)
  - Meaning: Jakarta Bean Validation (jakarta.validation) annotations on DTOs and inputs.
  - LLM: use @Valid and constraints; surface errors as RFC 7807 Problem Details or consistent error envelope.

- Exception handler (@ControllerAdvice)
  - Meaning: Centralized exception-to-response mapping.
  - LLM: map domain/validation/security errors deterministically to HTTP status and problem codes.

- Configuration properties (@ConfigurationProperties)
  - Meaning: Typed configuration objects bound from application.yml/properties.
  - LLM: validate via @Validated; document via configuration metadata; expose read-only via Actuator configprops where safe.

- Profiles (spring.profiles.active)
  - Meaning: Environment selection for config and bean activation.
  - LLM: define dev/test/prod profiles; avoid logic branching by profile inside code; prefer configuration.

- Transaction (@Transactional)
  - Meaning: Declarative transaction demarcation for service methods.
  - LLM: default readOnly on queries; set propagation/isolation explicitly on write paths; minimize transaction scope.

- JPA Entity
  - Meaning: ORM-mapped domain object managed by Hibernate (JPA).
  - LLM: model aggregates with clear invariants; prefer optimistic locking via @Version; keep bidirectional relations minimal and well-owned.

- Repository interface (JpaRepository)
  - Meaning: Spring Data interface providing CRUD and query derivation.
  - LLM: declare intent, prefer @Query for tuned reads; use projection interfaces/DTOs for read models.

- Migration (Flyway/Liquibase)
  - Meaning: Versioned database schema changes applied on startup/deploy.
  - LLM: forward-only migrations; gate deployment on migration success; maintain checksum discipline.

- Actuator
  - Meaning: Operational endpoints for health, metrics, and management.
  - LLM: expose health, readiness, liveness; restrict management endpoints; never expose sensitive write ops publicly.

- Micrometer
  - Meaning: Metrics facade used by Spring Boot.
  - LLM: emit timers/counters; tag with correlation IDs; export per environment.

- OpenTelemetry (OTel)
  - Meaning: Tracing API/SDK; Spring Boot integration via Micrometer Tracing or OTel starter.
  - LLM: propagate context; instrument HTTP, JDBC, and messaging; sample appropriately per environment.

- springdoc-openapi
  - Meaning: OpenAPI 3 generation and UI for Spring MVC.
  - LLM: document DTO constraints, pagination, errors; restrict UI route; publish contract artifacts.

- MockMvc
  - Meaning: MVC testing utility for controller-layer tests without full server.
  - LLM: test routing, validation, serialization; avoid starting the full container when not required.

- Testcontainers
  - Meaning: Ephemeral infrastructure for integration tests (DB/brokers).
  - LLM: run real dependencies; apply migrations; isolate per test suite; keep tests deterministic.

- Cache abstraction (@EnableCaching)
  - Meaning: Unified caching API with providers (Caffeine/Redis).
  - LLM: define cache names/contracts centrally; set TTL/size; instrument hit/miss metrics.

- Scheduling (@Scheduled) and Async (@Async)
  - Meaning: Background execution and scheduled jobs.
  - LLM: externalize cron; ensure idempotency; bound executors; propagate MDC/tracing.

- Spring Batch
  - Meaning: Batch processing framework with job/step model and restartability.
  - LLM: design chunk size and transaction boundaries; isolate job repository; ensure re-runs are safe.

- Mail (JavaMail/Spring Mail)
  - Meaning: Email sending utilities.
  - LLM: externalize templates; test via mock SMTP; avoid blocking long IO in request threads.

- Messaging (Kafka/RabbitMQ)
  - Meaning: Event streaming/queueing integration.
  - LLM: standardize topics/queues; handle retries/DLQs; ensure exactly-once/at-least-once semantics as required.

Policy and interpretation
- Choose one stack per module: Spring Boot MVC (blocking) vs reactive (Vert.x). Do not mix in the same transaction path.
- Keep controllers thin, services transactional, repositories focused. Map entities↔DTOs with MapStruct. Apply JSpecify nullness and Java LTS posture per language rules.
- For identity/OIDC and secrets, route to enterprise topics: [Security & Auth](../../platform/security-auth/README.md) and [Secrets & Config](../../platform/secrets-config/README.md).

See also
- Java glossary — [generative/language/java/GLOSSARY.md](../../language/java/GLOSSARY.md)
- Hibernate glossary — [generative/backend/hibernate/GLOSSARY.md](../hibernate/GLOSSARY.md)
- Observability index — [generative/platform/observability/README.md](../../platform/observability/README.md)
- Database reference — [generative/data/database/README.md](../../data/database/README.md)