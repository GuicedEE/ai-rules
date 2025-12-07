# Activity Master Rules Index

Scope: Reactive Activity Master Client rules for version 3.0.0-SNAPSHOT. Focused on CRTP fluent builders, system and enterprise services, token caching, and Hibernate Reactive 7 over Vert.x 5 with GuicedEE bindings.

Topic map
- Cerial Master (serial port addon): ./cerial/README.md
- Cerial Master client rules (client library): ./cerial-client/README.md
- Core Activity Master client rules (referenced by this library): ./client/README.md
- Interface hierarchies: ./interface_hierarchies.md
- Topic glossary (topic-first, authoritative for Activity Master terms): ./GLOSSARY.md

Cross-links
- Data category index: ../README.md
- Backend stacks: ../../backend/vertx/README.md, ../../backend/hibernate/README.md, ../../backend/guicedee/README.md, ../../backend/fluent-api/README.md
- Platform: ../../platform/observability/README.md, ../../platform/secrets-config/env-variables.md, ../../platform/testing/README.md, ../../platform/ci-cd/README.md
- Architecture sources (Mermaid MCP rendered): ../../../../docs/architecture/README.md and linked diagrams

Forward-only and modularity
- Replace monoliths with the modular files referenced above and update links rather than duplicating content.
- Keep host project docs (PACT/RULES/GUIDES/IMPLEMENTATION) outside the rules directory; use this index to align prompts and generation.
