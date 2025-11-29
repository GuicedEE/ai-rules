# Lifecycle Rules — GuicedEE Websockets

Scope: connection setup, scope enter/exit, cleanup, and event-loop safety for Vert.x 5 with GuicedEE scopes.

## Connection Setup
- Register the WebSocket handler via `VertxSocketHttpWebSocketConfigurator` during `IGuicePostStartup`.
- Bind `ServerWebSocket` and `RequestContextId` into `CallScopeProperties`; enter scope before handling frames.
- Configure default groups on connect: `EveryoneGroup` and the per-connection `RequestContextId`.

## Event-Loop Safety
- Never block the event loop. Use `WorkerExecutor` or `vertx.executeBlocking` for I/O.
- Avoid long-running SPI hooks; log and fail fast. Wrap failures in `WebSocketException`.
- Keep handler code idempotent; Vert.x may re-deliver if backpressure or reconnects occur.

## Scope Management
- Re-enter `CallScoper` per message (`processMessageInContext` pattern) and ensure `eventually(callScoper::exit)` runs.
- Bind `ServerWebSocket` in scope for downstream handlers; clean up on close/exception handlers.
- Remove sockets and consumers from `groupSockets`/`groupConsumers` on close.

## Error Handling
- Decode errors: log and drop; do not crash the event loop.
- Hook failures: wrap as `WebSocketException` and continue cleanup; do not suppress scope exit.
- Missing handlers: log WARN; no-op is acceptable.

## References
- Architecture sequences: `docs/architecture/sequence-websocket-lifecycle.md`
- Enterprise Vert.x rules: `rules/generative/backend/vertx/README.md`
