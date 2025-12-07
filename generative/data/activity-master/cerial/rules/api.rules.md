# API Rules — Activity Master Cerial

Scope
- Usage of `ICerialMasterService` and related APIs for COM port registration, lookup, and status updates.

Service patterns
- Always pass a caller-managed Mutiny `Session` and Activity Master system token; do not open sessions internally.
- Use `addOrUpdateConnection(session, ComPortConnection, system, token)` to create/update resource items and apply classifications; ensure `ComPortConnection` contains the hardware port identity from jSerialComm.
- Use `findComPortConnection` or `getComPortConnection` to hydrate classifications into `ComPortConnection` instances; attach timed senders only when needed.
- Use `updateStatus` to adjust ComPortStatus classification; avoid direct classification writes.
- Prefer `listAvailableComPorts(session, enterprise)` to compute available ports (scanned minus registered) instead of reimplementing the diff.

Fluent API and logging
- CRTP fluent strategy only; avoid builders. New fluent setters must return `(J) this` and be nullness-annotated per JSpecify guidance.
- Use Lombok `@Log4j2` on services; keep trace/debug/info/error signals consistent with existing patterns.

SPI exposure
- Expose `ICerialMasterService` via Guice private module and JPMS exports; maintain META-INF/services entries aligned with `module-info.java` provides clauses.
- Keep JPMS exports/opens in sync when adding new packages.

Error handling
- Reject null ComPortConnection or port values early with clear exceptions; log context (port/system) at trace/debug.
- Keep Mutiny chains non-blocking and avoid hardware access inside event-loop contexts except for enumeration and timed sender scheduling.
