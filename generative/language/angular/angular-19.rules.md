# Angular 19 — Modular Rules (Override of base angular.md)

Purpose
- Provide concise, version‑specific rules for Angular 19 that layer on top of ./angular.md. Only 19‑specific deltas are captured to avoid duplication.

How to use
- Apply ./angular.md (base) first, then these overrides for Angular 19.
- For language/tooling posture, align with TypeScript strict‑first (../typescript/GLOSSARY.md) and Web Components interop topics.

Quick start (CLI)
```bash
ng update @angular/cli@19 @angular/core@19   # or new workspace with v19
ng new my-app --standalone --routing --style=scss
cd my-app
ng add @angular/ssr                           # SSR/hydration (recommended)
```

Key deltas vs base

1) Signals (matured API in 19)
- Prefer signals/computed/effect for local state and derivations; use untracked inside effect for non‑reactive reads.
- New ergonomics and cleanup patterns for effect:
```ts
import { signal, computed, effect, untracked } from '@angular/core';
const count = signal(0);
const doubled = computed(() => count() * 2);
effect((onCleanup) => {
  const now = untracked(() => Date.now());
  // …
  onCleanup(() => { /* release resources */ });
});
```

2) Optional Zone.js
- Zone.js is optional; favor zoneless apps when compatible with dependencies.
- Coalescing settings recommended when zoneless:
```ts
bootstrapApplication(AppComponent, {
  providers: [/* … */],
  ngZoneEventCoalescing: true,
  ngZoneRunCoalescing: true
});
```

3) Enhanced control flow and @defer
- Use enhanced control‑flow blocks (if/for/switch) with signal sources where appropriate:
```html
@for (item of items(); track item.id) { … } @empty { … }
```
- Prefer @defer for code‑split subtrees; leverage triggers and prefetching:
```html
@defer (on viewport; prefetch: true) { <heavy-comp/> }
  @loading (minimum: 500ms) { <skeleton/> }
  @error { <error/> }
  @placeholder { <placeholder/> }
```

4) Inputs/Outputs/model ergonomics
- Use input()/output()/model() where supported to reduce boilerplate and improve type inference:
```ts
import { input, output, model } from '@angular/core';
name = input<string>('Default');
saved = output<void>();
value = model<number>(0);
```
- Maintain consistent DX across codebase; do not mix legacy and new patterns within the same feature unless migrating.

5) Hydration strategies (advanced)
- Prefer provideClientHydration(withHttpTransferCache()) and router features (withViewTransitions, withComponentInputBinding) for stability and UX:
```ts
provideClientHydration(withHttpTransferCache()),
provideRouter(routes, withComponentInputBinding(), withViewTransitions())
```
- Keep templates pure and deterministic to avoid mismatches; ensure stable ids/keys.

6) Standalone API refinements
- Continue standalone‑first; import CommonModule and other deps at the component level.
- Prefer route‑level lazy loading with loadComponent for tree‑shaking and perf.

7) State management
- For app‑wide state, pick one: signal‑based services or NgRx with modern providers; do not mix patterns arbitrarily.
- Use toObservable/toSignal only at interop boundaries (e.g., RxJS).

8) Testing
- TestBed with standalone imports; prefer Testing Library patterns. Ensure effects are idempotent under StrictMode‑like dev behaviors.

Migration (17 → 19)
- Upgrade CLI/core incrementally (17 → 18 → 19 when required).
- Adopt input()/output()/model() gradually; ensure bindings remain explicit and typed.
- Remove Zone.js where feasible; test hydration and control‑flow block assumptions (especially @for + track).

Anti‑patterns
- Mixing legacy *ngIf/*ngFor with 19 control‑flow on the same component during new development.
- Relying on Zone.js for change detection in signal‑centric apps.
- Using array index as @for key for lists that reorder/filter.

Prompt alignment
- When Angular 19 is selected:
  - Apply ./angular.md + this file.
  - Prefer signals‑first, optional zoneless bootstrap, advanced @defer, and new input/output/model ergonomics.
  - Configure SSR/hydration features (withHttpTransferCache, withViewTransitions, withComponentInputBinding).
  - Keep TS strict‑first per ../typescript/GLOSSARY.md.

See also
- Base rules — ./angular.md
- Glossary — ./GLOSSARY.md
- Angular 17 rules — ./angular-17.rules.md
- Angular 20 rules — ./angular-20.rules.md
- TypeScript glossary — ../typescript/GLOSSARY.md
- Web Components — ../../frontend/webcomponents/README.md