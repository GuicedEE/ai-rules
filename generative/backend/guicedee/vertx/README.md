# Guiced Vert.x Bridge — Topic Index

Bridge GuicedEE Client lifecycle with Vert.x 5. Use these modular rules when wiring event definitions, publishers, codecs, and configurators for Guiced Vert.x.

## Selected stacks & policies
- Java 25 LTS — `rules/generative/language/java/java-25.rules.md`; Maven build tooling — `rules/generative/language/java/build-tooling.md`
- Vert.x 5 — `rules/generative/backend/vertx/README.md`; GuicedEE Client — `rules/generative/backend/guicedee/README.md`
- Fluent API: CRTP (no Lombok @Builder) — `rules/generative/backend/fluent-api/crtp.rules.md`
- Logging — `rules/generative/backend/logging/README.md`; JSpecify — `rules/generative/backend/jspecify/README.md`
- CI/CD: GitHub Actions (GuicedEE libraries: shared workflow example `GuicedEE/Workflows/.github/workflows/projects.yml@master` via the `GuicedInjection` job—confirm before adding) — `rules/generative/platform/ci-cd/providers/github-actions.md`; env/secrets — `rules/generative/platform/secrets-config/env-variables.md`
- Document Modularity & Forward-Only — see RULES.md (host) and rules/RULES.md (repository)

## Topic modules
- Lifecycle & module wiring — ./lifecycle.rules.md
- Event definitions & options — ./event-definitions.rules.md
- Publishers (CRTP) — ./publishers.rules.md
- Codec strategy — ./codecs.rules.md
- Configuration & SPIs — ./configuration.rules.md
- Verticles & deployment — ./verticles.rules.md
- Testing & validation — ./testing.rules.md
- Glossary — ./GLOSSARY.md (authoritative for this bridge)

## Cross-links
- Backend: generative/backend/vertx/README.md; generative/backend/guicedee/README.md
- Language/Fluent API: generative/language/java/java-25.rules.md; generative/backend/fluent-api/crtp.rules.md
- Platform: generative/platform/ci-cd/README.md; generative/platform/ci-cd/providers/github-actions.md; generative/platform/secrets-config/env-variables.md
- Architecture references: docs/architecture/README.md, sequence-startup.md, sequence-publish-consume.md, c4-component-runtime.md

See docs/PROMPT_REFERENCE.md for selected stack traceability and how to load these rules in future prompts.
