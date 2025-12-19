# Angular Integration — FullCalendar Pro

## Overview
Angular is the primary delivery surface for FullCalendar Pro. The wrapper wires `@fullcalendar/resource-*` plugins via `@NgImportReference`, registers `@ViewChild` template refs, subscribes to the generated `eventBusService`, and exposes template slots for resource labels, headers, and columns. Follow the Angular 20 rules (`rules/generative/language/angular/angular-20.rules.md`) and treat the generated TypeScript as read-only; all changes happen in the Java source that drives the generator.

## Usage Patterns & Minimal Example
1. Annotate the Pro component with `@NgImportReference` for each premium plugin and `@ViewChild` editors for template references (`resourceAreaColumnHeaderTpl`, `resourceAreaColumnCellTpl`).
2. Add `NgTemplateElement`s inside `FullCalendarPro.init()` only when the corresponding `enable...Template` flag is true so the generated template is lean.
3. Use the generated `initializeResources()`, `handleResourceEvents()`, and `applyResourceAreaTemplates()` methods to coordinate template refs, event bus subscriptions, and `calendarOptions.resourceAreaColumns` assignments.

```typescript
const resourcesObserver = {
  next: (data: any) => this.handleResourceEvents(data),
  error: (err: any) => console.error('Resources listener failed', err)
};
this.subscriptionResources = this.eventBusService
  .listen(this.listenerName + 'Resources', this.handlerResourcesId)
  .subscribe(resourcesObserver);
```

## Inputs / Outputs / Events
- The Angular class listens on `listenerName + 'Resources'` with a handler ID generated in the constructor. The same ID is reused when unsubscribing inside `ngOnDestroy()` to avoid memory leaks.
- `handleResourceEvents()` gracefully handles both stringified JSON payloads and direct object arrays; it updates `calendarOptions.resources` so the event bus and template bindings remain in sync.
- `applyResourceAreaTemplates()` binds the template refs to `resourceAreaColumns`, letting Angular render custom column headers and cells without mutating the underlying calendar DOM.

## Styling & Theming
- Template markup (labels, headers, column cells) uses classes such as `.fc-tpl`, `.fc-resource-label`, `.fc-resource-area-header`, and `.fc-resource-col-cell`; keep new styling in CSS files referenced by `IMPLEMENTATION.md` so the architecture diagrams capture the DOM nodes.

## Accessibility / Performance Constraints
- Each `Subscription` must be torn down in `ngOnDestroy()`; the generated `this.subscriptionResources?.unsubscribe()` call ensures the Angular zone releases the observer.
- Avoid inline templates that render heavy loops—templates render per resource row, so keeping them lightweight prevents jank during scrolling.

## See also
- `rules/generative/frontend/jwebmp/fullcalendar-pro/events-and-resources.rules.md`
- Architecture: `docs/architecture/sequence-runtime-wiring.md`, `docs/architecture/c4-component-fullcalendar-pro.md`
- TypeScript client metadata: `../../../typescript/README.md`
