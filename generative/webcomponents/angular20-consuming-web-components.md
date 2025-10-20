# Angular 20 → Consuming Web Components (Modular Overview)

Use this entry when the goal is to use existing Web Components in an Angular 20 application.

## Quick start
- Ensure the Custom Element module is loaded (via ESM import or script tag).
- Use the custom element tag in Angular templates like any HTML element.
- Bind with standard attributes and handle events with `(event)`.

### Minimal pattern
```typescript
// main.ts (ensure element is defined before template render)
import 'my-elements/my-widget.js';
```

```html
<!-- any.component.html -->
<my-widget attr1="value" (clicked)="onClicked($event)"></my-widget>
```

## Guidance
- Prefer attribute strings and boolean presence for simple inputs.
- For complex data, set properties in code (e.g., `@ViewChild` then `el.myObj = {...}`).
- Use `CustomEvent` names as provided by the component; document event contracts.
- Avoid Angular forms bindings unless the element explicitly supports them.

## Further reading
- Angular 20 Overview — ./angular20-overview.md
- Producing Web Components — ./angular20-producing-web-components.md
- Micro Frontends Overview — ./microfronts-overview.md
