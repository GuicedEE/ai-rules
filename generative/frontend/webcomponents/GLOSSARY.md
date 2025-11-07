# Web Components Glossary (Topic-first)

Purpose
- Topic-first glossary for authoring and consuming Web Components across frameworks.
- Applies to all files in [webcomponents](rules/generative/frontend/webcomponents/).
- Precedence: overrides the root glossary and generic frontend guidance when this topic is in scope.
- Goal: canonical terminology, integration rules, and LLM interpretation guidance without duplicating framework-specific glossaries.

Scope
- Core concepts: Custom Elements, Shadow DOM, slots, CSS parts, CSS custom properties, HTML templates, ES modules.
- Consumption patterns: Vanilla, Angular, React, Next.js, microfrontends.
- Authoring policies: naming, reflection, attributes vs properties, events, accessibility, theming, performance.

Component Index and Routing
- [README.md](rules/generative/frontend/webcomponents/README.md)
- [custom-elements.md](rules/generative/frontend/webcomponents/custom-elements.md)
- [shadow-dom.md](rules/generative/frontend/webcomponents/shadow-dom.md)
- [html-templates.md](rules/generative/frontend/webcomponents/html-templates.md)
- [es-modules.md](rules/generative/frontend/webcomponents/es-modules.md)
- [microfronts-overview.md](rules/generative/frontend/webcomponents/microfronts-overview.md)
- [angular20-overview.md](rules/generative/frontend/webcomponents/angular20-overview.md)
- [angular20-consuming-web-components.md](rules/generative/frontend/webcomponents/angular20-consuming-web-components.md)
- [angular20-producing-web-components.md](rules/generative/frontend/webcomponents/angular20-producing-web-components.md)

Related topics
- Angular Awesome Glossary: [GLOSSARY.md](rules/generative/frontend/angular-awesome/GLOSSARY.md)
- React + Web Components: [react-web-components.md](rules/generative/language/react/react-web-components.md)
- Next.js + Web Components: [nextjs-web-components.md](rules/generative/frontend/nextjs/nextjs-web-components.md)

Core Definitions (anchor wording)
- Custom Element: An HTML element defined via [customElements.define()](rules/generative/frontend/webcomponents/custom-elements.md:1). Must include a dash in the name.
- Shadow DOM: Scoped DOM tree providing style and DOM encapsulation for a host element.
- Slot: A placeholder in a shadow tree that renders assigned light DOM children of the host.
- CSS Part: A shadow part export that allows targeted styling from light DOM via ::part(name).
- CSS Custom Property: A --kebab-case variable that can cross the shadow boundary and is inherited.
- Declarative Shadow DOM: Server-rendered shadow roots using <template shadowrootmode="open"> for SSR (see [shadow-dom.md](rules/generative/frontend/webcomponents/shadow-dom.md)).
- Light DOM: The children placed in the page (outside the component’s shadow), assigned to slots.
- Upgrade Timing: The moment a custom element class is connected/defined, upgrading HTML to an instance.
- Reflected Attribute: An attribute that mirrors a property (or vice versa) to maintain declarative state.
- CustomEvent: Event type used by components; may bubble, be composed, and cancelable.
- Module Specifier: The string in import statements; may be path-based or bare, resolved by import maps/bundlers.

Authoring Policies
- Naming
  - Use a unique, namespaced prefix (e.g., wa-...) and include at least one dash.
  - Keep tag names semantic and short; avoid version suffixes in tag names.
- Attributes vs Properties
  - Reflect simple scalar properties (string/number/enum/boolean) to attributes when useful for SSR/markup diffing.
  - Boolean attributes use presence/absence semantics; map to true/false properties.
  - Avoid reflecting objects/functions; expose as JS-only properties.
- Events
  - Emit CustomEvent with a typed detail; document event name, bubbles, composed, cancelable.
  - Avoid clashing names with native events; use wa-* namespace where appropriate.
- Styling
  - Expose style hooks via CSS parts and CSS custom properties; document them.
  - Do not rely on internal element structure; prefer ::part and custom properties.
