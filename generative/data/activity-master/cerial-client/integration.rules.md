# Integration Hooks (Cerial Master Client)

GuicedEE services
- `ComPortConnection` loads service implementations via Guice service loader: `IReceiveMessage`, `IErrorReceiveMessage`, and `IComPortStatusChanged`. Implement these as SPI modules and register through GuicedEE; avoid static singletons.
- Always call `ComPortConnection.getOrCreate(comPort, type)` to reuse registry-backed connections and keep `TIMED_SENDERS` aligned.
- Status updates coalesce `ComPortStatus.Idle` into `Silent` to avoid semantic drift across driver versions; do not rely on `Idle` in downstream code.

Driver and hardware integration
- The underlying driver is `com.guicedee.cerial`. Guard against hardware instability by using `alwaysWaitFullTimeoutAfterSend` when ports need deterministic pacing.
- Use `AttemptFn` to encapsulate driver sends; keep it idempotent and avoid leaking COM port state outside the registry.

Vert.x and event publishing
- Use `VertxEventPublisher` to publish aggregate and per-sender updates. Respect `setPublishingEnabled` when consumers are untrusted.
- Keep topic names configurable (`setAggregatePublishAddress`, `setSenderPublishPattern`), ensuring `%d` remains in sender patterns.

Frontend/TypeScript bridge
- DTOs are annotated with `@NgDataType` and implement `INgDataType` so JWebMP TypeScript generation can mirror `Config`, `MessageSpec`, `MessageResult`, `MessageProgress`, `SenderSnapshot`, and `ManagerSnapshot`.
- Keep field names stable to prevent downstream TypeScript API churn; align any changes with glossary updates and release notes.

Logging
- Log retry scheduling, pause/cancel events, and terminal states using Log4j2. Prefer Lombok `@Log4j2` on orchestration components; avoid switching to other logging backends.
