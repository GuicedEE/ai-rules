# GuicedEE Vert.x Persistence Rules (Index)

Topic index for the GuicedEE Vert.x Persistence ruleset. These rules target GuicedEE + Vert.x 5 + Hibernate Reactive 7 on Java 25 with CRTP-based fluent APIs and Log4j2 logging. Architecture references live under `../../../../../docs/architecture/`.

## Modules
- [configuration.rules.md](configuration.rules.md) — persistence unit descriptors, property readers, connection metadata, CRTP builder constraints.
- [bootstrapping.rules.md](bootstrapping.rules.md) — module lifecycle, `JtaPersistModule` wiring, lifecycle hooks, and trust boundaries.
- [reactive-session.rules.md](reactive-session.rules.md) — `Mutiny.SessionFactory` exposure, provider semantics, and Vert.x integration.
- [ci-cd-and-secrets.rules.md](ci-cd-and-secrets.rules.md) — GitHub Actions alignment, env var handling, and logging guardrails.
- [GLOSSARY.md](GLOSSARY.md) — topic-first terms with LLM interpretation guidance for persistence flows.

## Cross-links to enterprise topics
- Language & build: [`rules/generative/language/java/java-25.rules.md`](../../../language/java/java-25.rules.md), [`rules/generative/language/java/build-tooling.md`](../../../language/java/build-tooling.md)
- Frameworks: [`rules/generative/backend/guicedee/README.md`](../README.md), [`rules/generative/backend/guicedee/vertx/README.md`](../vertx/README.md), [`rules/generative/backend/hibernate/README.md`](../../hibernate/README.md)
- Logging & Lombok: [`rules/generative/backend/logging/README.md`](../../logging/README.md), [`rules/generative/backend/logging/LOGGING_RULES.md`](../../logging/LOGGING_RULES.md), [`rules/generative/backend/lombok/GLOSSARY.md`](../../lombok/GLOSSARY.md)
- CI/CD: [`rules/generative/platform/ci-cd/README.md`](../../../platform/ci-cd/README.md), [`rules/generative/platform/ci-cd/providers/github-actions.md`](../../../platform/ci-cd/providers/github-actions.md)
- Security & config: [`rules/generative/platform/secrets-config/env-variables.md`](../../../platform/secrets-config/env-variables.md), [`rules/generative/platform/security-auth/README.md`](../../../platform/security-auth/README.md)

## Architecture references
- System + containers: `../../../../../docs/architecture/c4-context.md`, `../../../../../docs/architecture/c4-container.md`
- Components: `../../../../../docs/architecture/c4-component-configuration.md`, `../../../../../docs/architecture/integration-trust-boundaries.md`
- Flows: `../../../../../docs/architecture/sequence-persistence-bootstrap.md`, `../../../../../docs/architecture/sequence-session-resolution.md`
- Domain model: `../../../../../docs/architecture/erd-connection-domain.md`
