# ActivityMaster Core Rules

This topic index defines how the ActivityMaster Core library (Java 25 + Maven, Vert.x 5, GuicedEE, Hibernate Reactive 7, PostgreSQL) exposes rules for host projects that integrate the reactive FSDM services. Treat it as the entry point whenever prompts mention the “ActivityMaster Core” product line; each linked `.rules.md` file focuses on a single area so prompts stay modular and forward-only.

## Topics
- **Core services & bootstrapping** (`services.rules.md`): Guides on wiring `ActivityMasterSystemsManager`, `IActivityMasterSystem`, and CRTP-based service builders.
- **Persistence & EntityAssist** (`persistence.rules.md`): Covers CRTP query builders, reactive session composition, classification joins, and DTO hydration through EntityAssist helpers.
- **Security, classification & observability** (`security.rules.md`): Explains SecurityToken propagation, classification guardrails, Log4j2 + Lombok `@Log4j2` guidance, and traceable instrumentation patterns.

## Cross-links
- Data category index: `../README.md`
- Backend stacks: `../../backend/vertx/README.md`, `../../backend/hibernate/README.md`, `../../backend/guicedee/README.md`, `../../backend/fluent-api/README.md`
- Platform stacks: `../../platform/observability/README.md`, `../../platform/secrets-config/env-variables.md`, `../../platform/testing/README.md`, `../../platform/ci-cd/README.md`
- ActivityMaster topic glossary: `../GLOSSARY.md`

## Prompt Language Alignment & Glossary
- Compliance relies on the authoritative ActivityMaster glossary (host project’s `GLOSSARY.md` supplemented by `../GLOSSARY.md`). Copy only explicitly enforced names (e.g., CRTP, `ActivityMasterSystemsManager`, `SecurityToken`, `EntityAssist helpers`) into consuming glossaries; all other terms should reference their owning topic glossary.
- This library exposes the FSDM domain as the data source and the provided systems as the functionality; consuming applications inject those systems via GuicedEE (`@Inject` or `IGuiceContext.get()`) to drive dynamic tables over the relationship graph. Clients must not alter the database schema outside the supplied graphical interfaces or the documented persistence pipelines.
