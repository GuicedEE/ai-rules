# Angular 20 — Modular Overview

Use this guide when your host project targets Angular 20 and you need a concise, modular entry point that aligns with the RulesRepository structure and formatting policies.

- Back-link: Frontend → Angular topic index — ./README.md
- Rules linkage: ../../../../RULES.md — Document Modularity Policy; Generative Topic Taxonomy

## Purpose
Provide a compact orientation for Angular 20’s key capabilities and how to apply them in line with our modular documentation model. Deep dives belong in focused guides (see See also).

## When to apply
- Building SPAs with Angular 20 features (Signals-first, improved hydration)
- Integrating Angular with Web Components (producing and consuming)
- Implementing Micro Frontends where Angular 20 is a participant
- Standardizing DI, routing, and state patterns across teams

## Quick start (minimal)
```bash
# Create a new Angular 20 workspace (Angular CLI assumed up-to-date)
ng new my-app --standalone --routing --style=scss
cd my-app
ng add @angular/ssr  # if SSR/hydration is required
```

Minimal Signals-based component (baseline)
```ts
import { Component, signal, computed } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <h2>{{ count() }}</h2>
    <p>Doubled: {{ doubled() }}</p>
    <button (click)="inc()">Increment</button>
  `
})
export class CounterComponent {
  readonly count = signal(0);
  readonly doubled = computed(() => this.count() * 2);
  inc() { this.count.update(v => v + 1); }
}
```

## Key patterns and guidance

### 1) Signals-first state
- Prefer signals/computed/effect for local component state and derivations.
- For app/state stores, prefer a small, explicit state object + derived selectors. Avoid over-engineering global stores unless cross-cutting.
- Anti-patterns: mixing imperative event mutation with hidden side effects; prefer pure update functions.

### 2) Hydration (SSR) without flicker
- Adopt Angular SSR and verify stable IDs for critical content to prevent mismatch.
- Measure TTI and interaction readiness; avoid blocking scripts during hydration.
- See also: Observability → Tracing for web timings correlation.

### 3) Micro Frontends
- Keep domain boundaries clear; publish/subscribe across boundaries using simple, typed events.
- Prefer Web Components as the interop contract for cross-framework shells.
- Defer shared state to composition root; do not leak internal stores across MFEs.

### 4) DI and providers
- Use `provide*` APIs in `bootstrapApplication` or feature-level `providers` for tree-shakable DI.
- Avoid global singletons unless cross-cutting and idempotent.

### 5) Web Components integration
- Producing: wrap standalone components as Custom Elements for cross-framework reuse.
- Consuming: integrate external Custom Elements with Inputs/Outputs mapped via attributes/events.

## Anti-patterns to avoid
- Monolithic feature modules solely for organization; prefer standalone components and feature-level providers.
- Coupling MFEs through direct framework imports; interop via contracts (Custom Elements + events).
- Hydration that re-renders large trees due to key/ID mismatches.

## See also (modular guides)
- Angular 20 + Web Components
  - Overview — ../webcomponents/README.md (category), ../../frontend/webcomponents/angular20-overview.md
  - Producing Web Components — ../../frontend/webcomponents/angular20-producing-web-components.md
  - Consuming Web Components — ../../frontend/webcomponents/angular20-consuming-web-components.md
  - Micro Frontends overview — ../../frontend/webcomponents/microfronts-overview.md
- Architecture
  - Micro Frontends (architectural) — ../../architecture/microfronts/README.md
- Frontend
  - Angular topic index — ./README.md

