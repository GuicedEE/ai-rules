# Next.js TDD (Framework Override)

Purpose
- Provide Next.js-specific TDD rules that extend and override:
  - Base TDD — [TDD Architecture](rules/generative/architecture/tdd/README.md)
  - TypeScript TDD — [TypeScript TDD](rules/generative/language/typescript/tdd.md)
- Precedence: This Next.js TDD framework override supersedes both Base and TypeScript TDD where directives differ.

Scope
- Applies to Next.js App Router apps (Server/Client Components, Route Handlers, Middleware) across Node and Edge runtimes.
- Integrates with Web Components usage and SSR/Streaming considerations.

Core TDD Workflow (inherits, Next.js specifics)
- Red → Green → Refactor with stage-gated, docs-first flow.
- Outside-in for features:
  - Start with acceptance/E2E (Playwright) for route behavior (SSR/streaming/hydration), then drive Route Handlers and components.
- Inside-out for pure logic (parsers, formatters, validators), then wrap with integration/acceptance.
- Behavior-first: test outcomes (status, HTML/text content, headers, cache behavior) not implementation details.

Recommended Tooling
- Unit/Integration: Vitest (preferred) or Jest
  - DOM testing: @testing-library/react for Client Components
- E2E: Playwright (preferred) for routes/flows/SSR-streaming checks
- Network mocking:
  - For Client tests: MSW
  - For Server-side unit/integration: mock global fetch or wrap in data-fetch helpers
- Coverage: c8/V8 in Vitest; enforce thresholds in CI
- Lint/Format: ESLint + Prettier; tsc type-check in CI

Project Structure (tests)
- app/ — pages, layouts, route handlers
- lib/ — shared logic; unit tests colocated or under test/
- test/setup.ts — test bootstrap (MSW for browser/node, fetch mocks)
- e2e/ — Playwright tests for routes/flows

Testing App Router Concepts

Server vs Client Components
- Server Components (default):
  - Test pure functions and data-fetch wrappers as unit tests
  - Avoid jsdom-only APIs; mock fetch/cache options
- Client Components:
  - Test with RTL in jsdom; user-event for realistic interactions
  - Ensure "use client" modules are isolated in tests

Route Handlers (app/segment/route.ts)
- Unit/integration:
  - Call exported HTTP methods (GET/POST…) directly
  - Create NextRequest with headers/cookies
  - Assert NextResponse: status, headers, body (JSON/text)
- Example
```ts
import { describe, it, expect } from 'vitest';
import { GET } from './route';
import { NextRequest } from 'next/server';

it('returns 200 with payload', async () => {
  const req = new NextRequest(new URL('http://localhost/api/hello'));
  const res = await GET(req);
  expect(res.status).toBe(200);
  const json = await res.json();
  expect(json).toEqual({ hello: 'world' });
});
```

Data Fetching and Caching
- Test cache semantics in unit/integration by asserting:
  - Cache-control headers (if set in Route Handlers)
  - Behavior when revalidate is configured (export revalidate; or fetch next: { revalidate, tags })
- For tag/path revalidation, prefer integration tests that simulate invocation of revalidatePath()/revalidateTag() and assert new content in E2E

Runtimes: Edge vs Node
- Unit/integration:
  - For Edge: avoid Node-only APIs in test subject; if unavoidable, mark those tests Node-only and document runtime selection
  - Use environment variables to gate runtime-specific branches and test both paths when relevant
- E2E:
  - Behavioral parity checked via Playwright; runtime differences are transparent to route testing

Middleware (middleware.ts)
- Unit:
  - Build NextRequest with URL/cookies/headers; assert NextResponse.next()/redirect()/rewrite() and headers
- Example
```ts
import { describe, it, expect } from 'vitest';
import middleware from '../middleware';
import { NextRequest } from 'next/server';

it('redirects anon user to login', () => {
  const req = new NextRequest(new URL('http://localhost/dashboard'));
  const res = middleware(req);
  expect(res.headers.get('location')).toBe('/login?next=/dashboard');
});
```

