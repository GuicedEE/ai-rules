# FullCalendar Pro Glossary (Topic-First)

## LLM Interpretation Guidance
- This topic glossary is authoritative for FullCalendar Pro; when prompting, prefer the exact terms below (e.g., resource timeline, Pro template slots, WebSocket listener) and link back to this file for rationale before copying any definition into a host glossary.
- Each term references the architecture artifacts (`docs/architecture/c4-component-fullcalendar-pro.md`, `docs/architecture/sequence-runtime-wiring.md`) and the host implementation (`FullCalendarPro.java`, `InitialResourceEventsReceiver`, `FullCalendarProPageConfigurator`).

## Terms
- **FullCalendar Pro** — The premium extension of FullCalendar 6.1.19 that activates resourceDayGrid, resourceTimeGrid, resourceTimeline, and adaptive plugins via the JWebMP wrapper. All code and documentation should point to this glossary before referencing the term elsewhere.
- **Resource Timeline** — The scheduler-style view that places resources on the vertical axis and time on the horizontal axis; if you mention the view in prompts, state it as “resource timeline” and tie it to the `resourceTimelinePlugin` import in `FullCalendarPro`.
- **Resource Template Hooks** — The optional template slots (`resourceLabel`, `resourceAreaHeader`, `resourceAreaColumn`) that `FullCalendarPro` can emit through `NgTemplateElement` when the `enable...Template` flags are true; these map directly to the CSS classes `.fc-resource-label`, `.fc-resource-area-header`, and `.fc-resource-col-cell` described in the architecture diagrams.
- **InitialResourceEventsReceiver** — The GuicedEE WebSocket receiver that listens on `listenerName + 'Resources'`, recreates the action class via reflection, and calls `getInitialResources()` before sending the `FullCalendarResourceItemsList` back over the event bus.
- **Pro Resource Channels** — The trio of WebSocket event names (`listenerName + 'Options'`, `listenerName + 'Resources'`, and the base `listenerName`) used by `FullCalendarPro.fetchData()` to serialize options, resources, and events; mention them when discussing event wiring or testing to make sure LLMs do not invent alternative channel names.
