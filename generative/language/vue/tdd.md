# Vue TDD Overrides

Use this topic with the Architecture → TDD base rules for Vue 3 apps (Options or Composition API) and Pinia stores.

Scope and precedence
- Applies to SFCs, composables, directives, and Pinia stores.
- Nuxt builds layer Nuxt-specific TDD guidance (see ../../frontend/nuxt/tdd.md).

Practices
- Favor unit-like tests around composables and stores; mount SFC shells only when template rendering matters.
- When using `<script setup>`, export helper functions explicitly so tests can import and exercise them without DOM mounting when possible.
- Assert emitted events with `wrapper.emitted()` and verify payload shapes per glossary definitions.
- For DOM-based specs, use `@testing-library/vue`; avoid brittle CSS selectors—query by role/label/text.
- Reset Pinia stores via `setActivePinia(createPinia())` in each spec to keep tests isolated.
- Mock browser APIs (IntersectionObserver, matchMedia) via Vitest setup files to keep JSDOM deterministic.
- SSR/CSR parity: when hydration is required, run tests in Nuxt harness (see Nuxt TDD file) to validate server payload + client hydration.

References
- Base TDD rules — rules/generative/architecture/tdd/README.md
- TypeScript rules (if using TS) — ../typescript/README.md
