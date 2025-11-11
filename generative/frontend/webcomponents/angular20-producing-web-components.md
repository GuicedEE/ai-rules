# Angular 20 → Producing Web Components (Modular Overview)

Use this entry when the goal is to expose Angular 20 components as Web Components (Custom Elements).

## Quick start
1. Build a standalone Angular component.
2. Wrap or register as a Custom Element at bootstrap.
3. Export as ESM and load in the target host.

### Minimal pattern
```typescript
import { bootstrapApplication } from '@angular/platform-browser';
import { createCustomElement } from '@angular/elements';
import { inject } from '@angular/core';
import { MyWidgetComponent } from './my-widget.component';

export function defineMyWidget() {
  const injector = inject<any>(null as any);
  const MyWidgetEl = createCustomElement(MyWidgetComponent, { injector });
  customElements.define('my-widget', MyWidgetEl);
}

bootstrapApplication(MyWidgetComponent).then(() => defineMyWidget());
```

## Guidance
- Inputs map to attributes/properties; prefer primitives and events for interop.
- Avoid Angular-only patterns in the public contract; keep DOM-facing API standard.
- Use lazy loading for heavy dependencies.

## Further reading
- Angular 20 Overview — ./angular20-overview.md
- Consuming Web Components — ./angular20-consuming-web-components.md
- Micro Frontends Overview — ./microfronts-overview.md
