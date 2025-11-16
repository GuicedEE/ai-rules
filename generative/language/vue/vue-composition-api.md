# Composition API and State Patterns

Use this guide to standardize how Composition API primitives are applied.

Composables
- Create composables as named functions (`export function useUserProfile() { ... }`).
- Return only the refs/computed values/actions required by consumers; avoid leaking implementation refs.
- Accept parameters as plain values or refs; document whether they are reactive.
- Cleanup timers, subscriptions, and event listeners in `onScopeDispose` to keep SSR rendering deterministic.

State management
- Prefer Pinia over Vuex. Define stores via `defineStore('cart', () => { ... })` using Composition API signatures.
- Keep store state typed; use `ref` for scalars, `reactive` for objects, `computed` for derived data.
- Do not mutate props directly; copy to local refs.

Reactivity tips
- Use `watchEffect` for auto-tracking dependencies; switch to `watch` when you need explicit arrays of deps.
- Avoid deep watchers when possible; restructure state into multiple refs.
- When bridging to Promise-based APIs, wrap asynchronous logic in `try/finally` to control loading flags.

Testing and docs
- Document every composable/store in GUIDES.md with a short blurb and link to its spec.
- Tests should cover success/error/edge flows and ensure watchers are stopped.
