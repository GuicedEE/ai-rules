# Angular 20 Web Components in Micro Frontends (Modular Overview)

Start here for a concise guide to combining Angular 20, Web Components, and Micro Frontend architecture. Use this when prompts reference shell apps, module federation, or cross-team integration via custom elements.

## Key ideas
- Each team owns a micro frontend that can expose UI as Web Components.
- A shell coordinates loading and composition; components remain framework-agnostic at integration boundaries.
- Prefer domain-aligned decomposition and independent deployment.

## Quick checklist
- Expose stable, versioned custom elements from each micro frontend.
- Load via ESM; coordinate routes/events via well-defined contracts.
- Isolate styles with Shadow DOM; expose parts for theming when needed.
- Health, logging, and error boundaries at the shell and micro levels.

## Further reading
- Angular 20 Overview — ./angular20-overview.md
- Producing Web Components — ./angular20-producing-web-components.md
- Consuming Web Components — ./angular20-consuming-web-components.md
