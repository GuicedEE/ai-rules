# Vert.x Web Server Bootstrap — Topic Index

Bootstrap HTTP/HTTPS servers with Vert.x 5 in GuicedEE applications. Use these modular rules when configuring the server, router, SPI handlers, and integrating with GuiceEE lifecycle.

## Selected stacks & policies
- Java 25 LTS — `rules/generative/language/java/java-25.rules.md`; Maven build tooling — `rules/generative/language/java/build-tooling.md`
- Vert.x 5 — `rules/generative/backend/vertx/README.md`; GuicedEE Core + Client — `rules/generative/backend/guicedee/README.md`
- Fluent API: CRTP (no Lombok @Builder) — `rules/generative/backend/fluent-api/crtp.rules.md`
- Logging — `rules/generative/backend/logging/README.md`; JSpecify — `rules/generative/backend/jspecify/README.md`
- CI/CD: GitHub Actions — `rules/generative/platform/ci-cd/providers/github-actions.md`; env/secrets — `rules/generative/platform/secrets-config/env-variables.md`
- Document Modularity & Forward-Only — see RULES.md (host) and rules/RULES.md (repository)

## Topic modules
- Server & options configuration — ./server-configuration.rules.md
- SPI interfaces & registration — ./spi-configurators.rules.md
- Router setup & request handling — ./router-configuration.rules.md
- Common use cases (REST, WebSocket, static, uploads) — ./use-cases.rules.md
- Module configuration & JPMS — ./module-info.rules.md
- Lifecycle integration — ./lifecycle.rules.md
- Troubleshooting & best practices — ./best-practices.rules.md
- Glossary — ./GLOSSARY.md (authoritative for this module)

## Cross-links
- GuicedEE Bridge: generative/backend/guicedee/vertx/README.md
- Vert.x Core: generative/backend/vertx/README.md
- GuicedEE: generative/backend/guicedee/README.md
- Language/Fluent API: generative/language/java/java-25.rules.md; generative/backend/fluent-api/crtp.rules.md
- Platform: generative/platform/ci-cd/README.md; generative/platform/secrets-config/env-variables.md
- Architecture references: docs/architecture/README.md, sequence-startup.md, c4-component-vertx-web.md

See docs/PROMPT_REFERENCE.md for selected stack traceability and how to load these rules in future prompts.
