# Cerial Master Client Glossary

Glossary precedence
- Topic-first: this file defines Cerial-specific terms. Defer to `../GLOSSARY.md` for shared Activity Master vocabulary and only add host-level terms when they are not defined here.
- LLM guidance: keep COM port, telemetry, and snapshot names intact when prompting; do not rename DTOs or event types.

Terms
- **TimedComPortSender** — Per-port retry scheduler that handles priority and group queues, runs `AttemptFn` send logic, and emits telemetry (`StatusUpdate`, `MessageProgress`, `SenderSnapshot`). CRTP setters return `(J)this`; do not wrap with Lombok `@Builder`.
- **MultiTimedComPortSender** — Multi-port manager that coordinates multiple `TimedComPortSender` instances, aggregates failures, enforces idle timeouts, and publishes manager-level snapshots/events. Publishing defaults: aggregate address `server-task-updates`, per-sender pattern `sender-%d-tasks` with `%d` placeholder.
- **Config** — Per-message/per-sender configuration: default retries=3, delayMs=2800, timeoutMs=3000, `alwaysWaitFullTimeoutAfterSend=false`, `alwaysSucceed=false`. Suppliers may override payload per attempt.
- **MessageSpec** — DTO describing a message payload plus suppliers to regenerate payloads per attempt. `generateId()` and `generateMessage(int attempt)` guard defaults and blanks.
- **MessageProgress / MessageResult** — Telemetry DTOs for in-flight and terminal state; include effective/default config snapshots and attempt counts.
- **SenderSnapshot / ManagerSnapshot / AggregateProgress** — Snapshot DTOs for per-sender and aggregate progress, including UTC offsets derived via `toOffset(...)`. Preserve timestamp fields and roll-up flags (`anyWaitingForResponse`, `anyErrored`).
- **ComPortConnection** — Registry-backed connection wrapper over `com.guicedee.cerial` drivers with GuicedEE service loader hooks (`IReceiveMessage`, `IErrorReceiveMessage`, `IComPortStatusChanged`). Access via `getOrCreate` to reuse the canonical instance per COM port.
- **AttemptFn** — Attempt coordinator function that executes a send via `ComPortConnection`, interprets `CompletionStage<Boolean>`, and feeds scheduler/telemetry logic. Keep it idempotent and side-effect safe.
- **PublishingEnabled** — Global toggle on `MultiTimedComPortSender` that gates Vert.x publishing; telemetry callbacks still fire regardless of this flag.
