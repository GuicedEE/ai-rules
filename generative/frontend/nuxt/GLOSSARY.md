# Nuxt Glossary (Topic-Scoped)

- **App Router** — Nuxt's file-based routing system rooted in `pages/`; dynamic routes defined with `[param].vue` or `[...slug].vue`.
- **Server Route / API Route** — Files under `server/api/` executed on the server (Nitro). Each exports a handler via `export default defineEventHandler`.
- **Composable** — Shared logic defined under `composables/` that Nuxt auto-imports; for Nuxt-specific use, prefix with `use` and document dependencies on runtime config.
- **Runtime Config** — Values defined in `nuxt.config.ts` under `runtimeConfig`; server-side values go under `runtimeConfig`, public ones under `runtimeConfig.public`.
- **Nitro** — Nuxt server engine powering server routes, middleware, and adapters. Mention adapter targets (node, vercel, cloudflare) in IMPLEMENTATION.md.
- **Middleware** — Files under `middleware/` executed before page navigation; add `.global` to run on every route.
- **Layouts** — Files under `layouts/` wrapping pages; `layouts/default.vue` is the standard shell.
- **Nuxt Plugin** — Files under `plugins/` that run before app instantiation; use `defineNuxtPlugin` and document SSR/client execution via filename suffix (`.client`, `.server`).
- **Nitro Event** — Request object for server routes; interact via `event.node.req`/`res` or helper utilities (e.g., `getQuery`, `readBody`).

LLM guidance
- Specify whether code runs on server, client, or both; respect `.client`/`.server` plugin conventions.
- Always note when `useAsyncData`/`useFetch` are awaited server-side vs client-side.
- For security-critical sections, reference nuxt-security guide and runtime config usage.
