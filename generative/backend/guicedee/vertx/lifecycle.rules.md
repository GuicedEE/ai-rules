# Lifecycle & Module Wiring (Guiced Vert.x)

Purpose: Align GuicedEE lifecycle hooks with Vert.x 5 startup so event registry, codecs, and bindings are deterministic.

- Startup order (see docs/architecture/sequence-startup.md):
  - `VertXPreStartup` creates Vert.x (applying `VertxConfigurator` SPI), scans `@VertxEventDefinition`, registers codecs, then installs `VertXModule`.
  - `VertXModule` binds the Vert.x singleton, named `VertxEventPublisher<T>` instances, and consumer classes derived from registry metadata.
  - `VertXPostStartup` deploys verticles via `VerticleStartup`/`VerticleBuilder`, runs configurators that require an injector, and sets the static `VertX` accessor.
- Respect CRTP fluent APIs on builders/configurators; do not add Lombok @Builder.
- Keep lifecycle idempotent: avoid side effects in annotation scans; guard codec registration against duplicates.
- Prefer DI access to Vert.x via Guice bindings; use the static `VertX` accessor only for legacy paths that cannot participate in DI.
- Register lifecycle services via JPMS (`module-info.java`) and keep module names aligned with Vert.x and GuicedEE services.
- Logging: log lifecycle milestones (boot, registry counts, codec results, verticle deployments) at info level; avoid logging payloads.

See also: ./configuration.rules.md, ./event-definitions.rules.md, ./verticles.rules.md, docs/architecture/c4-component-runtime.md.
