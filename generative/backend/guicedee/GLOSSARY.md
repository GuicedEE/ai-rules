# GuicedEE — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms for the GuicedEE ecosystem. When this topic is referenced, these terms take precedence over the root glossary. Keep entries concise and route to rules for detail.

Canonical terms
- GuicedEE — A modular, JPMS-first ecosystem that standardizes DI, lifecycle, and SPI-driven extension across JVM services. See: ./README.md
- GuicedInjection — Core DI/lifecycle framework in GuicedEE providing SPI contracts and startup/shutdown orchestration. See: ./functions/guiced-injection-rules.md
- SPI (Service Provider Interface) — Extension mechanism used across GuicedEE. Key SPIs include:
  - IGuiceModule, IGuicePreStartup, IGuicePostStartup, IGuicePreDestroy, plus module-specific SPIs (e.g., VertxConfigurator, VertxRouterConfigurator). See SPIs under each function’s rules.
- Lifecycle phases — Structured hooks for DI + infra:
  - Pre-startup → Startup → Post-startup → Pre-destroy (shutdown). Registered via SPI providers.
- CRTP policy — GuicedEE implies CRTP for fluent APIs. ALL CRTP classes are extensible (never final) to enable type-safe client extension. See: ../fluent-api/crtp.rules.md
- JPMS (module-info) — Modules declare “requires …” and register SPI via “provides … with …”. Avoid declaring “uses IGuiceModule” in your modules (GuicedInjection already does). See: guidance in function rules.
- Service discovery/registration — Prefer Java ServiceLoader and JPMS “provides … with …”; META-INF/services may be used in addition. See: functions rules and examples.
- GuicedEE Services (shaded JPMS libs) — JPMS-aligned replacements for popular third-party libraries with stable module names and BOM alignment. See: ./services/services.md
- PostgreSQL JPMS policy — Do not shade the driver in host projects; use com.guicedee.services:postgresql and requires org.postgresql. See: ./services/services.md
- Representations (CRTP) — Domain-driven representation interfaces that convert between formats (JSON/XML/Excel) using type-safe fluent CRTP. See: ./services/representations.md

Major function families (route-to rules)
- GuicedInjection (Core DI) — SPI setup, lifecycle, module configuration. See: ./functions/guiced-injection-rules.md
- GuicedVertx (Core Vert.x integration) — Event loop, verticles, event bus integration, lifecycle. See: ./functions/guiced-vertx-rules.md
- GuicedVertxWeb (HTTP/HTTPS + router) — Vert.x Web server, router configurators, TLS/keystore, static resources. See: ./functions/guiced-vertx-web-rules.md
- GuicedVertxRest (REST/Jakarta WS) — REST configuration on Vert.x, interceptors, scanners, debug endpoints. See: ./functions/guiced-vertx-rest-rules.md
- GuicedVertxPersistence (DB/Hibernate Reactive) — Connection setup, transactions, reactive patterns. See: ./functions/guiced-vertx-persistence-rules.md
- GuicedVertxSockets (WebSockets) — Real-time communication via Vert.x sockets, handlers. See: ./functions/guiced-vertx-sockets-rules.md
- GuicedRabbit (RabbitMQ) — Messaging clients, queue config, publish/consume patterns. See: ./functions/guiced-rabbit-rules.md
- GuicedCerial (Serial IO) — Serial port comms, event handling, recovery. See: ./functions/guiced-cerial-rules.md
- GuicedHibernate (ORM classic) — Hibernate ORM integration (blocking), sessions, transactions. See: ./functions/guiced-hibernate-rules.md
- GuicedSwaggerOpenAPI (API docs) — Swagger/OpenAPI generation and UI for GuicedEE apps. See: ./functions/guiced-swagger-openapi-rules.md

LLM interpretation guidance (how to apply these terms)
- Strategy defaults
  - Fluent API Strategy: If GuicedEE is in scope, select CRTP; do not mix with Builder. Use handwritten fluent setters returning the generic self type with an unchecked cast (return (J) this;) where needed.
  - Reactive policy: When GuicedEE + Vert.x or Hibernate Reactive is present, apply non-blocking patterns; avoid blocking on event loop.
- Routing by term cue
  - “IGuiceModule/PreStartup/PostStartup/PreDestroy”, “SPI”, “lifecycle hooks” → ./functions/guiced-injection-rules.md
  - “Vert.x”, “event bus”, “verticles”, “web server/router” → ./functions/guiced-vertx-rules.md, ./functions/guiced-vertx-web-rules.md
  - “REST”, “JAX-RS/Jakarta WS”, “interceptors” → ./functions/guiced-vertx-rest-rules.md
  - “persistence”, “hibernate reactive”, “transactions” → ./functions/guiced-vertx-persistence-rules.md
  - “websocket” → ./functions/guiced-vertx-sockets-rules.md
  - “rabbitmq” → ./functions/guiced-rabbit-rules.md
  - “serial”, “com port” → ./functions/guiced-cerial-rules.md
  - “hibernate (classic)” → ./functions/guiced-hibernate-rules.md
  - “OpenAPI/Swagger” → ./functions/guiced-swagger-openapi-rules.md
  - “shaded JPMS libraries”, “guicedee services”, “postgresql policy” → ./services/services.md
  - “representations”, “CRTP representation” → ./services/representations.md
- JPMS and SPI registration
  - Prefer module-info “provides … with …” to register SPI implementations; optionally duplicate via META-INF/services for non-module consumers.
  - Do not declare “uses com.guicedee.guicedinjection.interfaces.IGuiceModule” in your module — GuicedInjection already does; rely on it to discover providers.
- Class design policy (CRTP)
  - Extensible bases MUST be CRTP (abstract Base<J extends Base<J>>) so fluent chains preserve subtype. All CRTP classes remain extensible (never final) for client extension.
- Nullness
  - Adopt @org.jspecify.annotations.NullMarked; annotate @org.jspecify.annotations.Nullable only where null is part of the contract. Avoid @Nullable Optional<T> and returning null collections/optionals.

Terminology hints (routing)
- “SPI providers”, “module-info provides … with …” → GuicedInjection
- “router configurator”, “TLS keystore”, “static handler” → GuicedVertxWeb
- “REST interceptors”, “scanner config”, “debug endpoints” → GuicedVertxRest
- “reactive SessionFactory”, “transactions”, “Mutiny Uni/Multi” → GuicedVertxPersistence
- “ws handler”, “socket event” → GuicedVertxSockets
- “queue/binding”, “publish/consume” → GuicedRabbit
- “serial port”, “baud rate”, “parity” → GuicedCerial
- “hibernate session”, “entity mapping (blocking)” → GuicedHibernate
- “openapi ui”, “swagger schema” → GuicedSwaggerOpenAPI
- “services BOM”, “postgres driver policy” → GuicedEE Services

See also
- Topic index — ./README.md
- Functions (rules) — ./functions/
- Services (JPMS shaded libs) — ./services/services.md
- Representations — ./services/representations.md
- Fluent API (CRTP/Builder) — ../fluent-api/README.md
- JSpecify — ../jspecify/README.md
- Lombok — ../lombok/README.md