# Routing, Data Fetching, and Server Routes

Routing
- Pages placed under `pages/` map to routes. Example: `pages/products/[id].vue` → `/products/:id`.
- Nested routes use directories with `index.vue`. Use `definePageMeta` for titles/auth requirements.
- Middleware can run per-route (`middleware/auth.ts`) or globally (`auth.global.ts`). Document dependencies between middleware and runtime config.

Data fetching
- Use `useAsyncData`/`useFetch` with `await` inside `<script setup>` to fetch data server-side. Provide unique keys (e.g., `useAsyncData('products', ...)`).
- Handle caching with `stale-while-revalidate` options and specify server vs client execution via `server` option.
- For client-only requests, wrap `useFetch` calls in `if (process.client)` or `onMounted` to avoid SSR errors.

Server routes
- Place API handlers under `server/api/*.ts`. Export `defineEventHandler` returning JSON.
- Validate input via `validateQuery`/`readBody`, sanitize external outputs, and return typed payloads.
- Use Nitro utilities (`getRouterParam`, `setResponseStatus`) for clarity.
- Document each server route in GUIDES.md with HTTP method, path, and corresponding spec.

Examples
```ts
// server/api/products/[id].get.ts
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const product = await event.context.db.products.findOne(id)
  if (!product) {
    throw createError({ statusCode: 404, statusMessage: 'Product not found' })
  }
  return product
})
```
