# Configuration and Publishing Rules (Cerial Master Client)

Defaults and validation
- `Config` defaults: retries=3, delayMs=2800, timeoutMs=3000, `alwaysWaitFullTimeoutAfterSend=false`, `alwaysSucceed=false`. Negative values throw `IllegalArgumentException`; validate caller inputs before constructing configs.
- Always keep time math in milliseconds and convert to UTC with `TimedComPortSender.toOffset(...)` when exposing timestamps.
- Per-message config overrides: attach via `MessageSpec.config`; use `setBeforeStartConfig` on `MultiTimedComPortSender` to adjust configs at runtime.

Timeout/pause semantics
- `alwaysWaitFullTimeoutAfterSend`: when true, the sender waits the full timeout even if the send completes early. Use for hardware that needs fixed pacing.
- `alwaysSucceed`: when true, the message is marked successful after `(assignedRetry x assignedDelayMs) + assignedTimeoutMs` even without explicit success. Use sparingly; document when setting this flag.
- Idle timeout: defaults to 120_000 ms. Override via Guice named bindings `cerialmaster.manager.idleAfterMs` (milliseconds) or `cerialmaster.manager.idleAfterMinutes` (minutes). The manager caches the first resolved value.

Publishing (Vert.x)
- Aggregate publish address defaults to `server-task-updates`. Update via `setAggregatePublishAddress(String)` with non-blank input.
- Per-sender publish pattern defaults to `sender-%d-tasks`. The pattern must include `%d`; `setSenderPublishPattern` enforces this or throws `IllegalArgumentException`.
- Global publishing toggle: `setPublishingEnabled(boolean)` disables Vert.x publishing while leaving internal telemetry callbacks intact. Consumers should still subscribe to in-process `Multi` streams.

Payload suppliers
- `MessageSpec` supports `Supplier<String>` and `IntFunction<String>` for dynamic payload generation. Attempt-aware suppliers take precedence; null returns keep the previous payload. Avoid expensive supplier work; they run on every attempt.
- When payloads are blank after supplier evaluation, the sender transmits an empty payload to avoid leaking identifiers; do not fall back to title/id.

Registry usage
- Always obtain `ComPortConnection` via `getOrCreate` to reuse registry instances keyed by COM port and keep `TIMED_SENDERS` consistent.
- When setting COM port status, prefer the provided setters; status changes coalesce `Idle` to `Silent` to avoid semantic drift across driver versions.
