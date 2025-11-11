# Next.js Overview (App Router, RSC) — Modular

Purpose
- Provide a concise orientation for modern Next.js (App Router, Server Components) in enterprise use.

Key points
- Prefer App Router (app/) with Server Components by default; mark Client Components via 'use client'. Use sparingly: 'use client' ships component code and any reachable values to the browser. Never import server-only secrets or non-NEXT_PUBLIC env into Client Components. See Security → Client Components ('use client') risk model — ./nextjs-security.md#13-client-components-use-client-risk-model.
- File-based routing with nested layouts; streaming and Suspense-first UX.
- Data fetching: async Server Components with fetch; caching/revalidation via fetch options and Route Segment Config.
- Rendering: SSR, SSG, ISR, and dynamic rendering; choose per-route.
- API routes and Route Handlers for server logic co-located with UI when appropriate.
- Env/secrets: use environment variables and limit exposure to client (NEXT_PUBLIC_ prefix only when safe).

Recommended stack
- TypeScript, ESLint, Prettier; Tailwind or CSS Modules; React Testing Library + Vitest/Jest.
- TanStack Query for client side data synchronization where needed; favor server data in RSC.

Cross-links
- Routing and Data — ./nextjs-routing-data.md
- SSR/SSG/ISR — ./nextjs-ssr-ssg.md
- Web Components in Next.js — ./nextjs-web-components.md
- React overview — ../react/react-overview.md
