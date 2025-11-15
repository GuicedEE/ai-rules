# Vue Overview

Purpose: Provide quick-start structure for Vue 3 applications that align with Rules Repository guardrails.

Key points
- Use Vite (preferred) or Vue CLI only for legacy migrations. Document the bundler choice inside IMPLEMENTATION.md.
- Structure source as `src/components`, `src/composables`, `src/stores`, `src/routes` (if using Vue Router).
- Enforce Composition API with `<script setup>`; Options API only when wrapping legacy libs.
- Register global plugins (router, Pinia, i18n) via `app.use()` inside `src/main.ts` and keep plugin wiring idempotent for SSR.
- Keep SFC templates declarative; move logic into composables or computed properties.
- Use `defineProps`/`defineEmits` macros for typed interfaces; export prop/event contracts for reuse in docs/tests.
- Align CSS with scoped modules or utility classes (Tailwind) but document the approach in RULES.md.
- Document environment variables consumed by Vite in `.env.example` with `VITE_` prefix.

Starter template checklist
1. Initialize Vite with `npm create vite@latest my-app -- --template vue-ts`.
2. Install Pinia and Vue Router when state or routing is required.
3. Add ESLint + Prettier configs consistent with TypeScript topic rules.
4. Scaffold shared composables (e.g., `useApi`, `useFeatureFlag`) inside `src/composables/` with typed responses.
5. Create README sections referencing Vue topic index and any Nuxt usage.
