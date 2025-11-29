# GuicedEE Inject — Rules Index

Scope
- Rules for the GuicedEE Inject library: Guice-based DI, SPI discovery, classpath scanning, logging bootstrap, job service orchestration, and optional adapters (Vert.x). Forward-only change policy applies; no persistence/transaction manager is included.

Quick links (topic modules)
- Lifecycle and Boot: ./lifecycle.rules.md
- Configuration and Scanning: ./configuration.rules.md
- Extension Points (SPI): ./extension-points.rules.md
- Adapters — Vert.x (optional): ./adapters-vertx.rules.md
- Testing Strategy: ./testing.rules.md

Selected stacks and policies
- Language/Build: Java 25 LTS with Maven — rules/generative/language/java/java-25.rules.md, rules/generative/language/java/build-tooling.md
- Fluent API strategy: CRTP — rules/generative/backend/fluent-api/crtp.rules.md
- Logging: rules/generative/backend/logging/README.md
- Nullness: rules/generative/backend/jspecify/README.md
- CI/CD: rules/generative/platform/ci-cd/providers/github-actions.md
- Optional adapter: Vert.x 5 — rules/generative/backend/vertx/README.md

Cross-references and glossaries
- Architecture diagrams: docs/architecture/README.md (context/container/component/sequence/ERD)
- Prompt reference (stacks, diagram links): docs/PROMPT_REFERENCE.md
- Glossary (topic-first): ../../../../GLOSSARY.md plus rules/generative/backend/guicedee/GLOSSARY.md and related stack glossaries

Forward-only notes
- Breaking reorganizations must update inbound links in this topic.
- Keep adapters optional and isolated; do not introduce persistence (e.g., Hibernate Reactive) into this library’s rules.
