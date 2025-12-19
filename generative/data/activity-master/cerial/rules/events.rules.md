# Events and Messaging Rules — Activity Master Cerial

Event taxonomy
- Lifecycle: `RegisteredANewConnection`, `ClosedANewConnection`.
- Messaging: `SendMessageToComPort`, `Message`, `MessageReceivedFromComPort` (and optional `RawMessage` classification for raw payload capture).
- Register event types during installation using Activity Master `IEventService` with provided Mutiny session/token.

Event handling guidance
- Emit lifecycle events when connections are created/removed; include COM port number and device type in payload/classifications.
- For messaging, persist message resource items/types when required by upstream workflows; keep payload handling non-blocking.
- When reading from COM ports, validate payload boundaries using `ComPortAllowedCharacters` and `ComPortEndOfMessage` classifications before emitting message events.

Observability
- Trace events with Log4j2; avoid logging full payloads for sensitive content—log hashes or metadata instead.
- If telemetry is required, align with Activity Master telemetry rules and ensure classification values map to event attributes for downstream consumers.
