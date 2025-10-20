# Angular 20 + Web Components (Modular Overview)

Start here for a high-level understanding of building and using Web Components with Angular 20. This is a concise entry optimized for generative AI. The full guide remains available as a deep dive.

## When to use
- You need to expose Angular components as Custom Elements for cross-framework/vanilla HTML use.
- You need to consume existing Web Components inside Angular 20 apps.

## Key points
- Angular components can be wrapped/exposed as Web Components.
- Prefer standard inputs/outputs mapping to attributes/events when exposing.
- Keep bundles as ESM; lazy-load where appropriate.

## Produce vs Consume
- Producing: expose an Angular component as a Custom Element; register once on app bootstrap.
- Consuming: import or load the element module; use the custom tag directly in templates.

## Further reading
- Producing Web Components — ./angular20-producing-web-components.md
- Consuming Web Components — ./angular20-consuming-web-components.md
- Micro Frontends Overview — ./microfronts-overview.md
