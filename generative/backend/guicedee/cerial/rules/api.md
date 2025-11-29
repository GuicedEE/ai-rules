# API Rules — CerialPortConnection (CRTP)

Purpose
- Define the CRTP-fluent API surface for `CerialPortConnection` and the serial configuration enums it depends on.

Requirements
- CRTP only: setters like `setBaudRate`, `setDataBits`, `setParity`, `setStopBits`, `setFlowControl`, `setTimeoutMillis` return `(J) this`. Do not add Lombok `@Builder`.
- Enumerations: extend or adjust `BaudRate`, `DataBits`, `Parity`, `FlowControl`, `StopBits`, `ComPortStatus` before exposing new configuration. Validate combinations and log any rejected inputs.
- Utilities: keep open/close helpers, buffer/byte writes, and last-message tracking side-effect-light and chainable.
- Lifecycle: maintain `IGuicePreDestroy` to ensure `disconnect()` is invoked during shutdown; surface idempotent disconnect logic.

Examples (outline)
- Fluent configuration and connect:
  - `connection.setBaudRate(BaudRate.$9600).setDataBits(DataBits.$8).setParity(Parity.None).connect();`
- Timeouts and flow control:
  - `connection.setTimeoutMillis(2000).setFlowControl(FlowControl.HardwareRtsCts);`

See also
- Glossary — ../GLOSSARY.md (CRTP, enums, status definitions)
- Lifecycle rules — ./lifecycle.md
- Data listeners — ./data-listeners.md
