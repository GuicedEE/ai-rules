# Angular 20 — Modular Rules (Override of base angular.md)

Purpose
- Provide concise, version‑specific rules for Angular 20 layered on top of ./angular.md. Capture only Angular 20 deltas to avoid duplication.

How to use
- Apply ./angular.md (base) first, then these Angular 20 overrides.
- For TypeScript posture and Web Components interop, route to their topic glossaries/rules.

Quick start (CLI)
```bash
# New Angular 20 workspace
ng new my-app --standalone --routing --style=scss
cd my-app
# Add SSR/hydration (recommended)
ng add @angular/ssr
```

Key deltas vs base

1) Signals‑first and optimized hydration
- Prefer signals/computed/effect for local state and derivations; ensure templates are deterministic for hydration fidelity.
- Hydration improvements (zero/low flicker) are expected; design with stable keys/ids and pure bindings.

2) SSR/hydration defaults
- Use server rendering and the latest hydration providers for best UX:
```ts
import { provideClientHydration, withHttpTransferCache } from '@angular/platform-browser';
import { provideRouter, withViewTransitions, withComponentInputBinding } from '@angular/router';

export const appConfig: ApplicationConfig = {
  providers: [
    provideClientHydration(withHttpTransferCache()),
    provideRouter(routes, withComponentInputBinding(), withViewTransitions())
  ]
};
```
- Keep render/init side‑effect free; avoid DOM reads/writes in constructors; use effects or lifecycle hooks safely post‑render.

3) Control flow and defer loading (refinements)
- Use control‑flow blocks (if/for/switch) and refined @defer strategies:
```html
@defer (on viewport; prefetch: true) { <heavy-comp/> }
  @loading (minimum: 300ms) { <skeleton/> }
  @error { <error-ui/> }
  @placeholder { <placeholder/> }
```
- Prefer @for with signal data sources and stable track keys.

4) DI and functional routing at scale
- Use provide* APIs at app/bootstrap or route‑level providers for tree‑shakable DI.
- Prefer functional routing with lazy standalone components via loadComponent.

5) State strategy
- Keep local state in signals; for cross‑cutting state, select one strategy (signals‑based services or NgRx with modern providers). Avoid hybrid sprawl.
- Use toObservable/toSignal interop only at boundaries.

6) Zones and change detection
- Prefer zoneless where libraries allow; signals reduce the need for Zone.js. Audit third‑party dependencies before switching.

7) Testing and performance
- Test with TestBed + standalone imports; favor Testing Library patterns.
- Audit hydration with realistic data; instrument TTI/INP and verify transfer cache impacts.

Migration (19 → 20)
- Update CLI/Core to 20; re‑validate hydration and @defer usage with new defaults.
- Ensure @for keys stable; migrate any legacy patterns (modules, *ngIf/*ngFor) in new code to modern blocks.
- Revisit SSR configuration and provider flags to enable newer router/hydration features.

Anti‑patterns
- Mixing legacy template directives with modern control flow in new features.
- Side‑effects at render that break hydration (DOM reads/writes, timers, global event listeners).
- Overuse of global stores when signals‑based local state suffices.

Prompt alignment
- When Angular 20 is selected:
  - Apply ./angular.md + this file.
  - Generate standalone components, functional routing, signals‑first state, and refined @defer usage.
  - Configure SSR/hydration with transfer cache and router features.
  - Keep TS strict‑first per ../typescript/GLOSSARY.md; align with Web Components interop guidance.

See also
- Base rules — ./angular.md
- Glossary — ./GLOSSARY.md
- Angular 17 rules — ./angular-17.rules.md
- Angular 19 rules — ./angular-19.rules.md
- TypeScript glossary — ../typescript/GLOSSARY.md
- Web Components — ../../frontend/webcomponents/README.md