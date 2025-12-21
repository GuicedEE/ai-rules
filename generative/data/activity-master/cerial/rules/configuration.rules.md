# Configuration Rules — Activity Master Cerial

Classification and resource types
- Resource item type: `SerialConnectionPort` (concept: ResourceItemType). Create via installer; reuse for all COM ports.
- Classifications (concepts from Activity Master):
  - `ComPort` (ResourceItem)
  - `ComPortNumber`, `ComPortDeviceType`, `ComPortStatus`, `BaudRate`, `BufferSize`, `DataBits`, `StopBits`, `Parity` (ResourceItemXClassification)
  - `ComPortAllowedCharacters`, `ComPortEndOfMessage` (ResourceItemXClassification)
  - Message-related: `SendMessageToComPort`, `Message`, `RawMessage`, `MessageReceivedFromComPort` (EventXClassification)
- Event types: `RegisteredANewConnection`, `ClosedANewConnection`, `SendMessageToComPort`, `Message`, `MessageReceivedFromComPort`.

Installer defaults
- Create types/classifications/event types in `ISystemUpdate` (CerialMasterInstall) using caller-supplied Mutiny session and system token.
- Sequence creation when dependencies exist (e.g., parent classification before child); avoid parallelism where order matters.
- Register system metadata via `IActivityMasterSystem` implementation; ensure sortOrder matches installer task count.

Guice/JPMS wiring
- JPMS module `com.guicedee.activitymaster.cerialmaster`: export service packages; open packages for Guice/Jackson as needed.
- Provide bindings via `IGuiceModule` (private module) and include module names in `IGuiceScanModuleInclusions`.
- Register configurator via `IGuiceConfigurator` to enable classpath/annotation scanning when required by GuicedEE.

Env and runtime
- Align env vars with `rules/generative/platform/secrets-config/env-variables.md`; include DB URL/user/pass, auth endpoints, tracing toggles, test container image, enterprise/system names.
- Do not hardcode COM port values; rely on discovery and persisted classifications.
