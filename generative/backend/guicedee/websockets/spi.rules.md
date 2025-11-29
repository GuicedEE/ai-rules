# SPI Rules — GuicedEE Websockets

Scope: extensibility hooks for group lifecycle and publish overrides.

## Hooks
- `GuicedWebSocketOnAddToGroup`: invoked on `addToGroup`; may short-circuit default behavior when returning `true`.
- `GuicedWebSocketOnRemoveFromGroup`: invoked on `removeFromGroup`; may short-circuit default behavior.
- `GuicedWebSocketOnPublish`: invoked on `broadcastMessage` when no `RequestContextId` is present; return `true` to indicate handled.

## Registration
- Prefer DI multibinders to register hooks; ServiceLoader is the fallback (`IGuiceContext.loaderToSet`).
- Hooks must be non-blocking; wrap failures as `WebSocketException`.
- Declare JSpecify nullability on public methods.

## Message Listeners
- Action registry is `IGuicedWebSocket.getMessagesListeners()`; one handler per action.
- Register handlers during startup; avoid runtime mutation unless synchronized.

## References
- SPI usage: `VertxWebSocketsModule`, `GuicedWebSocket`
- Architecture: `docs/architecture/c4-component-websocket.md`
