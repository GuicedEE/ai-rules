# JWebMP Core — Rules Index

Scope
- Service/framework rules for the JWebMP Core + Client stack on Java 25 + Maven with CRTP fluent APIs, Log4j2 logging, JSpecify nullness, and GuicedEE + Vert.x integration.
- Use these rules when maintaining the library or authoring host app code that consumes it; keep host-specific docs outside this rules repository.

Topics
- Rendering & Components — ./jwebmp-core-rendering.rules.md
- GuicedEE Integration — ./guicedee-integration.rules.md
- Logging — ./logging.rules.md
- Nullness (JSpecify) — ./jspecify.rules.md
- CI/CD (GitHub Actions) — ./github-actions.rules.md

Related enterprise topics
- JWebMP (frontend): ../README.md
- JWebMP Client (configuration/rendering/reactive/logging/nullness/examples): ./client/README.md
- GuicedEE: ../../backend/guicedee/README.md (+ client/web/vertx)
- Vert.x: ../../backend/vertx/README.md
- Java 25 + Maven: ../../language/java/README.md, ../../language/java/java-25.rules.md, ../../language/java/build-tooling.md
- Logging: ../../backend/logging/README.md
- JSpecify: ../../backend/jspecify/README.md
- CI/CD: ../../platform/ci-cd/README.md and provider ../../platform/ci-cd/providers/github-actions.md

Policies
- Forward-only: replace obsolete docs/anchors; update indexes when reorganizing.
- Document Modularity: keep topic files focused and link back to this index.
- Documentation-first stages apply; blanket approval is honored when provided by the requester.
