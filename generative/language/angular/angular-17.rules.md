# Angular 17 — Modular Rules (Override of base angular.md)

Purpose
- Provide concise, version-specific rules for Angular 17 to apply on top of the base rules in ./angular.md. Avoid duplication by only documenting 17-specific deltas and decisions.

How to use
- Apply ./angular.md (base) first, then these overrides for Angular 17.
- For cross-cutting language concerns (TypeScript strict-first, Web Components interop), route to their topic glossaries and rules.

Quick start (CLI)
```bash
npm i -g @angular/cli
ng new my-app --standalone --routing --style=scss
cd my-app
ng serve
# SSR if needed:
ng add @angular/ssr
```

Key deltas vs base

1) Standalone-first (default in 17)
- Components/directives/pipes are standalone; import dependencies at component level.
- Prefer feature-first structure; avoid NgModules unless required.

2) Control flow blocks (if/for/switch)
- Use Angular’s built-in control-flow blocks introduced in v17:
```html
@if (user) { <div>{{ user.name }}</div> }
@for (item of items; track item.id) { <div>{{ item.name }}</div> } @empty { <p>No items</p> }
@switch (state) { @case ('a') { ... } @default { ... } }
```
- Use track expressions for @for performance (e.g., track item.id).

3) Signals (initial maturity)
- Use signal/computed for local state derivations; effect for side effects.
- Prefer signals for local state; where app-wide state is needed, evaluate NgRx or a signals-based service pattern.
```ts
const count = signal(0);
const doubled = computed(() => count() * 2);
```

4) SSR + hydration (improved)
- Provide SSR using Angular Universal; hydration via provideClientHydration().
- Keep templates pure to avoid hydration mismatch; ensure stable ids/keys.

5) Routing (functional)
- Prefer Routes array + loadComponent for lazy standalone components.
```ts
export const routes: Routes = [
  { path: '', loadComponent: () => import('./home/home.component').then(m => m.HomeComponent) }
];
```

6) HTTP and forms
- HttpClient typed APIs with cancellation awareness; validate on submit and show errors post-touched.
- Prefer Reactive Forms; type controls and validators; align with strict TS (exact optionals, noUncheckedIndexedAccess).

7) Testing
- Use TestBed with standalone component imports; Testing Library for Angular recommended.
- Jest may be used instead of Karma/Jasmine if requested by project.

Migration notes (16 → 17)
- Migrate to standalone with the Angular schematic:
```bash
ng generate @angular/core:standalone
```
- Adopt new control-flow blocks to replace legacy *ngIf/*ngFor/*ngSwitch stepwise.
- Move router to functional form; remove NgModule-based routing shells.

Anti-patterns
- Re-introducing NgModules purely for grouping; prefer standalone + feature folders.
- Using array index as @for key for re-orderable lists.
- Hydration that re-renders large trees due to id/key instability.

Prompt alignment
- When prompts select Angular 17:
  - Apply ./angular.md + this file.
  - Use standalone components, functional routing, v17 control-flow blocks, and signals for local state.
  - If SSR/hydration is selected, add @angular/ssr and provideClientHydration().
  - Keep TypeScript strict-first per ../typescript/GLOSSARY.md.

See also
- Base rules — ./angular.md
- Glossary — ./GLOSSARY.md
- Angular 19 — ./angular-19.rules.md
- Angular 20 — ./angular-20.rules.md
- TypeScript glossary — ../typescript/GLOSSARY.md
- Web Components — ../../frontend/webcomponents/README.md