# Options, Layout, and Localization — FullCalendar (JWebMP Wrapper)

Contract and serialization
- Use `FullCalendarOptions` as the single JSON contract; keep field names aligned to upstream FullCalendar 6.1.19 (string-based views like `dayGridMonth`, `timeGridWeek`, `resourceTimelineDay`).
- Prefer CRTP setters that keep defaults null unless the upstream API requires explicit booleans (e.g., `stickyHeaderDates`, `slotLabelDidMount` hooks). Do not inline HTML in Java; rely on NgTemplate helpers when HTML is unavoidable.
- When adding options, include Jackson annotations consistent with peers and avoid exposing getters that mutate serialization shape.

Views, layout, and sizing
- Views: configure via `setInitialView(String)` and add custom views under `options/views/` using `FullCalendarView` and `FullCalendarDefaultViews` helpers; keep custom durations/types consistent with upstream `type` strings.
- Layout: manage toolbars with `FullCalendarHeaderToolBarOptions`; prefer text/icon maps instead of raw HTML for buttons. Ensure `height`, `contentHeight`, `aspectRatio`, and `stickyHeaderDates` follow upstream defaults and respect responsive recalculations.
- Day headers and slots: use `FullCalendarTimeSlot` for slot duration/labeling; guard against conflicting slot settings (e.g., `slotDuration` vs `slotLabelInterval`). For timeline, set multi-tier headers via arrays rather than HTML.

Localization and time handling
- Timezone: set `timeZone` as an IANA string; avoid legacy local/UTC flags. Provide `now` for deterministic testing.
- Locale: prefer `locale` for a single locale and `locales` array for multi-locale bundles; ensure language packs are delivered via the page configurator.
- Direction and formatting: use `direction` (ltr/rtl) per upstream strings; keep date/time formatting hooks consistent with Angular client expectations.

Business hours and visibility windows
- Use `FullCalendarBusinessHours` for recurring availability; keep `dow` aligned to 0-6 integers. Avoid mixing business hours and explicit events without documenting precedence.
- Apply `FullCalendarVisibleRange` for bounded navigation; align with `validRange` and disable prev/next buttons when outside bounds.
- Slot constraints: ensure `slotDuration`, `slotMinTime`, and `slotMaxTime` are coherent; document defaults in release notes when changing.
