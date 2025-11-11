# React — Topic Glossary (Priority over root glossary)

Scope
- Minimal canonical terms for React in this topic. When this topic is referenced, these terms take precedence over the root glossary. Keep entries concise and route to rules/guides for detail.

LLM interpretation guidance (how to apply these terms)
- Component model
  - Prefer function components with hooks; do not generate class components or legacy lifecycle methods.
  - Use the Automatic JSX Runtime; do not import React for JSX unless the toolchain requires it.
- TypeScript posture
  - Model Props with explicit interfaces/types; avoid React.FC unless you specifically want the implicit children prop.
  - Type children as ReactNode when applicable; type events using React.*Event.
- State and effects
  - Use useState/useReducer for state; useEffect for effects; prefer effect separation and minimal dependency arrays.
  - Avoid stale-closure bugs by listing stable dependencies or wrapping callbacks with useCallback.
- Memoization
  - Use useMemo/useCallback for expensive computations and stable references; do not prematurely optimize.
- Keys and lists
  - Keys must be stable and unique among siblings; avoid array index keys where reordering/filtering occurs.
- Concurrency
  - React 18+ concurrent features: transitions (useTransition), deferred values (useDeferredValue), scheduler-friendly updates.
- Suspense and lazy
  - Use React.lazy and Suspense for code-splitting; pair with error boundaries for robust UX.
- Accessibility
  - Prefer semantic elements; wire labels/aria attributes; ensure focus management for modals/portals.
- Testing
  - Prefer React Testing Library and type-safe test setups; avoid testing implementation details.

Routing
- Language index — ./README.md
- Overview — ./react-overview.md
- Web Components interop — ./react-web-components.md
- SSR/SSG/ISR options — ./react-ssr-options.md
- Next.js category — ../../frontend/nextjs/README.md

Canonical terms

- function component
  - Meaning: Stateless/stateful function returning JSX; primary unit for UI composition.
  - LLM: generate function components with explicit Props types; avoid classes.

- props
  - Meaning: Immutable inputs to a component.
  - LLM: define Props as a type/interface; destructure in parameters for clarity.

- children
  - Meaning: Arbitrary nested content passed between opening/closing tags.
  - LLM: type as ReactNode when supported by the component’s design.

- state updater function
  - Meaning: Functional form of setState that receives previous state.
  - LLM: prefer updater form when the next state depends on prior state.

- controlled vs uncontrolled inputs
  - Meaning: Controlled input value comes from state; uncontrolled uses the DOM’s internal state via refs/defaultValue.
  - LLM: default to controlled for predictable behavior; use uncontrolled only for performance/escape hatches.

- key
  - Meaning: Stable identity for list items enabling efficient reconciliation.
  - LLM: never use array index keys when items can be reordered/removed/inserted.

- hook
  - Meaning: Functions prefixed with “use” that leverage React state/effects and follow the Rules of Hooks.
  - LLM: call hooks only at the top level of function components or custom hooks; never inside conditionals/loops.

- useEffect (effect)
  - Meaning: Runs side effects after render; dependency array controls re-run.
  - LLM: separate unrelated effects; list all stable deps; use cleanup to avoid leaks.

- useMemo / useCallback (memoization)
  - Meaning: Cache computed values/functions between renders based on dependencies.
  - LLM: memoize only when it prevents expensive work or stabilizes identities for child props.

- useRef (refs)
  - Meaning: Mutable container persisting across renders without triggering re-renders.
  - LLM: use for DOM access and instance-like storage; avoid storing derived state.

- context
  - Meaning: Mechanism for passing data through the tree without prop drilling.
  - LLM: define minimal context surfaces; memoize provider values to avoid unnecessary renders.

- Suspense
  - Meaning: Declarative waiting for async data/code; shows fallback UI.
  - LLM: wrap lazily loaded components or async boundaries; pair with error boundaries.

- lazy (code splitting)
  - Meaning: Dynamic import of components.
  - LLM: prefer route-level and heavy sub-tree splitting; place under Suspense.

- StrictMode
  - Meaning: Development-only runtime checks with intentional double-invocation of some lifecycles/effects.
  - LLM: ensure effects are idempotent and clean up correctly.

- SyntheticEvent
  - Meaning: React’s cross-browser event wrapper.
  - LLM: type events correctly (e.g., React.MouseEvent<HTMLButtonElement>).

- transitions / deferred values
  - Meaning: Mark non-urgent updates (useTransition) or derive lag-tolerant values (useDeferredValue).
  - LLM: use for large list filtering, search-as-you-type, or route transitions.

- fragment
  - Meaning: Group elements without extra DOM nodes.
  - LLM: prefer <>...</> or <React.Fragment> for keyed fragments.

- portal
  - Meaning: Render subtree into a different DOM container (e.g., modals, tooltips).
  - LLM: manage focus and aria relationships; close on escape/backdrop appropriately.

- error boundary
  - Meaning: Class or wrapper catching render-time errors below it.
  - LLM: provide at least one at app shell; pair with Suspense for resilient UX.

- reconciliation
  - Meaning: Algorithm diffing virtual trees to compute minimal DOM changes.
  - LLM: help it with stable keys and memoization where beneficial.

- SSR / SSG / ISR
  - Meaning: Server-Side Rendering, Static-Site Generation, Incremental Static Regeneration (framework-dependent).
  - LLM: route to Next.js docs for implementation details; keep components framework-agnostic where possible.

- web components interop
  - Meaning: Integration of Custom Elements into React.
  - LLM: prefer property/attribute bridging and event dispatch via CustomEvent; see dedicated interop guide.

TypeScript-specific guidance for React
- Props
  - Prefer type or interface Props; avoid React.FC unless implicit children is desired.
- Events
  - Use React.*Event types; e.g., React.ChangeEvent<HTMLInputElement>.
- Children
  - Type as ReactNode; avoid implicit any.
- Generics
  - For reusable components (e.g., data tables), use generics with constraints; expose explicit prop-based type parameters when needed.

Prompt alignment
- When this topic is selected in prompts:
  - Generate function components with explicit Props types, hooks-only patterns, and strict TypeScript types.
  - Use Automatic JSX Runtime; configure tooling accordingly; no unnecessary React import for JSX.
  - Add React Testing Library scaffolding if tests are in scope; pair with vitest/jest as appropriate.
  - For SSR/SSG/ISR needs, route to the Next.js topic and keep React components SSR-safe (avoid window/document at render).

See also
- Topic index — ./README.md
- Overview — ./react-overview.md
- Web Components interop — ./react-web-components.md
- SSR/SSG options — ./react-ssr-options.md
- Next.js — ../../frontend/nextjs/README.md