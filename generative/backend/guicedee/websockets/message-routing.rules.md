# Message Routing Rules — GuicedEE Websockets

Scope: decoding, dispatching, and responding to WebSocket text frames.

## Decode & Dispatch
- Decode JSON frames with `ObjectMapper` into `WebSocketMessageReceiver`.
- Set `broadcastGroup` to the current `RequestContextId` before dispatch.
- Route by `action` using `IGuicedWebSocket.getMessagesListeners()`; one handler per action. Log WARN when missing.

## Handler Expectations
- Handlers must be non-blocking; offload I/O.
- Handlers may respond directly (`writeTextMessage`) or publish to groups (EventBus).
- JSpecify on all public APIs; CRTP fluent APIs only (no Lombok `@Builder`).
- Use SLF4J for logging; include `RequestContextId` in context where possible.

## Failure Semantics
- Decode failure → log error → drop message; scope still exits.
- Handler failure → log error; other handlers remain unaffected.
- Hook failure (publish override) → wrap as `WebSocketException`; fall back to default broadcast.

## Testing Notes
- Unit-test handler dispatch per action.
- Verify decode failure does not crash the loop.
- Validate group publish writes to all sockets in `groupSockets`.

## References
- Architecture sequence: `docs/architecture/sequence-message-routing.md`
- Vert.x rules: `rules/generative/backend/vertx/README.md`
- CRTP fluent API: `rules/generative/backend/fluent-api/crtp.rules.md`
