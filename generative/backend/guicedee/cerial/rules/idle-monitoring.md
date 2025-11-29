# Idle Monitoring & Vert.x Timers — Cerial

Purpose
- Define how `CerialIdleMonitor` uses Vert.x timers to detect inactivity and update connection state safely.

Requirements
- Vert.x access: obtain `Vertx` via `IGuiceContext.get(Vertx.class)`; never block event loops. Use `setPeriodic`/`cancelTimer` with lightweight checks.
- Logic: compute elapsed time since `lastMessageTime`; transition `ComPortStatus` (e.g., Online → Silent/Offline) and emit through `ComPortEvents`.
- Cleanup: ensure timers are canceled during shutdown (`IGuicePreDestroy`) and when connections close.
- Observability: log transitions with port identifiers; emit structured events for telemetry consumers.
- Configurability: expose thresholds via CRTP setters or configuration so host apps can tune idle intervals.

Examples (outline)
- Timer setup: `vertx.setPeriodic(idleIntervalMs, id -> evaluateIdle(connection, events));`
- Cleanup: `vertx.cancelTimer(timerId); connection.disconnect();`

See also
- Data listeners — ./data-listeners.md
- Lifecycle rules — ./lifecycle.md
- Observability guidance — ../../logging/README.md (logging), ../../platform/observability/README.md (telemetry)
