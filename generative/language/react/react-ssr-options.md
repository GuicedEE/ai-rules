# SSR and Rendering Options with React (Modular)

Purpose
- Outline rendering choices for React projects with and without Next.js.

Options
- Pure SPA (client-only): simplest deploy, no SSR; use Vite/CRA. Pros: low complexity. Cons: poorer SEO, slower TTFB.
- Next.js with App Router (recommended): Server Components by default, streaming SSR, RSC boundaries. Pros: optimal DX/SSR/SEO.
- Next.js Pages Router (legacy/maintained): good for incremental migration; prefer App Router for new apps.
- Custom SSR (Express/Vite SSR): only when Next.js is not an option; higher maintenance.

Guidelines
- Prefer Next.js App Router for greenfield apps; use Server Components for data-heavy UI and Client Components for interactive islands.
- Co-locate data fetching in Server Components using async functions; avoid duplicating fetch in client.
- Use React Suspense for streaming and skeletons; avoid spinner-only UX.
- Cache with Next.js fetch cache, revalidate tags/paths for ISR.

Cross-links
- Next.js overview — ../nextjs/nextjs-overview.md
- Next.js SSR/SSG modes — ../nextjs/nextjs-ssr-ssg.md
- React overview — ./react-overview.md
