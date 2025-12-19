# Events, Sources, and Resources — FullCalendar (JWebMP Wrapper)

Event model
- `FullCalendarEvent` implements `IFullCalendarEvent` with CRTP setters for id/title/allDay/start/end/timezone-sensitive fields; keep ISO-8601 serialization and avoid Java-side timezone conversions.
- Rendering options live in `FullCalendarEventRenderingOptions` (colors, borders, text styles). Maintain parity with upstream names and keep defaults null for sparse payloads.
- Duration: prefer `java.time` types (`LocalDateTime`, `LocalDate`, `Duration`) and avoid string parsing on the client; document any conversions in release notes.

Event sources
- Use `FullCalendarEventSource` for local/static sources and `FullCalendarGoogleCalendarEventSource` for Google Calendar feeds; ensure URLs/ids are validated server-side before exposing to the client.
- Collections: `FullCalendarEventsList` provides list handling; avoid mutating lists after serialization without documenting push/update semantics.
- When adding feed hooks, align to upstream fetch/transform semantics (success/failure callbacks) and surface only JSON-safe fields.

Resources and resource timeline
- Represent resources with `FullCalendarResourceItem` and `FullCalendarResourceItemsList`; keep `id` and `title` mandatory when enabling resource timeline views.
- Resource area columns: use `FullCalendarResourceAreaColumn` to define headers/fields; prefer string fields over raw HTML. If HTML is required, document the didMount hook in Angular integration.
- Resource event linkage: populate `FullCalendarEventResourceInfo` for events bound to resources; ensure resource IDs map to defined items and validate in tests.

Business rules and consistency
- Enforce deterministic IDs for events/resources to keep Angular diffing predictable.
- Avoid mixing recurring event shortcuts with ad-hoc resources unless documented; prefer explicit events for predictable JSON structure.
- Keep Google Calendar and other remote feeds optional; default to local event sources to simplify testing.
