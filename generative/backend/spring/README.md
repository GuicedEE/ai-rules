# Spring (Boot MVC) — Topic Index and Rules

Non-reactive Spring backend guidance for HTTP APIs and services built with Spring Boot MVC. This topic consolidates setup, configuration, REST design, data access, security, observability, and common addons.

Contents
- Overview and setup — see "Overview and setup"
- Configuration and profiles — see "Configuration and profiles"
- MVC REST controllers and validation — see "MVC REST controllers and validation"
- Data JPA and transactions — see "Data JPA and transactions"
- Security (non-reactive) — see "Security (non-reactive)"
- Actuator and observability — see "Actuator and observability"
- Addons: OpenAPI (springdoc), Testing (JUnit/MockMvc/Testcontainers), Caching, Scheduling & Async, Batch, Mail, Messaging, Database migrations, Packaging
- See also and cross-links

Version alignment and scope
- Prefer Java LTS 21 or 25 for new services. See [generative/language/java/java-21.rules.md](../../language/java/java-21.rules.md) and [generative/language/java/java-25.rules.md](../../language/java/java-25.rules.md).
- Scope: non-reactive MVC stack (Servlet, embedded Tomcat/Jetty). For reactive see Vert.x 5 topic: [generative/backend/vertx/README.md](../vertx/README.md).

Overview and setup
- Build tool: Maven or Gradle. Enforce dependency convergence and BOM usage.
- Starters commonly used:
  - web (MVC, embedded server)
  - validation (Bean Validation)
  - data-jpa (Hibernate ORM)
  - security (Spring Security)
  - actuator (health/metrics)
  - configuration processor (metadata for IDEs)
- Group logical modules (optional multi-module): api (contracts), app (web), domain (models + services), data (repositories), bootstrap (executor).
- REST default port and context path configured via application properties.

Configuration and profiles
- Use hierarchical application configuration files with environment-specific overrides (e.g., application-dev.yml, application-prod.yml).
- Use typed configuration properties classes bound to a prefix; validate inputs; surface in actuator/configprops.
- Store secrets in environment variables or secret stores; never commit secrets.
- Maintain a single source of truth for external endpoints, timeouts, and feature flags.

MVC REST controllers and validation
- Design resource-oriented endpoints with consistent naming and HTTP semantics.
- Validate input models using Bean Validation; return problem details payloads for violations.
- Centralize exception translation to consistent error responses; map domain errors to HTTP status codes deterministically.
- Support pagination, sorting, and filtering using explicit parameters and consistent conventions.
- Enforce content negotiation: JSON by default; disable XML unless required.

Data JPA and transactions
- Use Spring Data JPA repositories for aggregate persistence; avoid leaking ORM entities outside service boundary.
- Prefer optimistic locking for concurrency; model version field explicitly.
- Use explicit transactional boundaries at service layer; default readOnly for read paths; narrow transaction scope.
- Choose database migrations tool (Flyway or Liquibase) as part of deployment workflow.

Security (non-reactive)
- Apply defense-in-depth: authentication, authorization, CSRF for browser flows, rate limiting at edge.
- Adopt JWT/OIDC where appropriate; integrate with enterprise identity provider via Spring Security.
- Define authorization rules by route and method; least privilege defaults.
- Store password hashes using strong algorithms only where local auth is required.
- Cross-link enterprise security guidance: [generative/platform/security-auth/README.md](../../platform/security-auth/README.md) and [generative/platform/secrets-config/security.md](../../platform/secrets-config/security.md).

Actuator and observability
- Expose health, readiness, and liveness endpoints with sensible checks (DB, message brokers, external deps).
- Emit metrics via Micrometer; configure OpenTelemetry tracing exporters per environment.
- Redact sensitive values; whitelist actuator endpoints by environment; never expose write operations publicly.
- Cross-link observability guidance: [generative/platform/observability/README.md](../../platform/observability/README.md).

Addons — OpenAPI (springdoc)
- Use springdoc-openapi to generate OpenAPI 3 docs and serve interactive UI under a restricted path.
- Keep DTOs stable; annotate constraints; document pagination and error formats; publish artifacts to consumers.

Addons — Testing (JUnit 5, MockMvc, Testcontainers)
- Unit tests: fast, isolated domain logic.
- Web slice tests: verify controller routing, validation, and serialization without starting full container.
- Integration tests: spin up real dependencies (DB, brokers) via Testcontainers; apply migrations at startup.
- Contract tests where applicable; seed golden samples for error responses.

Addons — Caching
- Local caching for hot lookups; distributed cache for cross-instance sharing.
- Choose an implementation appropriate to workload; configure TTLs; instrument cache metrics.

Addons — Scheduling and Async
- Schedule background jobs; externalize cron expressions; ensure idempotency.
- Use async execution prudently; bound thread pools; propagate MDC for tracing.

Addons — Batch
- Use chunk-oriented processing with restartability; isolate job repository; design idempotent steps.

Addons — Mail
- Externalize templates; test with in-memory SMTP or mock providers; avoid blocking calls on request thread.

Addons — Messaging (Kafka/RabbitMQ)
- Standardize topic/queue naming; schema governance; consumer groups; backpressure and retries with DLQs.

Addons — Database migrations
- Author forward-only migrations; track checksum drift; gate deploy on migration success.

Packaging and deployment
- Build layered container images using buildpacks or optimized Dockerfiles; separate runtime from build-time dependencies.
- Externalize config via env and secrets; prefer immutable images; enable graceful shutdown.

Checklists
- Security: authentication configured, authorization rules in place, secrets externalized.
- Reliability: health/readiness checks, timeouts and retries configured, thread pools bounded.
- Observability: metrics, tracing, structured logs, correlation IDs.
- Data: migrations automated, transaction boundaries defined, locking strategy documented.
- API: consistent error model, validation coverage, pagination contract.

See also
- Backend category index — [generative/backend/README.md](../README.md)
- Hibernate ORM (relational persistence) — [generative/backend/hibernate/hibernate-orm-overview.md](../hibernate/hibernate-orm-overview.md)
- Database reference — [generative/data/database/README.md](../../data/database/README.md)