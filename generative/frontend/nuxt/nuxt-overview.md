# Nuxt Overview

Key principles for Nuxt 3 apps aligned with the Rules Repository.

Structure
- Use the default Nuxt directory layout: `app.vue`, `pages/`, `components/`, `composables/`, `layouts/`, `plugins/`, `server/`, `middleware/`.
- Keep server-only logic under `server/`; avoid importing server files into client bundles.
- Configure Nuxt via `nuxt.config.ts` with typed `defineNuxtConfig` exports; document modules/plugins enabled (e.g., `@pinia/nuxt`).

Rendering modes
- Default to hybrid rendering: server-render HTML per request and hydrate on the client. For SSG, document `nuxt generate` strategy and incremental regeneration settings.

State & data
- Prefer `useAsyncData` or `useFetch` inside pages/composables to fetch data; handle errors/loading states explicitly.
- Use Pinia for global stores; register via modules array or manual plugin.

Tooling
- Use Nitro adapters for deployment targets (Node, Vercel, Cloudflare Workers). Document chosen adapter and required env variables.
- Use ESLint + Prettier + Vitest consistent with TypeScript rules.

Checklist
1. Create `app.vue` layout shell referencing root components.
2. Scaffold sample page with `pages/index.vue` using `<script setup>`.
3. Configure Pinia + Vue Router modules if not already included.
4. Add CLI scripts (`dev`, `build`, `preview`) to package.json.
5. Link README + RULES to Vue + Nuxt topic indices.
