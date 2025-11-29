# Configuration Rules — GuicedEE Websockets

Scope: WebSocket server tuning via `WebSocketServerOptions`.

## Options & Defaults
- `perMessageCompressionSupported` (default: true)
- `compressionLevel` (0-9, default: 9)
- `maxFrameSize` (bytes, default: 65536)
- `maxChunkSize` (bytes, default: 65536)
- `maxFormAttributeSize` (bytes, default: 65536)
- `registerWebSocketWriteHandlers` (default: true)
- `idleTimeoutSeconds` (default: 300)
- `maxGroupSize` (default: 10000)

## Validation
- Enforce: `maxChunkSize > 0`, `maxFrameSize > 0`, `maxGroupSize > 0`, `idleTimeoutSeconds > 0`.
- Enforce: `compressionLevel` in 0–9.
- Validate options before wiring HttpServer: `VertxSocketHttpWebSocketConfigurator.builder(HttpServerOptions)`.

## Usage
- Bind `WebSocketServerOptions` via DI to override defaults.
- Keep configuration immutable at runtime; set on startup only.
- Document tuned values in release notes when they change.

## References
- Implementation: `WebSocketServerOptions`, `VertxSocketHttpWebSocketConfigurator`
- Enterprise Vert.x rules: `rules/generative/backend/vertx/README.md`
