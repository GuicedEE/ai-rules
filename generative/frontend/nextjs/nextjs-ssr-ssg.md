# SSR/SSG/ISR and Rendering Modes — Modular

Purpose
- Explain rendering choices per route and how to configure them in Next.js App Router.

Modes
- SSR (Dynamic): default for uncached server rendering; export const dynamic = 'force-dynamic'.
- SSG (Static): pre-render at build; export const dynamic = 'force-static' or use no dynamic data.
- ISR (Incremental): static with revalidation; export const revalidate = 60 or set fetch({ next: { revalidate: 60 } }).
- Edge vs Node runtimes: set export const runtime = 'edge' | 'nodejs' per route if needed.

Examples
```tsx
// app/products/[id]/page.tsx
export const revalidate = 60; // ISR

export default async function ProductPage({ params }: { params: { id: string } }) {
  const res = await fetch(`https://api.example.com/products/${params.id}`, { next: { revalidate: 60 } });
  const product = await res.json();
  return <div>{product.name}</div>;
}
```

Streaming and Suspense
- Use Suspense boundaries in layouts/pages to stream server-rendered content progressively.

Cache control
- Use revalidateTag/revalidatePath in Route Handlers or server actions to invalidate caches on writes.

Cross-links
- Next.js overview — ./nextjs-overview.md
- Routing and Data — ./nextjs-routing-data.md
- React SSR overview — ../react/react-ssr-options.md
