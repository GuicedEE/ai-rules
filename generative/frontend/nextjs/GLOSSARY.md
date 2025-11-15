# Next.js Glossary (Topic-first)

Purpose
- Topic-first glossary for building with Next.js App Router.
- Applies to all files in [rules/generative/frontend/nextjs](rules/generative/frontend/nextjs/README.md).
- Precedence: overrides the root glossary when Next.js is in scope. Avoids duplication with React glossary by focusing on Next-specific conventions.

Component Index and Routing
- [README.md](rules/generative/frontend/nextjs/README.md)
- [nextjs-overview.md](rules/generative/frontend/nextjs/nextjs-overview.md)
- [nextjs-routing-data.md](rules/generative/frontend/nextjs/nextjs-routing-data.md)
- [nextjs-ssr-ssg.md](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md)
- [nextjs-security.md](rules/generative/frontend/nextjs/nextjs-security.md)
- [nextjs-web-components.md](rules/generative/frontend/nextjs/nextjs-web-components.md)

Scope
- App Router conventions, routing, data fetching and caching, rendering modes (SSR/SSG/ISR), edge vs node runtimes, middleware, security, web components, and deployment.

Core Definitions (anchor wording)
- App Router: File-system routing rooted at [app/](rules/generative/frontend/nextjs/nextjs-overview.md).
- Server Component: Default component type rendered on the server; disallows browser-only APIs.
- Client Component: Opt-in via ["use client"](rules/generative/frontend/nextjs/nextjs-overview.md:1); allows hooks and browser APIs.
- Layout: Shared UI defined in [app/layout.tsx](rules/generative/frontend/nextjs/nextjs-overview.md).
- Page: Route entry defined in [app/page.tsx](rules/generative/frontend/nextjs/nextjs-overview.md).
- Route Segment Config: Static export in a route file controlling runtime and caching.
- Route Handler: API handler in [app/segment/route.ts](rules/generative/frontend/nextjs/nextjs-routing-data.md).
- Middleware: Edge function evaluated before a request reaches routes, configured in [middleware.ts](rules/generative/frontend/nextjs/nextjs-routing-data.md).
- Edge Runtime: V8 isolate runtime with limited Node APIs; selected per route via segment config.

Data Fetching and Caching
- Use [`fetch()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) in Server Components for data access; its cache semantics drive rendering.
- Revalidation:
  - Static: set [`revalidate`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) = X in a route segment or returned data.
  - On-demand: [`revalidatePath()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1), [`revalidateTag()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1).
- Dynamic data:
  - Opt out of static prerender by setting [`dynamic`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) = "force-dynamic" in the segment config.
- Params and metadata:
  - Static params: [`generateStaticParams()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1).
  - Metadata: [`generateMetadata()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) and static export [`metadata`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1).
- Cache control:
  - Request: [`fetch()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) options `{ cache, next: { revalidate, tags } }`.
  - Segment: export [`revalidate`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) and [`dynamic`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) values.

Rendering Modes
- SSR: Render on the server per request when dynamic data is used or caching demands.
- SSG: Pre-render at build time; combine with ISR via revalidate.
- ISR: Incremental updates to static pages via background regeneration with revalidate or on-demand.
- Streaming: Progressive rendering for slow data; supported by Server Components and Suspense boundaries.

Routing Conventions
- File-based routes under [app/](rules/generative/frontend/nextjs/nextjs-overview.md):
  - [app/(group)/](rules/generative/frontend/nextjs/nextjs-overview.md) for route groups.
  - [app/[param]/](rules/generative/frontend/nextjs/nextjs-routing-data.md) for dynamic segments.
  - [app/[...catchAll]/](rules/generative/frontend/nextjs/nextjs-routing-data.md) for catch-all.
  - [app/[[...optional]]/](rules/generative/frontend/nextjs/nextjs-routing-data.md) for optional segments.
  - [app/segment/loading.tsx](rules/generative/frontend/nextjs/nextjs-overview.md) for Suspense fallback.
  - [app/segment/error.tsx](rules/generative/frontend/nextjs/nextjs-overview.md) and [app/segment/not-found.tsx](rules/generative/frontend/nextjs/nextjs-overview.md).
