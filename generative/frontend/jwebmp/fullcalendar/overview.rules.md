# Overview — FullCalendar (JWebMP Wrapper)

Purpose and scope
- Wrapper for FullCalendar 6.1.19 with the official Angular plugin, hosted through JWebMP Core/Client/TypeScript/Angular 20 on Java 25 LTS.
- Documentation-first with Specification-Driven Design and forward-only change policy; stage gates auto-approved (blanket) but recorded in Pact/Guides/Implementation.
- Generated Angular/TypeScript bundles remain read-only; mutate Java CRTP models only.

Architecture anchors
- Components: `FullCalendar` widget, `FullCalendarOptions` JSON contract, `FullCalendarEvent`/`FullCalendarEventSource`, resources (resource timeline support), business hours/visible range/time slots, NgTemplate helpers for slots.
- Integration: `FullCalendarPageConfigurator` wires scripts/styles and npm dependencies for Angular builds; module exports defined in `module-info.java`.
- Data flow: Jackson serializes options/events/resources to JSON for Angular’s `<full-calendar [options]>` binding; async updates flow over JWebMP client channels when used with GuicedEE client.
- Diagrams: reference `../../../../../docs/architecture/README.md` plus context/container/component and sequence files before altering flows.

Fluent API and coding constraints
- CRTP fluent setters only; no Lombok builders. Return `(J) this` for chained setters and apply `@SuppressWarnings("unchecked")` when needed.
- Logging: Log4j2 only. Follow backend logging rules when adding diagnostics.
- Nullness: honor JSpecify annotations already present; avoid widening nullable surfaces without documenting in rules and glossary.

Versioning and compatibility
- Locked to FullCalendar 6.1.19 (Angular 12-20 alignment). Avoid back-compat stubs; document removals in release-notes.
- Time, locale, and view names must match upstream FullCalendar strings (e.g., `timeGridWeek`, `dayGridMonth`, `resourceTimelineDay`).