- Accessibility
  - Provide accessible names/roles; reflect label, aria-* attributes when relevant.
  - Maintain focus delegation and keyboard interactions; opt-in to delegatesFocus if needed.
- Performance
  - Lazy-load heavy resources; avoid synchronous layout thrash; use requestAnimationFrame when animating.
  - Use ResizeObserver/IntersectionObserver instead of polling.
- Versioning
  - Changes to parts/slots/events are breaking; version via package, not tag names.

Consumption Policies
- Vanilla
  - Import/define components before usage; ensure module graph loads definitions prior to first paint.
  - Use attributes for initial declarative config; set JS-only props after connectedCallback/upgrade.
- Angular
  - Enable [CUSTOM_ELEMENTS_SCHEMA](rules/generative/language/angular/angular.md:1) where no dedicated wrappers exist.
  - For dedicated wrappers, follow [GLOSSARY.md](rules/generative/frontend/angular-awesome/GLOSSARY.md) binding and events policy.
- React
  - Prefer ref for imperative props; use onEvent case mapping where applicable; see [react-web-components.md](rules/generative/language/react/react-web-components.md).
- Next.js
  - Ensure ESM-compatible bundling and SSR guards; see [nextjs-web-components.md](rules/generative/frontend/nextjs/nextjs-web-components.md).
- Microfrontends
  - Use ESM and import maps to avoid duplicate registrations; isolate styles via shadow DOM; see [microfronts-overview.md](rules/generative/frontend/webcomponents/microfronts-overview.md).

SSR and Hydration
- Use Declarative Shadow DOM for SSR when supported; otherwise render placeholders and upgrade on client.
- Avoid reading instance properties during SSR; guard with typeof window checks or hydration flags.
- Prefer attributes for SSR-visible state; defer JS-only property assignment until after upgrade.

Security
- Never inject unsanitized HTML into light DOM slots or component internals.
- Validate and sanitize URL-bearing attributes; avoid eval-like APIs.

Testing
- Authoring: test with @web/test-runner or Playwright; verify slot/part contracts.
- Consumption: test integration in framework harnesses (Angular/React) with JSDOM or e2e.

LLM Interpretation Guidance
- When asked to author a component:
  - Provide tag name, attributes/properties (indicate reflected vs JS-only), slots, CSS parts, events (with detail type), and usage examples.
  - Include accessibility notes and theming hooks (custom properties/parts).
  - Include ESM import/registration guidance and upgrade timing notes.
- When asked to consume in a framework:
  - Show attribute vs property binding correctly for that framework.
  - Show event subscriptions and slot usage; avoid accessing internals.
- When generating docs in this folder:
  - Route to the appropriate file in Component Index and avoid duplicating definitions from this glossary.

Component Index and Routing (by topic)
- Concepts
  - [custom-elements.md](rules/generative/frontend/webcomponents/custom-elements.md)
  - [shadow-dom.md](rules/generative/frontend/webcomponents/shadow-dom.md)
  - [html-templates.md](rules/generative/frontend/webcomponents/html-templates.md)
  - [es-modules.md](rules/generative/frontend/webcomponents/es-modules.md)
- Angular 20 Integration
  - [angular20-overview.md](rules/generative/frontend/webcomponents/angular20-overview.md)
  - [angular20-consuming-web-components.md](rules/generative/frontend/webcomponents/angular20-consuming-web-components.md)
  - [angular20-producing-web-components.md](rules/generative/frontend/webcomponents/angular20-producing-web-components.md)
- Microfrontends
  - [microfronts-overview.md](rules/generative/frontend/webcomponents/microfronts-overview.md)

Anchor Terms
- Custom Element, Shadow DOM, Light DOM, Slot, CSS Part, CSS Custom Property, Reflected Attribute, JS-only Property, Upgrade Timing, Declarative Shadow DOM, CustomEvent, Module Specifier, Import Map, Hydration Guard.

Compliance
- Follow this glossary for vocabulary and policies. Framework-specific glossaries may further restrict behavior; when both apply, use the narrower, topic-local rules.