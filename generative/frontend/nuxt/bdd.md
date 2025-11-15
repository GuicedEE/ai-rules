# Nuxt BDD Overrides

Use this guide to adapt BDD scenarios for Nuxt 3 SSR/SSG flows.

Scenario structure
- Capture both server-rendered state and hydrated client behavior. Example: "Given the product page renders via SSR" → assert initial HTML before interactions.
- Include runtime config or route middleware preconditions when they affect user flows.
- Describe navigation in terms of file-based routes (`/products/[id]`) so AI agents know which page file to update.
- When scenarios cover server API routes, identify the handler file (e.g., `server/api/cart.post.ts`) and expected HTTP contract.

Testing hints
- Prefer Playwright/Cypress for end-to-end SSR validation; couple with snapshot tests of server HTML when necessary.
- For component-level tests, reuse Vue TDD guidance but note Nuxt-specific helpers (e.g., `setupTest` from `nuxt-vitest`).
- Use Nuxt's built-in test utils to stub route params and runtime config values per scenario.

Link back to: rules/generative/architecture/bdd/README.md and ../language/vue/bdd.md.