SSR/Streaming/Hydration
- E2E tests (Playwright) should:
  - Assert SSR markers: initial content visible without client JS (detectable text/DOM)
  - For streaming: assert progressive appearance of content (locator eventually visible)
  - For hydration: assert interactive behavior after load (buttons, forms)
- Client Component tests (RTL):
  - Avoid fragile timing; use findBy* queries; prefer user-event for interactions

Web Components Integration
- Server Components: render custom elements as static HTML; do not access element instance properties
- Client Components: attach imperative props in useEffect via ref; unit test with RTL; integration/E2E confirm behavior
- Avoid querying shadow internals; assert public behavior or ::part styling

Headers/Cookies in Tests
- Unit/integration (Route Handlers, Middleware):
  - Construct NextRequest with custom headers/cookies; assert transformations in NextResponse
- Client tests:
  - Do not access server-only headers/cookies; mock via MSW or test boundaries (Route Handler responses)

Cache/Tag Testing Strategy
- Unit: verify that fetch is called with correct cache/next options in data-fetch helpers
- Integration: call route handler and assert headers/content differences under different cache settings
- E2E: use revalidation endpoints/workflows to confirm content changes after invalidation

Fixtures and Test Data
- Keep fixtures typed; use builders for clarity (factory methods/functions)
- For complex JSON: store under test/fixtures/*.json; assert with partial matchers

Coverage and Gates (Next.js-specific)
- Enforce ≥ 80% lines/statements/functions; ≥ 70% branches via Vitest config
- Critical flows (auth, checkout, data mutation) must have acceptance coverage (Playwright)

CI Pipeline (example)
- Lint/Type-check: eslint . && tsc -p tsconfig.json --noEmit
- Unit/Integration: vitest run --coverage
- E2E: playwright test (install browsers first)
- Artifacts: coverage (lcov/html); junit xml optional; break on violations

Examples

- Route Handler unit
```ts
import { POST } from './route';
import { NextRequest } from 'next/server';

it('creates resource', async () => {
  const req = new NextRequest(new URL('http://localhost/api/orders'), {
    method: 'POST',
    body: JSON.stringify({ sku: 'ABC', qty: 2 }),
  } as any);
  const res = await POST(req);
  expect(res.status).toBe(201);
  expect(res.headers.get('location')).toMatch(/\/api\/orders\/\d+$/);
});
```

- Client Component (RTL)
```ts
import { render, screen } from '@testing-library/react';
import user from '@testing-library/user-event';
import { AddToCart } from './AddToCart';

it('increments on click', async () => {
  render(<AddToCart sku="ABC" />);
  await user.click(screen.getByRole('button', { name: /add to cart/i }));
  expect(screen.getByRole('status')).toHaveTextContent('1');
});
```

- E2E (Playwright) with SSR/hydration
```ts
import { test, expect } from '@playwright/test';

test('product page SSR, then hydrates and adds to cart', async ({ page }) => {
  await page.goto('/products/abc');
  await expect(page.getByRole('heading', { name: /abc/i })).toBeVisible(); // SSR
  await page.getByRole('button', { name: /add to cart/i }).click();        // hydrated
  await expect(page.getByRole('status')).toHaveTextContent('1');
});
```

LLM Interpretation Guidance (Next.js)
- Author/update failing tests first (unit/integration/E2E) based on Stage 1/2 docs; STOP to request approval before implementation.
- Choose the minimal appropriate scope:
  - Route Handler behavior → unit/integration at server
  - UI flow → Playwright E2E and RTL for Client Components
  - Caching/revalidation → unit for helper options, integration/E2E for effect
- Respect runtime constraints (Edge vs Node); guard Node-only APIs and test both paths if present.
- For Web Components, defer imperative props to Client Components and test with RTL/Playwright.

Superseded Base Sections (clarifications)
- Route Handlers/Middleware, SSR/Streaming/Hydration, runtime selection, and cache/revalidation specifics here supersede generic TypeScript/Base guidance for Next.js projects.

Routing and Related TDD
- Base TDD — [README](rules/generative/architecture/tdd/README.md)
- TypeScript TDD — [tdd.md](rules/generative/language/typescript/tdd.md)
- Web Components TDD — [tdd.md](rules/generative/frontend/webcomponents/tdd.md)