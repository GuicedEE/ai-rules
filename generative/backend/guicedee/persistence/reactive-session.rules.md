# Reactive Session Rules — GuicedEE Vert.x Persistence

Guidance for exposing and consuming `Mutiny.SessionFactory` through GuicedEE and Vert.x.

## Provider Semantics
- `MutinySessionFactoryProvider` must be the sole provider exported to application services; never bypass it to access `EntityManagerFactory`.
- Provider should lazily start via `JtaPersistService` and cache the unwrapped `Mutiny.SessionFactory`; guard against returning null by validating bootstrap completion.
- Respect CRTP builder constraints on connection info; avoid mutating returned factories.

## Usage Patterns
- Inject `Mutiny.SessionFactory` into Vert.x services or repositories; align transaction semantics with `rules/generative/backend/hibernate/README.md` (reactive transactions, session-per-request guidance).
- For Vert.x event-loop safety, ensure operations remain non-blocking; offload blocking calls to worker pools where unavoidable.
- When integrating with Vert.x SQL clients, map configuration from `ConnectionBaseInfo` to Vert.x datasource creation (see `configuration.rules.md`).

## Observability & Logging
- Emit lifecycle logs around provider access (acquire/release) using Log4j2; avoid logging SQL or secrets.
- Trace session resolution using the flow in `../../../../../docs/architecture/sequence-session-resolution.md`.

## Performance Constraints
- Keep provider lookup constant-time; avoid reflection-heavy paths at runtime by preloading ServiceLoader contributors during bootstrap.
- Reuse Vert.x shared clients where possible to minimize connection churn.

## See also
- `bootstrapping.rules.md` for startup ordering
- `configuration.rules.md` for connection metadata
- `ci-cd-and-secrets.rules.md` for secrets handling
