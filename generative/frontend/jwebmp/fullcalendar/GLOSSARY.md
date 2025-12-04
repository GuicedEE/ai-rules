# Glossary — FullCalendar (JWebMP Wrapper)

Precedence and usage
- Topic-first: load after base glossaries for JWebMP core/client/typescript/angular, Angular language (base + 20), and TypeScript. Avoid duplicating definitions in host projects; link here.
- Prompt language alignment: use upstream view/option strings (e.g., `dayGridMonth`, `timeGridWeek`, `resourceTimelineDay`) and CRTP setter terminology; avoid inventing aliases.

Terms

**FullCalendar 6.1.19 Alignment**
- Version lock to 6.1.19 with Angular plugin 12-20; no back-compat stubs for prior versions.
- Option naming mirrors upstream JSON contract; string-based views only.

**CRTP Fluent Models**
- `FullCalendarOptions`: root JSON contract containing view/time/locale/toolbar/resource/event settings; setters return `(J) this`.
- `FullCalendarEvent` + `IFullCalendarEvent`: event payload with id/title/allDay/start/end, rendering options, extended props.
- `FullCalendarEventSource`: local/remote feed definition (URL, method, headers); `FullCalendarGoogleCalendarEventSource` for Google feeds.
- `FullCalendarBusinessHours`, `FullCalendarVisibleRange`, `FullCalendarTimeSlot`: reusable structs for schedules and slot sizing.

**Views and Layout**
- `initialView`: string view name (e.g., `dayGridMonth`, `timeGridWeek`, `listWeek`, `resourceTimelineDay`).
- `headerToolbar`/`footerToolbar`: button layout definitions; use text/icon maps instead of inline HTML.
- `timeZone`: IANA timezone string; `now`: server-defined reference time for deterministic rendering.
- `locale` / `locales`: single vs bundled locale definitions; `direction`: `ltr` or `rtl`.

**Resources and Timeline**
- `FullCalendarResourceItem` / `FullCalendarResourceItemsList`: resource catalog with deterministic ids and titles.
- `FullCalendarResourceAreaColumn`: resource area column definitions; prefer plain text headers and fields.
- `FullCalendarEventResourceInfo`: linkage between events and resources (ids and titles only).

**Templates and Hooks**
- `NgTemplateSlot` / `NgTemplateElement`: helper types for declaring Angular template slots from Java; use when HTML is unavoidable.
- `resourceAreaHeaderDidMount` / `eventDidMount`: client-side hooks; provide data only, not raw JS strings.

**Testing and Determinism**
- Freeze time via `now` and deterministic IDs for golden JSON tests.
- BrowserStack usage limited to cross-browser FullCalendar rendering validation.

See also
- Topic index — ./README.md
- JWebMP client glossary — ../client/GLOSSARY.md
- Angular glossary and version override — ../../../language/angular/GLOSSARY.md, ../../../language/angular/angular-20.rules.md
- TypeScript glossary — ../../../language/typescript/GLOSSARY.md
