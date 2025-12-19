# Activity Master Cerial Client Rules

Scope
- Cerial Master Client addon for Activity Master FSDM, built on GuicedEE client services, Vert.x 5, CRTP fluent DTOs, and Mutiny telemetry. This topic covers COM port message orchestration (`TimedComPortSender`, `MultiTimedComPortSender`), configuration, telemetry, integration hooks, and testing.
- Use this topic for the Cerial Master client library. For the core Activity Master client library, continue to use `../client/README.md`.

Topic index
- Lifecycle and orchestration: ./lifecycle.rules.md
- Configuration and publishing: ./configuration.rules.md
- Telemetry and snapshots: ./telemetry.rules.md
- Integration hooks (GuicedEE, drivers, TypeScript): ./integration.rules.md
- Testing and validation: ./testing.rules.md
- Release notes (forward-only): ./release-notes.md
- Topic glossary (Cerial-specific terms): ./GLOSSARY.md

Cross-links
- Activity Master topic index: ../README.md
- Interface hierarchies: ../interface_hierarchies.md
- Topic glossary (Activity Master wide): ../GLOSSARY.md
- Architecture diagrams (Mermaid sources): ../../../../../docs/architecture/README.md
- Backend stacks: ../../../backend/vertx/README.md, ../../../backend/guicedee/README.md, ../../../backend/fluent-api/README.md
- Language/tooling: ../../../language/java/java-25.rules.md, ../../../backend/mapstruct/mapstruct-6.md, ../../../backend/lombok/README.md, ../../../backend/jspecify/README.md
- Frontend bridge: ../../../frontend/jwebmp/typescript/README.md
- Platform: ../../../platform/secrets-config/env-variables.md, ../../../platform/testing/README.md, ../../../platform/ci-cd/README.md

Usage and policy
- Start from this index when prompting or extending the Cerial Master client; do not mix with `../client` unless you are working in the core Activity Master client library.
- Apply the Document Modularity Policy and Forward-Only Change Policy from `rules/RULES.md`; replace outdated anchors rather than duplicating them.
- Honor CRTP fluent setter rules; avoid Lombok `@Builder` on DTOs used by the client.
