# GuicedEE Websockets — Rules Index

Library-specific rules for GuicedEE Websockets (Vert.x 5 + GuicedEE Core/Web/Client). These docs live inside the Rules Repository at `rules/generative/backend/guicedee/websockets/` and mirror the host library docs.

## Modules
- [lifecycle.rules.md](./lifecycle.rules.md) — connection setup, scope entry/exit, event-loop safety
- [message-routing.rules.md](./message-routing.rules.md) — decoding, handler dispatch, error handling
- [groups.rules.md](./groups.rules.md) — group creation, membership, broadcast, limits
- [spi.rules.md](./spi.rules.md) — `GuicedWebSocketOn*` hooks and message listener registry
- [configuration.rules.md](./configuration.rules.md) — `WebSocketServerOptions`, defaults, validation

## Cross-Links (Enterprise)
- Vert.x: `rules/generative/backend/vertx/README.md`
- GuicedEE Core/Web/Client: `rules/generative/backend/guicedee/README.md`, `rules/generative/backend/guicedee/web/README.md`, `rules/generative/backend/guicedee/client/README.md`
- Fluent API (CRTP): `rules/generative/backend/fluent-api/crtp.rules.md`
- Nullability (JSpecify): `rules/generative/backend/jspecify/README.md`
- Logging: `rules/generative/structural/logging/README.md`
- CI/CD: `rules/generative/platform/ci-cd/providers/github-actions.md`

## Prompt Language Alignment & Glossary
- Canonical glossary: `GLOSSARY.md` (topic-first). Host projects should copy only enforced mappings; otherwise link back here.
- Use “RequestContextId” for per-connection group, “EveryoneGroup” for broadcast-all, and “messageListeners” for the action registry.

## Usage
1) Read lifecycle and message-routing rules before modifying handlers.  
2) Apply configuration rules when setting `WebSocketServerOptions`.  
3) Implement SPI hooks via DI (preferred) or ServiceLoader fallbacks; see `spi.rules.md`.  
4) Keep implementations non-blocking; offload blocking work.  
5) Cross-check with enterprise rules above for language/framework constraints.
