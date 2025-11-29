# CI/CD & Secrets Rules — GuicedEE Vert.x Persistence

CI/CD expectations and secrets handling for this library’s ruleset.

## GitHub Actions
- Align workflows with [`rules/generative/platform/ci-cd/README.md`](../../../platform/ci-cd/README.md) and [`providers/github-actions.md`](../../../platform/ci-cd/providers/github-actions.md); keep Java 25 toolchain pinned.
- Run documentation link checks (RULES/GUIDES/architecture) and unit tests in separate jobs; cache Maven dependencies per branch.
- Publish SNAPSHOTs only after Stage 4 approval; record release steps in `RELEASE_NOTES.md`.

## Secrets & Config
- Environment variables follow [`rules/generative/platform/secrets-config/env-variables.md`](../../../platform/secrets-config/env-variables.md); document required vars in `.env.example` before code changes.
- Never print secrets in logs; use Log4j2 markers and redaction helpers when emitting config context.
- For database credentials, prefer pulling from secrets managers via MicroProfile Config; fall back to env vars for local dev only.

## Quality Gates
- Enforce formatting and linting per Java 25 guidance; block merges on failing link checks or missing architecture references in RULES/GUIDES.
- Keep RULES/GUIDES aligned with `docs/PROMPT_REFERENCE.md` and architecture diagrams; update references when diagrams change.

## Testing & Examples
- Provide minimal reactive integration tests that start `JtaPersistService` against an in-memory database or containerized Postgres; assert `Mutiny.SessionFactory` creation and teardown.
- Include example snippets in GUIDES showing how to request `Mutiny.SessionFactory` via injection and execute a simple transaction (non-blocking).
- Gate merges on tests that validate ServiceLoader registration for `IProperties*Reader` implementations.

## See also
- `configuration.rules.md` for property reader constraints
- `bootstrapping.rules.md` for lifecycle checks
- `reactive-session.rules.md` for runtime access patterns
