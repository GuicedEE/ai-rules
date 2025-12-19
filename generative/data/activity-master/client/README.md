# Activity Master Client Rules

Scope
- Reactive client library for Activity Master SPI (3.0.0-SNAPSHOT) using GuicedEE + Vert.x 5 + Hibernate Reactive 7 and CRTP fluent builders.
- Documents lifecycle flows, query/builder usage, token caching, configuration, and testing expectations.

Topic index
- Lifecycle and bootstrap rules: ./lifecycle.rules.md
- Builder and query rules: ./builders.rules.md
- Token cache rules: ./token-cache.rules.md
- Configuration and deployment rules: ./configuration.rules.md
- Testing and validation rules: ./testing.rules.md
- Release notes (forward-only): ./release-notes.md

Cross-links
- Activity Master topic index: ../README.md
- Interface hierarchies: ../interface_hierarchies.md
- Topic glossary: ../GLOSSARY.md
- Architecture diagrams (Mermaid MCP sources): ../../../../../docs/architecture/README.md
- Stacks: ../../../backend/vertx/README.md, ../../../backend/hibernate/README.md, ../../../backend/guicedee/README.md, ../../../backend/fluent-api/README.md
- Platform: ../../../platform/observability/README.md, ../../../platform/secrets-config/env-variables.md, ../../../platform/testing/README.md, ../../../platform/ci-cd/README.md

Usage
- Start from this index when crafting prompts or adding features to ensure rules, glossary, and diagrams stay aligned.
- Keep all updates forward-only; replace outdated references instead of duplicating them.
