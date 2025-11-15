# Angular — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms for Angular in this topic. When this topic is referenced, these terms and directives take precedence over the root glossary. Keep entries concise and route to modular guides and version overrides for details.

LLM interpretation guidance (how to apply these terms)
- Version selection
  - Angular versions are explicit in prompts (17/19/20). Use ./angular.md (base rules) as the default and apply deltas from the selected version override (./angular-17.rules.md, ./angular-19.rules.md, ./angular-20.rules.md).
  - Do not mix version-only APIs; if ambiguous, prefer the selected version’s override file guidance.
- Standalone-first
  - Prefer standalone components/directives/pipes; avoid NgModule unless required (legacy libraries or special integration).
- Control flow (if / for / switch)
  - Use Angular’s built-in control-flow blocks (v17+) instead of *ngIf/*ngFor where supported. Fall back to legacy syntax in v17-only templates where necessary.
- Signals and reactivity
  - Prefer signals (v16+) and computed/effect APIs for local reactive state. For app-wide state, choose a strategy (signals services or NgRx) based on project needs.
- SSR/Hydration
  - Use server-side rendering with hydration for SEO and perf; prefer zoneless hydration where version supports it (v19+). Keep templates pure for hydration safety.
- Routing
  - Use functional routers and route-level code-splitting; leverage lazy-loaded standalone components.
- Web Components
  - Integrate native Custom Elements or build Angular Elements as needed; for cross-framework sharing, reference the Web Components topic and Angular interop guides.
- Testing
  - Favor modern Angular TestBed APIs and Testing Library for Angular; avoid brittle renderer-dependent tests.
- Security
  - Use built-in sanitization; bind to [property] not [innerHTML] unless trusted; handle DOM access via Renderer2 and platform checks.

Routing
- Language index — ./README.md
- Base rules — ./angular.md
- Version overrides — ./angular-17.rules.md, ./angular-19.rules.md, ./angular-20.rules.md
- Web Components interop — ../../frontend/webcomponents/README.md

Canonical terms

- Standalone component
  - Meaning: Component usable without NgModule; imports declared directly on the component.
  - LLM: generate standalone=true; import dependencies at the component level.

- Control flow blocks (if/for/switch)
  - Meaning: Template syntax replacing *ngIf/*ngFor/*ngSwitch (v17+).
  - LLM: prefer new blocks when the selected Angular version supports them.

- Signals / computed / effect
  - Meaning: Fine-grained reactivity primitives (v16+).
  - LLM: use signals for local state; use computed for derived values; use effect for side-effects. Avoid mixing with ZoneJS when zoneless is targeted.

- Input / Output (decorators, signals)
  - Meaning: Component inputs/outputs; for signals-based inputs/outputs use the version-appropriate APIs.
  - LLM: prefer @Input/@Output with typed EventEmitter; adopt signal-based inputs/outputs if the selected version encourages them and app architecture allows.

- Functional router / lazy routes
  - Meaning: Route configurations using functional APIs; lazy-loaded components/routes.
  - LLM: default to functional route definitions; prefer route providers and guards as needed.

- Dependency Injection (DI)
  - Meaning: Provide services via providedIn:'root' or scoped providers; use inject() where appropriate.
  - LLM: prefer providedIn and inject() within functions/constructors mindful of version constraints.

- Hydration (SSR)
  - Meaning: Client picks up server-rendered HTML; zero/low flicker.
  - LLM: write pure templates and avoid side-effects on init; prefer stable IDs/keys and data-safe bindings; consult version override for hydration specifics.

- Zones / zoneless
  - Meaning: Legacy change detection mechanism vs signal-centered zoneless strategies (v19+).
  - LLM: follow the selected version’s recommendation; prefer zoneless when app targets it and libs allow.

- HttpClient / interceptors
  - Meaning: Angular’s HTTP API with interceptor chains for cross-cutting concerns.
  - LLM: prefer typed APIs and observable handling with proper cancellation/unsubscription patterns.

- Forms (Reactive / Template-driven)
  - Meaning: Two approaches to forms.
  - LLM: prefer Reactive Forms for scalability and testability.

- Testing utilities (TestBed)
  - Meaning: Angular’s core test harness.
  - LLM: configure TestBed with standalone imports; prefer Testing Library patterns for user-centric tests.

- Builder / CLI
  - Meaning: Angular CLI and builders for build/test/serve.
  - LLM: keep tsconfig strict; align with TypeScript glossary (unknown over any; strictNullChecks; exactOptionalPropertyTypes).

Version overrides (routing hints)
- Angular 17 (./angular-17.rules.md)
  - Control-flow blocks introduced; stable SSR; standalone-first; signals available.
- Angular 19 (./angular-19.rules.md)
  - Signals and control flow matured; improvements to DI and optional zoneless patterns.
- Angular 20 (./angular-20-overview.md or ./angular-20.rules.md)
  - Hydration/SSR refinements; enhanced state; performance/tooling upgrades; version-specific DI and build pipeline changes.

Prompt alignment
- When Angular is selected in prompts:
  - Ask for or respect the selected version (17/19/20). Use ./angular.md (base) and apply the version override file.
  - Generate standalone components, functional routing, and modern control flow when supported by the selected version.
  - Integrate SSR/hydration per version; ensure templates are hydration-safe.
  - Apply TypeScript strict-first policy per the TypeScript glossary; interop with Web Components per the webcomponents topic.

See also
- Topic index — ./README.md
- Base rules — ./angular.md
- Version overrides — ./angular-17.rules.md, ./angular-19.rules.md, ./angular-20.rules.md
- TypeScript glossary — ../typescript/GLOSSARY.md
- Web Components — ../../frontend/webcomponents/README.md