# JWebMP Angular — Overview and Conventions

Purpose
- Generate Angular 20 source/config from JWebMP annotations and host the built dist via Vert.x 5 with STOMP/WebSocket bridging.
- Keep documentation-first and forward-only; do not preserve deprecated anchors.

Stacks and constraints
- Java 25 LTS, Maven build.
- Angular 20 + TypeScript (follow ../../../language/angular/README.md and angular-20.rules.md; TypeScript base ../../../language/typescript/README.md).
- JWebMP Core/Client/TypeScript; GuicedEE Core/Client/Web/WebSocket; Vert.x 5.
- Logging: Log4j2 via Lombok `@Log4j2`; avoid other logging annotations.
- Fluent API: CRTP; no Lombok `@Builder` on fluent types; return `(J)this` in setters.
- Generated assets are read-only (Angular TS/HTML/CSS/dist). Change Java sources and rerun generation.

How to apply
- Start from annotated Java classes: `@NgApp`, `@NgComponent`, `@NgRoutable`.
- Follow TypeScript/Angular base rules for syntax/version specifics (Angular 20).
- Use JWebMP components for markup; avoid inline HTML strings.
- When adding APIs or modules, align with GuicedEE/Vert.x rules for lifecycle and router binding.

See also
- Type generation — ./type-generation.rules.md
- Hosting/messaging — ./hosting-messaging.rules.md
- Testing — ./testing.rules.md
- Release notes — ./release-notes.md
- JWebMP core/client/typescript — ../README.md, ../core/README.md, ../client/README.md, ../typescript/README.md
- GuicedEE Web/WebSocket/Vert.x — ../../../backend/guicedee/web/README.md, ../../../backend/guicedee/websockets/README.md, ../../../backend/guicedee/vertx/README.md
