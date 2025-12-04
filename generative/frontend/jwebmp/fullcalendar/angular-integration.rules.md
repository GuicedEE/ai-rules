# Angular Bridge and Data Flow — FullCalendar (JWebMP Wrapper)

Angular plugin alignment
- Target Angular 20 with `@fullcalendar/angular`; match FullCalendar 6.1.19 option names and view identifiers. Keep generated Angular artifacts read-only.
- Use `FullCalendarPageConfigurator` to register scripts/styles/npm deps; avoid hardcoding asset URLs elsewhere. Ensure module-info exports stay in sync.
- When emitting options to Angular, serialize with Jackson and bind via `<full-calendar [options]="calendarOptions">`; keep `plugins` array selection in the Angular layer, not in Java options.

Templates and hooks
- Avoid inline HTML in Java; prefer Angular templates or `NgTemplateSlot`/`NgTemplateElement` for unavoidable markup. When using `resourceAreaHeaderDidMount` or similar hooks, document the HTML/string mutual exclusivity.
- For callbacks (dateClick, eventClick, eventDidMount), expose data via JSON-safe payloads and define TypeScript handlers in the Angular consumer; do not embed raw JavaScript strings.

Data exchange and updates
- Default flow: server computes `FullCalendarOptions` and events, serialized once; client augments with plugin imports and callbacks.
- Live updates: if using JWebMP client channels, publish deterministic payloads keyed by event/resource ids; avoid partial updates that break Angular change detection.
- Timezone and locale fields must be populated server-side; do not rely on browser defaults.

Validation and evidence
- Cross-check integration changes against `../../../../../docs/architecture/sequence-*.md` and component diagrams before updating rules.
- Keep CI and local builds aligned with Angular 20 toolchain; document npm peer requirements in release-notes when they shift.
