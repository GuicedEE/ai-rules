# Data Listeners & Events — Cerial

Purpose
- Standardize serial data/status handling through `ComPortEvents` and non-blocking listener implementations.

Requirements
- Listener design: implement `SerialPortDataListener` variants (message vs. byte listeners) that delegate to `ComPortEvents` and update `lastMessageTime`. Avoid blocking calls; handle exceptions and propagate them as structured events.
- Event routing: all status transitions and data notifications flow through `ComPortEvents` so logging/telemetry stays centralized.
- Status model: use `ComPortStatus` (Offline/Connecting/Online/Silent/Faulted/etc.). Emit transitions when errors, disconnects, or idle detection occur.
- CRTP safety: helpers that attach listeners should preserve fluent chains on `CerialPortConnection`.
- Logging: prefer Log4j2 with port identifiers and status context; no raw `System.out`.
- Error/status callbacks: surface `onConnectError(Throwable)`, `onComPortStatusUpdate(ComPortStatus)` (and similar) through `ComPortEvents` so downstream consumers receive consistent updates; avoid direct logging-only handlers.
- SPI messaging: when wiring comPortRead/comPortWrite callbacks, keep them non-blocking and ensure they update `lastMessageTime` and propagate data through `ComPortEvents` instead of bypassing the aggregator.

Examples (outline)
- Attach listeners: `connection.addMessageListener(new DataSerialPortMessageListener(events)).addBytesListener(new DataSerialPortBytesListener(events));`
- Status/error callbacks: `events.onConnectError(ex); events.onComPortStatusUpdate(status);` should notify consumers and emit structured logs.
- Error routing: catch listener exceptions, log with context, and emit `ComPortStatus.Faulted` through `ComPortEvents`.

See also
- Idle monitoring — ./idle-monitoring.md
- API rules — ./api.md
- Glossary — ../GLOSSARY.md
