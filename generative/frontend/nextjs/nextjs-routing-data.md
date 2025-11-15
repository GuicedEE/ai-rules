# Routing and Data Fetching (App Router) — Modular

Purpose
- Show routing primitives and data patterns in Next.js App Router.

Routing basics
- app/layout.tsx defines the root layout; nested layouts per segment.
- app/page.tsx for the root route; app/(group)/segment/page.tsx for groups.
- Route Handlers: app/api/route.ts, app/api/users/[id]/route.ts for server endpoints.

Data fetching in Server Components
- Use async components and fetch directly server-side:
```tsx
// app/users/page.tsx
export default async function UsersPage() {
  const res = await fetch('https://api.example.com/users', { next: { revalidate: 60 } });
  const users = await res.json();
  return (
    <ul>
      {users.map((u: any) => <li key={u.id}>{u.name}</li>)}
    </ul>
  );
}
```

Dynamic vs static
- Static: set revalidate number or export const revalidate = 60.
- Dynamic: export const dynamic = 'force-dynamic' for non-cacheable routes.

Client components and hydrations
- Mark components with 'use client' when using state/effects. Use sparingly: code and any reachable values in Client Components are shipped to the browser; never import server-only secrets or non-NEXT_PUBLIC env here. See Security — ./nextjs-security.md#13-client-components-use-client-risk-model.
- For client data synchronization, use TanStack Query with a Provider in a Client Component boundary.

Cross-links
- Next.js overview — ./nextjs-overview.md
- SSR/SSG/ISR — ./nextjs-ssr-ssg.md
- Web Components — ./nextjs-web-components.md
