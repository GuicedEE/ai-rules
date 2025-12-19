# Lifecycle and Orchestration Rules (Cerial Master Client)

Scope
- Applies to `TimedComPortSender` (per-port) and `MultiTimedComPortSender` (multi-port aggregation) in `com.guicedee.activitymaster.cerialmaster.client`.

Entrypoints and queues
- Use `TimedComPortSender.enqueue`/group APIs for per-port work; priority queue items run before group queues. Maintain FIFO within group queues.
- `MultiTimedComPortSender` manages a map of senders by COM port; always acquire senders through the manager to keep registry state consistent.
- Call `MessageSpec.generateId()` before enqueueing when the caller did not supply an id; keep `friendlyName` non-blank for telemetry readability.

Retry and attempt coordination
- Attempts are driven by the scheduler inside `TimedComPortSender` using `Config.assignedRetry`, `assignedDelayMs`, and `assignedTimeoutMs`. Time computations stay in UTC; reuse `TimedComPortSender.toOffset(...)` for conversion to `OffsetDateTime`.
- Use `setBeforeStartConfig` on the manager to transform configs per message right before starting; guard against null returns (the engine already preserves the original config).
- Keep `AttemptFn` idempotent; it should return `CompletionStage<Boolean>` indicating success/failure without mutating shared state outside telemetry/snapshots.

Pause/cancel/idle handling
- Pause/resume/cancel operations propagate to all active senders when invoked on the manager. Ensure callers subscribe to `StatusUpdate` to observe terminalization.
- Idle timeout defaults to 120_000 ms; override via Guice named bindings `cerialmaster.manager.idleAfterMs` (millis) or `cerialmaster.manager.idleAfterMinutes` (minutes). Idle triggers reset of group state and aggregate snapshots.
- Track `lastRunFinishedAtEpochMs` to suppress premature idle transitions; update it only after all per-port groups are terminal.

Group coordination
- `setGroupName` assigns the run label and triggers manager-level status emission. Update group name before enqueueing batches so telemetry is consistent.
- `ManagerSnapshot.from(manager, waitingLimit, completedLimit)` produces a safe, limited snapshot; prefer this helper when exposing state externally.

State guards
- Maintain atomic flags to avoid duplicate terminalization (`StateGuard` patterns in `TimedComPortSender`). Do not bypass these guards when adding new states.
- When updating attempt maps, prefer `ConcurrentHashMap` operations and avoid synchronized blocks that can delay scheduler tasks.

Publishing
- Vert.x publishing is gated by `setPublishingEnabled`; status updates continue internally even when publishing is disabled. Always include `%d` in sender publish patterns to avoid topic collisions.
