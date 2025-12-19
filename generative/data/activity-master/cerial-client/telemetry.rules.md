# Telemetry and Snapshots (Cerial Master Client)

Streams
- `TimedComPortSender` publishes `Multi<StatusUpdate>` and `Multi<MessageProgress>`; subscribe early to capture retries, pauses, and terminal states. Backpressure is handled by Mutiny; avoid blocking subscribers.
- Use `onStatisticsUpdated` to register snapshot consumers; callbacks fire regardless of Vert.x publishing settings.

Snapshots
- `SenderSnapshot` includes waiting/sending/completed lists, roll-up flags (`anyErrored`, `anyWaitingForResponse`), and UTC timestamps derived via `TimedComPortSender.toOffset(...)`.
- `ManagerSnapshot` aggregates per-sender snapshots with `AggregateProgress` (percent complete, failures, comPort set, worst-case remaining time). Generate via `ManagerSnapshot.from(manager, waitingLimit, completedLimit)` to avoid unbounded collections.
- `AggregateProgress` timestamps: `startedAtEpochMs`, `finishedAtEpochMs`, `estimatedFinishedAtEpochMs`, and `originallyEstimatedFinishedAtEpochMs` must stay in epoch milliseconds; expose UTC conversions for API consumers.

Status publishing
- Vert.x publishing mirrors internal telemetry: aggregate topic (`server-task-updates` by default) and per-sender topics using `sender-%d-tasks` pattern. Keep `%d` placeholder intact to avoid collisions.
- Publishing toggle: `isPublishingEnabled` gates Vert.x messages; internal telemetry continues. Only disable when downstream Vert.x consumers are untrusted or unavailable.

Notes for downstream consumers
- Provide friendly `title`/`friendlyName` values in `MessageSpec` to keep telemetry readable.
- Treat `alwaysSucceed` messages as terminal even without driver ACKs; monitor `note` fields on `MessageProgress` for context.
- Avoid mixing cross-port state; subscribe to per-sender streams for port-specific dashboards and use aggregate topics for fleet-level monitoring.
