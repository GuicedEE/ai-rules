# Options and Layout — FullCalendar Pro

## Overview
FullCalendar Pro surfaces the advanced layout options (resource day grid/time grid/timeline, adaptive resizing, and resource area columns) from the Pro plugins while reusing the CRTP-style option setters inherited from `FullCalendar`. Options are delivered through `FullCalendarPro.fetchData()` and serialized into the Angular `calendarOptions` object before the calendar API renders.

## Usage Patterns & Minimal Example
- Enable the Pro plugins by default (resourceDayGrid, resourceTimeGrid, resourceTimeline, adaptive) and then update the `calendarOptions` payload inside `fetchData()` to include the desired `initialView`, `schedulerLicenseKey`, and view-specific fields such as `resources`, `slotDuration`, or `visibleRange`.
- Configure column templates via `setEnableResourceAreaColumnTemplates(true)` and provide `resourceAreaColumnHeaderTpl`/`resourceAreaColumnCellTpl` in Angular to bind custom columns to the `resourceAreaColumns` array.

```ts
this.calendarOptions = {
    ...this.calendarOptions,
    initialView: 'resourceTimeGridDay',
    views: {
        resourceTimeGridDay: {
            dayMaxEvents: 3
        }
    },
    resourceAreaColumns: [
        { field: 'title', headerContent: this.resourceAreaColumnHeaderTpl }
    ]
};
```

## Inputs / Outputs / Events
- `AdditionalOptions` are emitted through the `listenerName + 'Options'` channel (see `fetchData()`), so ensure the payload includes `listenerName`, `className`, and any plugin-specific keys (e.g., `slotDuration`, `visibleRange`).
- Resource templates should expose `let` arguments (e.g., `withLetArg()`) so Angular can read `arg.resource` and `arg.field` when rendering header/cell content.
- Provide `resourceLabelTemplate` and `resourceAreaHeaderTemplate` toggles so the view can opt into accessible label formatting without forcing markup whenever the premium view is inactive.

## Styling & Theming
- Keep CSS under `.fc-resource-*` to align with FullCalendar’s default themes; mention any custom theme tweaks in `IMPLEMENTATION.md` or architecture diagrams.
- Document Pro-specific templates in `docs/architecture/c4-component-fullcalendar-pro.md` so designers understand the template slots that appear in the DOM.

## Accessibility / Performance Constraints
- When adding resource columns, include header text that screen readers can announce (e.g., `{{ arg?.field || 'Column' }}`) and avoid purely decorative icons.
- Resource templates should avoid heavy DOM operations because template rendering occurs for every visible row; keep loops minimal and rely on CSS for emphasis.

## See also
- `rules/generative/frontend/jwebmp/fullcalendar-pro/overview.rules.md`
- Architecture: `docs/architecture/c4-component-fullcalendar-pro.md`, `docs/architecture/sequence-runtime-wiring.md`
- Angular language: `../../../language/angular/README.md`, `../../../language/angular/angular-20.rules.md`
