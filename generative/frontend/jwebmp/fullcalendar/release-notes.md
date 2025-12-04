# Release and Migration Notes — FullCalendar (JWebMP Wrapper)

Status
- Forward-only rules set aligned to FullCalendar 6.1.19 and Angular 20 plugin; stage gates auto-approved (blanket).
- This file tracks rule-level changes and breaking documentation shifts; use project-level release notes for code releases.

Current change (December 2025)
- Added modular rules for FullCalendar under `rules/generative/frontend/jwebmp/fullcalendar` (overview, options/layout, events/resources, Angular integration, testing, glossary).
- Reinforced CRTP-only fluent API, Log4j2 logging, Java 25 LTS, JSpecify nullness, and read-only Angular artifacts.
- Locked view/option naming to upstream strings; clarified timezone/locale handling and resource timeline expectations.

Migration guidance
- Replace any legacy view objects with string-based `initialView` values.
- Remove inline JavaScript/HTML injections; use NgTemplate helpers or Angular templates.
- Ensure event/resource IDs are deterministic to support client-side diffing; update tests accordingly.
