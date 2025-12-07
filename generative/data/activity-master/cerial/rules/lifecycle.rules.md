# Lifecycle Rules — Activity Master Cerial

System registration
- Implement `IActivityMasterSystem` to register the CerialMaster system name/description and expose sort order; use caller Mutiny session.
- Provide `ISystemUpdate` to create types/classifications/event types and progress logging; respect sort order/taskCount annotations.

Startup and post-startup
- Post-startup hooks should validate system presence and configuration, not re-install types. Keep operations non-blocking and idempotent.
- Defaults belong in the installer; reserve post-startup for validation/telemetry.

COM port lifecycle
- `addOrUpdateConnection` creates resource items and applies classifications; ensure a deterministic chain of classification writes to avoid race conditions.
- `updateStatus` must retrieve the resource item via classification lookup to avoid stale IDs.
- Timed senders should not auto-start for scanner-type ports; allow callers to trigger start.
- Cache of discovered ports may be reused across calls; document refresh expectations.

SPI and service exposure
- Provide Guice bindings via a private module exposing generic `ICerialMasterService<?>` and concrete type; ensure META-INF/services entries mirror JPMS provides.
- Inclusion module must list both `com.guicedee.activitymaster.cerialmaster` and client packages to enable scanning.

Logging and telemetry
- Use Log4j2 with Lombok `@Log4j2`; include port/system identifiers in trace/debug messages.
- Log failures with error and include exception; avoid swallowing Mutiny failures.
