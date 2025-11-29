# GuicedEE Cerial — Topic Glossary (priority over root for serial scope)

Scope
- Canonical terms for the `com.guicedee.cerial` module. These entries override the root glossary when the Cerial topic is in scope.

Canonical terms
- **CerialPortConnection** — CRTP-fluent serial client exposing configuration setters (baud, parity, data bits, flow control, timeouts) and lifecycle hooks (`connect`, `disconnect`, `IGuicePreDestroy`). Utilities handle last-message tracking and buffer writes.
- **ComPortEvents** — Central event aggregator for status/data callbacks, wiring `SerialPortDataListener` implementations into structured notifications.
- **CerialPortsBindings** — `IGuiceModule` that binds per-port `CerialPortConnection` instances via `Names.named`.
- **CerialPortConnectionProvider** — Guice provider that constructs/configures `CerialPortConnection` singletons per port number.
- **CerialIdleMonitor** — Vert.x-timer-driven idle detector that reads `lastMessageTime` and emits `ComPortStatus` transitions (Online → Silent/Offline) through `ComPortEvents`.
- **ComPortStatus** — Enumeration of port states (Offline, Connecting, Online, Silent, Faulted, etc.) used across listeners and monitors.
- **SerialPortDataListener variants** — Message/byte listeners that delegate to `ComPortEvents` and update `lastMessageTime` without blocking the Vert.x event loop.
- **ComPortEvents callbacks** — Includes status/error hooks such as `onConnectError(Throwable)`, `onComPortStatusUpdate(ComPortStatus)`, and comPortRead/comPortWrite notifications used by listeners and monitors.

LLM interpretation guidance
- Route “serial”, “com port”, “baud/parity/data bits”, “idle monitor”, or “jSerialComm listener” questions to this topic’s rules and examples.
- Apply CRTP rules: fluent setters return `(J) this`; do not introduce builders on the same API.
- Default nullness is `@NullMarked`; use `@Nullable` only where absent values are part of the contract (e.g., optional callbacks).
- Prefer structured events/logging over ad-hoc `println` for diagnostics; include port identifiers and statuses.

See also
- Topic index — ./README.md
- Rules — ./rules/
- Services & SPI registration — ./services/services.md
- Examples — ./examples/examples.md