- Route Handlers: [app/api/hello/route.ts](rules/generative/frontend/nextjs/nextjs-routing-data.md) exporting HTTP method functions.

Runtimes and Segment Config
- Select runtime per route with export const [`runtime`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) = "edge" | "nodejs".
- Control static/dynamic and caching with export const [`dynamic`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1), [`revalidate`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1), and [`preferredRegion`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1).
- Use export const [`dynamicParams`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) = true | false to control fallback for dynamic params.

Security and Headers
- Use [`headers()`](rules/generative/frontend/nextjs/nextjs-security.md:1) and [`cookies()`](rules/generative/frontend/nextjs/nextjs-security.md:1) in Server Components/Route Handlers.
- Configure CSP, HSTS, and security headers in [nextjs-security.md](rules/generative/frontend/nextjs/nextjs-security.md).
- Avoid leaking secrets to Client Components; read secrets server-side only.

Web Components Integration
- See [nextjs-web-components.md](rules/generative/frontend/nextjs/nextjs-web-components.md) for SSR guards and hydration.
- Prefer Declarative Shadow DOM where supported; otherwise hydrate on client with feature checks.
- Wrap imperative-only props by using Client Components and refs.

Styling, Fonts, Images
- CSS Modules, Tailwind, and CSS-in-JS are supported; prefer CSS Modules in the App Router for locality.
- Fonts: use [`next/font`](rules/generative/frontend/nextjs/nextjs-overview.md:1) to avoid layout shift and network waterfalls.
- Images: use [`next/image`](rules/generative/frontend/nextjs/nextjs-overview.md:1) with appropriate sizes and priority for LCP.

Internationalization
- Configure i18n routes in next.config and hoist common dictionaries in Server Components for caching benefits.

Environment and Secrets
- Only expose variables prefixed with NEXT_PUBLIC_ to the client.
- Access process.env exclusively in Server Components or Route Handlers; never in shared modules used by both unless guarded.

Middleware and Edge
- Define [middleware.ts](rules/generative/frontend/nextjs/nextjs-routing-data.md) at the project root to run logic before routing.
- Use [`NextResponse`](rules/generative/frontend/nextjs/nextjs-routing-data.md:1) for redirects/rewrites in middleware and route handlers.
- Keep middleware tiny; avoid heavy deps; prefer headers/cookies for signaling.

Testing
- Unit test Server Components and utilities in Node; e2e with Playwright. For Route Handlers, test HTTP behavior against the dev server.

Deployment
- Static output: prefer SSG/ISR where applicable to maximize CDN cacheability.
- Edge runtime for latency-sensitive endpoints; Node runtime where Node APIs are required.

LLM Interpretation Guidance
- When generating a feature with data fetching:
  - Prefer Server Components; lift fetches server-side using [`fetch()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) and segment config for caching.
  - Use [`generateStaticParams()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) for static routes with known params.
  - Use [`revalidatePath()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1)/[`revalidateTag()`](rules/generative/frontend/nextjs/nextjs-ssr-ssg.md:1) for ISR invalidation.
- When selecting runtime:
  - Choose "edge" for lightweight, latency-sensitive tasks; "nodejs" for libraries relying on Node APIs.
- When authoring Route Handlers:
  - Export HTTP method functions; read headers/cookies via [`headers()`](rules/generative/frontend/nextjs/nextjs-security.md:1)/[`cookies()`](rules/generative/frontend/nextjs/nextjs-security.md:1); return [`NextResponse`](rules/generative/frontend/nextjs/nextjs-routing-data.md:1).
- When mixing Client and Server Components:
  - Keep most UI server-side; isolate interactivity behind small Client Components with explicit ["use client"](rules/generative/frontend/nextjs/nextjs-overview.md:1).
- When integrating Web Components:
  - Guard client-only usage and attach imperative props in Client Components; prefer declarative attributes for SSR.

Anchor Terms
- App Router, Server Component, Client Component, Route Handler, Segment Config, Revalidation, Streaming, ISR, Edge Runtime, Middleware, Metadata, Static Params.

Compliance
- Follow this glossary’s conventions for naming files and choosing rendering/caching strategies.
- Defer React-specific guidance to the React glossary; this file focuses on Next-specific behavior.