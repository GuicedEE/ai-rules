# Vue BDD Overrides

Use this file to adapt the Architecture → BDD base rules for Vue 3 frontends.

Precedence:
- Vue BDD supersedes base BDD guidance when a scenario covers Vue Single File Components, composables, or routing concerns.
- Nuxt scenarios defer to the Nuxt BDD rules in addition to this file.

Scenario guidance
- Describe user intent at the component or page level (e.g., "Given the catalog grid is visible"), not internal refs.
- Explicitly assert rendered DOM in templates after hydration. When using SSR (Nuxt), assert server-rendered HTML before client interaction.
- Capture component state transitions (props → reactive state → emitted events). Name props/events exactly as defined in SFCs.
- When testing composables, bind them to lightweight harness components to emulate lifecycle hooks.
- Include edge cases for async effects (loading/error), ensuring watchers are disposed between tests.

Automation hints
- Use Vitest/Cypress for component/e2e tests; prefer Testing Library Vue queries for DOM assertions.
- Mount SFCs with `mount` from `@vue/test-utils`; wrap store/composable providers via factory helpers.
- For Pinia stores, instantiate a fresh Pinia per scenario to avoid shared state.

Link back to: rules/generative/architecture/bdd/README.md for global workflow expectations.
