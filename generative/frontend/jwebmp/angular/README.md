# JWebMP Angular Rules Index (Angular 20, Vert.x 5)

Use this topic when generating or hosting Angular 20 applications from JWebMP annotations with Vert.x STOMP/WebSocket bridging. Follow the base language rules first, then these library specifics.

- Scope and stacks: Java 25 LTS, Maven; Angular 20; TypeScript base rules; JWebMP Core/Client/TypeScript; GuicedEE Core/Client/Web/WebSocket; Vert.x 5 hosting; CRTP fluent APIs with Log4j2 (`@Log4j2`).
- Do not edit generated artifacts (Angular TS/HTML/CSS/dist); change the Java sources that feed generation instead.
- Use CRTP setters (no Lombok `@Builder` on fluent types). Keep logging with Log4j2 only.

Rules
- Overview and conventions — ./overview.rules.md
- Type generation pipeline — ./type-generation.rules.md
- Hosting and messaging — ./hosting-messaging.rules.md
- Testing and coverage — ./testing.rules.md
- Release notes (forward-only) — ./release-notes.md

See also (enterprise topics)
- Angular language base — ../../../language/angular/README.md and ../../../language/angular/angular-20.rules.md
- TypeScript language base — ../../../language/typescript/README.md
- JWebMP Core/Client/TypeScript — ../README.md, ../core/README.md, ../client/README.md, ../typescript/README.md
- GuicedEE Web/WebSocket/Vert.x — ../../../backend/guicedee/web/README.md, ../../../backend/guicedee/websockets/README.md, ../../../backend/guicedee/vertx/README.md
- Logging — ../../../backend/logging/README.md
- Fluent API (CRTP) — ../../../backend/fluent-api/crtp.rules.md
- CI/CD — ../../../platform/ci-cd/README.md and ../../../platform/ci-cd/providers/github-actions.md
- Testing — ../../../platform/testing/README.md, ../../../platform/testing/jacoco.rules.md, ../../../platform/testing/java-micro-harness.rules.md, ../../../platform/testing/browserstack.rules.md
