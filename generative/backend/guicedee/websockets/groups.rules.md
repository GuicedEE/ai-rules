# Groups Rules — GuicedEE Websockets

Scope: group creation, membership, broadcast, and limits.

## Creation & Membership
- Default groups: `EveryoneGroup` and `RequestContextId`.
- `addToGroup`/`removeFromGroup` first invoke SPI hooks; if none handle, fall back to `groupSockets`/`groupConsumers`.
- Ensure `groupSockets`/`groupConsumers` maps exist before registration; create lazily.

## Broadcast
- `broadcastMessage` uses SPI publish override first; default path iterates `groupSockets` and writes to sockets.
- Log WARN and create placeholder group if publishing to a missing group.
- Use EventBus consumers per group to fan out messages to sockets.

## Limits & Safety
- Validate `maxGroupSize > 0`; enforce via `WebSocketServerOptions`.
- Protect against large fan-out; consider compression and chunk sizes in options.
- Remove sockets and consumers on close/exception to avoid leaks.

## References
- Architecture: `docs/architecture/c4-container.md`, `docs/architecture/erd-websocket-model.md`
- Options: `configuration.rules.md`
