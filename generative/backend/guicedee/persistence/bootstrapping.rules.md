# Bootstrapping Rules — GuicedEE Vert.x Persistence

Describes how persistence units are initialized through GuicedEE modules and lifecycle hooks.

## Module Lifecycle
- Extend `DatabaseModule` subclasses with `@EntityManager` to declare persistence units; override `getPersistenceUnitName()` and `getConnectionBaseInfo(...)`.
- Register per-persistence-unit `JtaPersistModule` instances during `configure()`; modules must be idempotent across reloads.
- `VertxPersistenceModule` tracks `ConnectionBaseInfo → JtaPersistModule` pairs and exposes Hibernate services via `VertxServiceContributor`.
- `GuicedConfigurator` must be installed to enable annotation/field/method scanning used by persistence modules.

## Startup Sequence
- Follow `../../../../../docs/architecture/sequence-persistence-bootstrap.md` for order: property readers → connection enrichment → module registration → `JtaPersistService.start()`.
- `JtaPersistService` is responsible for creating/stopping `EntityManagerFactory` and unwrapping `Mutiny.SessionFactory`; enforce double-start guards and graceful shutdown.
- Use Log4j2 to emit lifecycle events; retain emoji markers used in existing services for consistency.

## Trust Boundaries
- Validate ServiceLoader contributions before applying them; fail fast when encountering unsupported prefixes or missing credentials.
- Enforce TLS and vetted driver artifacts at the database boundary; link to `../../../../../docs/architecture/integration-trust-boundaries.md`.
- Keep provider outputs immutable; do not leak mutable `ConnectionBaseInfo` references beyond the bootstrap window.

## Migration / Forward-only
- Remove legacy monolith docs; prefer modular RULES + GUIDES linked from the index README.
- Record breaking changes in `RELEASE_NOTES.md` and ensure new rules supersede previous ones without reintroducing deprecated APIs.

## See also
- `configuration.rules.md` for property readers and metadata
- `reactive-session.rules.md` for provider semantics
- `ci-cd-and-secrets.rules.md` for CI and env handling
