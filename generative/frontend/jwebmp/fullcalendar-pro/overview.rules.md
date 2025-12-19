# Overview — FullCalendar Pro Wrapper

## Overview & Purpose
The `FullCalendarPro` base class extends the standard wrapper by enabling the Pro resource/timeline plugins, template hooks, and WebSocket-backed resource delivery. It keeps the CRTP setters inherited from `FullCalendar` (`FullCalendarPro<J extends FullCalendarPro<J>>`) and wires each Pro widget into the GuicedEE runtime via `InitialResourceEventsReceiver`, `FullCalendarProPageConfigurator`, and the service descriptors listed in `IMPLEMENTATION.md`.

## Usage Patterns & Minimal Example
1. Create a concrete subclass of `FullCalendarPro` inside the host module and override `getInitialResources()` to return a `FullCalendarResourceItemsList` of the resource timeline rows you need.
2. Enable the desired template flags (`setEnableResourceLabelTemplate`, `setEnableResourceAreaHeaderTemplate`, `setEnableResourceAreaColumnTemplates`) before the component renders, or call `enableAllProTemplates()` for full template coverage.
3. Use the `fetchData()` override to request both options and resource sets from the GuicedEE event bus before rendering and let `handleResourceEvents()` feed the Angular options object with the returned arrays.

```java
public class MyProCalendar extends FullCalendarPro<MyProCalendar> {
    public MyProCalendar() {
        super("pro-calendar");
        enableAllProTemplates();
    }

    @Override
    public FullCalendarResourceItemsList getInitialResources() {
        FullCalendarResourceItemsList resources = new FullCalendarResourceItemsList();
        resources.add(FullCalendarResource.create("r1").withTitle("Team A"));
        return resources;
    }
}
```

## Inputs / Outputs / Events
- `getInitialResources()` feeds the event bus receiver (`InitialResourceEventsReceiver`) that responds to the `listenerName + 'Resources'` WebSocket channel.
- The Angular client listens for both `listenerName + 'Options'` and `listenerName + 'Resources'`, so the server must send the class name, listener name, and serialized payload before FullCalendar renders.
- Resource templates (label/header/columns) emit markup with `.fc-tpl` CSS hooks, ensuring they reuse the same accessibility semantics as the base widget.

## Styling & Theming
- Avoid inline string HTML in Java; use `NgTemplateElement` helpers to emit template fragments (e.g., `resourceAreaColumnHeader` content) and rely on `.fc-resource-*` classes to stay consistent with FullCalendar’s theming.
- Document any CSS overrides inside `docs/architecture` or `IMPLEMENTATION.md` so designers know how the templates tie back to the architecture diagrams.

## Accessibility / Performance Constraints
- Templates should include `aria` attributes or semantic tags inside the `NgTemplateElement` fragments to keep the rows navigable; avoid anonymous spans containing only icons.
- Keep resource counts manageable (do not load thousands of rows unless the host configuration paginates via the `FullCalendarResourceItemsList`) because the Angular event bus serializes each resource list before the calendar renders.

## See also
- `rules/generative/frontend/jwebmp/fullcalendar-pro/options-and-layout.rules.md`
- `rules/generative/frontend/jwebmp/fullcalendar-pro/events-and-resources.rules.md`
- Architecture: `docs/architecture/c4-component-fullcalendar-pro.md`, `docs/architecture/sequence-runtime-wiring.md`
- Glossary & prompt alignment: `./GLOSSARY.md`
