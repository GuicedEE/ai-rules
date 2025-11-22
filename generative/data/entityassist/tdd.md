# EntityAssist Reactive TDD (Topic Supplement)

Purpose
- Extend the enterprise [TDD architecture guide](rules/generative/architecture/tdd/README.md) with rules specific to EntityAssistReactive.
- Applies to contributors writing or consuming the library under `generative/data/entityassist/`.

Scope
- Unit, integration, and contract tests for CRTP entities, query builders, GuicedEE database modules, and JPMS module wiring.
- Covers both the library repository and downstream projects that embed the module.

## Testing Levels

| Level | Focus | Tooling / Notes |
| --- | --- | --- |
| Unit | Builders, entities, converters in isolation. Verify fluent APIs, validation, and Mutiny chaining without hitting a real database. | JUnit 5 (or Jupiter via GuicedEE test harness), Mutiny `UniAssertSubscriber`, Mockito/AssertJ. Ensure the JPMS test module exports the packages under test. |
| Integration | Persistence flows against a live database via Testcontainers. Validate `DatabaseModule` wiring, JPMS `--add-reads`, and Guice injection. | JUnit 5 + `@Testcontainers` or programmatic lifecycle, PostgreSQL container (or driver-specific alternative). Always load the same `module entity.assist.test` pattern and reuse the project’s `.env.example` toggles (e.g., `TEST_DB_CONTAINER_IMAGE`). |
| Contract / Acceptance | Library consumed inside a host service. Verify the builder contracts (e.g., query filters, transaction semantics) using Gherkin or scenario-based tests. | JUnit/JBehave/Cucumber; ensure builders are resolved through DI rather than manual instantiation. |

## Core Practices
1. **JPMS test module** — Mirror the library’s `module entity.assist.test` so Hibernate Reactive can reflectively inspect entities. Include `opens com.<tests>` to `org.hibernate.orm.core`, `com.google.guice`, `org.junit.platform.commons`, `net.bytebuddy`, and `com.entityassist` if required.
2. **Mutiny assertions** — Use `UniAssertSubscriber` or `.subscribe().with` to assert signals. Tests must verify that builder helpers never return `null` and that errors propagate when Hibernate raises an exception.
3. **DatabaseModule coverage** — Write tests that extend or override the `DatabaseModule` to prove credential handling, `setReactive(true)`, and connection pooling flags. Treat `.env` as optional toggles; real credentials live in the module.
4. **Criteria expectations** — For `QueryBuilder` tests, inspect generated predicates by applying filters and verifying the resulting SQL via Hibernate logging/test double, or by executing against Testcontainers and inspecting outcomes (counts, result sets).
5. **Forward-only docs** — When adding new testing helpers, update the corresponding rules in this topic so downstream teams inherit the guidance (do not delete prior instructions; supersede them).

## Example Checklist
- [ ] `mvn -B verify` passes with Surefire `--add-reads` flags intact.
- [ ] Testcontainers spins up the database declared in `.env` (`TEST_DB_CONTAINER_IMAGE`), and the `DatabaseModule` reads host/port/user from the container.
- [ ] Mutiny `Uni` contract verified: success + failure paths.
- [ ] CRTP typing enforced (no raw/unchecked generics in tests).
- [ ] Guice modules registered via `ServiceLoader` (`META-INF/services/com.guicedee.guicedinjection.interfaces.IGuiceModule`).

## References
- [EntityAssist Reactive Rules](./entity-assist-reactive-rules.md)
- [Glossary](./GLOSSARY.md)
- Related enterprise topics: `rules/generative/architecture/tdd/README.md`, `rules/generative/backend/vertx/README.md`, `rules/generative/backend/hibernate/README.md`.
