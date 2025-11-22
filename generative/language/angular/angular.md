# Angular — Base Rules (Version-agnostic)

Purpose
- Provide concise, modular, version-agnostic Angular guidance used as the common baseline. Version-specific behavior is defined in override files (angular-17.rules.md, angular-19.rules.md, angular-20.rules.md). Avoid duplication by placing shared guidance here and only deltas in version overrides.

How to use
- Select Angular version in prompts (17, 19, or 20).
- Apply this base file first, then the chosen version’s override.
- For SSR/SSG/ISR choose Next.js or Angular Universal per project; hydrate safely.

Core principles
- Standalone-first
  - Use standalone components/directives/pipes; import dependencies at component level.
- Routing
  - Prefer functional routing and route-level code-splitting; use guards/resolvers/providers functionally.
- Reactivity
  - Use signals for local state where available and appropriate; use computed/effect; coordinate with app-wide state strategy (signals services or NgRx).
- Control flow
  - Prefer Angular’s built-in control flow blocks (if/for/switch) where the selected version supports them; fall back to legacy syntax if required by version.
- Type safety and flow control
  - Ban `any` (explicit or implicit); use `unknown`, generics, and discriminated unions, then narrow via conditions/guards instead of casting away types.
  - Do not add no-op try/catch blocks; surface errors or handle them explicitly so failures stay observable.
- SSR/Hydration
  - Keep templates pure and deterministic; avoid side-effects during render/init; prefer zoneless hydration when version supports it; ensure stable keys/ids.
- DI
  - Prefer providedIn for service scope; use inject() in functions/providers where appropriate; avoid over-provisioning at component roots.
- HTTP
  - Prefer typed HttpClient, interceptors for cross-cutting concerns, cancellation awareness.
- Forms
  - Prefer Reactive Forms; apply form control typing; validators pure and testable.
- Testing
  - Use Angular TestBed for integration; prefer Testing Library for user-focused assertions; avoid brittle DOM-coupled tests.

Structure and conventions
- Component authoring
  - Input/Output explicit; type events; avoid any; prefer unknown + narrowing.
  - View encapsulation per design; accessibility and aria labeling; semantic HTML first.
- File organization
  - Feature-first folders; co-locate component files; use barrel exports sparingly.
- Tooling
  - TypeScript strict-first (see ../typescript/GLOSSARY.md): strict, strictNullChecks, exactOptionalPropertyTypes, noUncheckedIndexedAccess.
  - ESM module settings; builder config aligned with strict TS.
- Web Components interop
  - Integrate Custom Elements carefully: prefer property binding, CustomEvent dispatch, and compatibility wrappers as needed.

Version overrides (apply on top of base)
- Angular 17 — ./angular-17.rules.md
  - Introduces control flow blocks, signals maturity step; SSR stable.
- Angular 19 — ./angular-19.rules.md
  - Improved DI ergonomics, signals/control-flow refinements; optional zoneless strategies.
- Angular 20 — ./angular-20.rules.md
  - Hydration/SSR refinements; performance/tooling upgrades; state and DI improvements.

Prompt alignment
- Frontend (Reactive): Angular (17/19/20)
  - Generate standalone components, functional routing, modern control flow per selected version.
  - Apply strict TS posture (unknown over any; no implicit anys; exact optionals; unchecked indexed access disabled).
  - For SSR/hydration, follow the selected version’s capabilities; keep templates pure and idempotent.

See also
- Topic index — ./README.md
- Glossary — ./GLOSSARY.md
- Version overrides — ./angular-17.rules.md, ./angular-19.rules.md, ./angular-20.rules.md
- TypeScript glossary — ../typescript/GLOSSARY.md
- Web Components — ../../frontend/webcomponents/README.md
