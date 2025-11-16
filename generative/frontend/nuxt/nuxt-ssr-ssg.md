# SSR vs SSG Strategy

Choose rendering strategies intentionally and document them in IMPLEMENTATION.md.

SSR (Server-Side Rendering)
- Default for authenticated dashboards or highly dynamic data.
- Ensure server routes and runtime config secrets stay server-only.
- Implement caching/prefetch strategies (HTTP cache headers, Nitro storage) where appropriate.

SSG (Static Site Generation)
- For marketing/docs pages, use `nuxi generate` with route rules in `nuxt.config.ts` or `nitro.prerender.routes` entries.
- Document revalidation strategy using `routeRules` with `isr` configs (seconds) for incremental static regeneration.

Hybrid
- Use route rules to mix SSR and SSG (e.g., `routeRules: { '/blog/**': { swr: 60 }, '/admin/**': { ssr: true } }`).
- When using Edge adapters, ensure server API routes avoid Node-specific APIs.

Hydration
- Verify server-rendered HTML matches client-side DOM; avoid `window` usage outside client-only sections.
- Use `<client-only>` wrapper sparingly; prefer feature detection.

Testing
- Snapshot SSR output for key routes and run e2e tests for SSG routes served from generated assets.
