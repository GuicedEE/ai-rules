# Testing and Validation — FullCalendar (JWebMP Wrapper)

General policy
- Documentation-first with forward-only changes; record coverage and risks in Pact/Implementation before code edits.
- Use Java 25 toolchain; enforce CRTP contracts with unit tests and Jacoco coverage thresholds aligned to platform testing rules.

Server-side tests
- Validate serialization of `FullCalendarOptions`, events, resources, and business hours with golden JSON snapshots (stable ordering, deterministic IDs).
- Add nullness-focused tests to guard JSpecify expectations and prevent widening nullable surfaces.
- Prefer Java Micro Harness for fast component tests; avoid slow integration tests unless reproducing a regression.

Client/Angular checks
- Align with Angular 20 testing guidance (Karma/Jest per project rules). Mock plugin imports (`@fullcalendar/daygrid`, `timegrid`, `interaction`, `resource-timeline`) and assert bindings for key options (initialView, locale, timeZone).
- Use BrowserStack only for cross-browser validation of rendering/layout; keep suites minimal and gated behind CI secrets.

Regression and compatibility
- When adding new options or hooks, extend test fixtures for view names, toolbar configuration, and resource timelines. Document any changed defaults in `./release-notes.md`.
- Avoid adding flaky time-dependent tests; fix time via `now` option and frozen clocks.
