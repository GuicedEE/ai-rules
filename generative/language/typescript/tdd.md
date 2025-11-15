# TypeScript TDD (Language Override)

Purpose
- Provide TypeScript-specific TDD rules that extend and override the Base TDD architecture.
- Precedence: TypeScript TDD supersedes [Base TDD](rules/generative/architecture/tdd/README.md) for TypeScript projects; framework-specific TDD (Angular, React, Vue, Next.js, Nuxt, Angular Awesome, Web Components) supersedes this file.

Scope
- Applies to Node- and browser-targeted TypeScript libraries/apps.
- Coordinates with topic rules (Angular, React, Vue, Next.js, Nuxt, Web Components) where tests touch framework surfaces.

Precedence and Links
- Base TDD (general) → [TDD Architecture](rules/generative/architecture/tdd/README.md)
- Language override (this file) → TypeScript guidance (supersedes base where it conflicts)
- Framework overrides (if any) → Supersede both for framework concerns

Core TDD Workflow (inherits base)
- Red → Green → Refactor
- Prefer Outside-in for product/API features; Inside-out for algorithmic/core logic.
- Behavior-first tests; avoid specifying private internals or framework implementation details.

Recommended Tooling
- Unit/Integration test runner: Vitest (preferred) or Jest
  - Vitest advantages: fast, inline snapshots, watch mode, TS-first, jsdom/node environments
- DOM/component testing (framework-agnostic): @testing-library/dom
- HTTP/network mocking: MSW (Mock Service Worker) — browser/node adapters
- End-to-End (E2E): Playwright (preferred) or Cypress
- Coverage: c8 (V8 coverage) via Vitest; alternative nyc/istanbul for Jest
- Lint/Format: ESLint + Prettier; type-checking with tsc in CI

Project Structure (suggested)
- src/ — production code
- test/ or colocated tests: src/**/*.test.ts, src/**/*.spec.ts
- integration tests: test/integration/**/*.test.ts (or tag-based separation)
- e2e tests: e2e/**/*.spec.ts (Playwright project)

Vitest Configuration (example)
```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node', // 'jsdom' for browser/DOM tests
    globals: true,
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov', 'html'],
      thresholds: { lines: 80, functions: 80, branches: 70, statements: 80 },
    },
    pool: 'threads',
    watch: false,
  },
});
```

Test Taxonomy (TypeScript adaptation)
- Unit tests (largest): deterministic, pure logic, no IO/sleep; fake time and randomness
  - Use vi.useFakeTimers(), vi.spyOn(), dependency injection for clock/random
- Integration tests (moderate): verify boundary adapters (HTTP/DB/external APIs)
  - Use MSW for HTTP; Testcontainers from Node if hitting real services
- Acceptance/E2E (smallest): user flows, routing, SSR/hydration for framework apps
  - Use Playwright; stable data-testid selectors; test critical paths end-to-end

Coverage and Quality Gates
- Target ≥ 80% lines/statements/functions; ≥ 70% branches (project may raise thresholds).
- Enforce in CI via Vitest coverage thresholds (see config).
- Mutation testing optional (Stryker), recommended for critical packages.

Test Data, Time, and Isolation
- Unit:
  - vi.useFakeTimers(); vi.setSystemTime(new Date(...))
  - Inject seeded RNG dependency or use deterministic generators
  - Keep fixtures as small, typed objects; prefer builders for clarity
- Integration:
  - MSW handlers for HTTP; ensure handler lifecycles per-test to avoid bleed
  - If using containers, scope lifecycle per-file or per-suite; run migrations on setup
- Acceptance:
  - Seed known fixtures; reset state between tests; run Playwright projects per browser if necessary

Node vs Browser Targets
- Node (default): environment: 'node', no DOM APIs; use undici for fetch where needed
- Browser/DOM: environment: 'jsdom', use @testing-library/dom
- Cross-env libraries: split tests by environment or parametrize with describe.each

HTTP Mocking with MSW (example)
```ts
// test/setup.ts
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

export const server = setupServer(
  http.get('https://api.example.com/users/:id', ({ params }) =>
    HttpResponse.json({ id: params.id, name: 'Jane' })
  )
);

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

Unit Test Example (Vitest)
```ts
import { describe, it, expect } from 'vitest';
import { sum } from './sum';

describe('sum()', () => {
  it('adds two numbers', () => {
    expect(sum(2, 3)).toBe(5);
  });

  it('overflows to Infinity on very large inputs', () => {
    expect(sum(Number.MAX_VALUE, Number.MAX_VALUE)).toBe(Number.POSITIVE_INFINITY);
  });
});
```

Integration Test Example (MSW)
```ts
import { describe, it, expect } from 'vitest';
import { server } from '../test/setup';
import { http, HttpResponse } from 'msw';
import { getUser } from './client';

describe('getUser()', () => {
  it('returns the user from API', async () => {
    const user = await getUser('42');
    expect(user).toEqual({ id: '42', name: 'Jane' });
  });

  it('handles 404s', async () => {
    server.use(http.get('https://api.example.com/users/:id', () => HttpResponse.json({}, { status: 404 })));
    await expect(getUser('missing')).rejects.toThrow(/404/);
  });
});
```

E2E Example (Playwright)
```ts
// e2e/home.spec.ts
import { test, expect } from '@playwright/test';

test('home page shows greeting', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: /welcome/i })).toBeVisible();
});
```

CI Integration (matrix)
- Install + type-check + unit
  - pnpm i --frozen-lockfile
  - pnpm typecheck
  - pnpm test:unit --coverage
- Integration
  - pnpm test:integration (spin MSW or containers; export CI=1 to hard-fail on unhandled)
- E2E (Playwright)
  - pnpm exec playwright install --with-deps
  - pnpm test:e2e
- Artifacts: coverage lcov/html uploaded; junit xml optional for CI annotations
- Break build on coverage violations or test failures; do not retry flaky tests

Framework Interop and Overrides
- Angular (framework override) — use Angular TestBed, Testing Library for Angular, harnesses, and SSR/hydration guards for web components; see [Angular TDD](rules/generative/language/angular/tdd.md)
- React (framework override) — use React Testing Library, user-event, and SSR nuances; see [React TDD](rules/generative/language/react/tdd.md)
- Vue (framework override) — use Vue Test Utils, Testing Library Vue, Pinia test harness, and Composition API exports; see [Vue TDD](rules/generative/language/vue/tdd.md)
- Next.js (framework override) — Server/Client Components, Route Handlers, caching; see [Next.js TDD](rules/generative/frontend/nextjs/tdd.md)
- Nuxt (framework override) — Hybrid SSR/SSG, Nitro server routes, runtime config; see [Nuxt TDD](rules/generative/frontend/nuxt/tdd.md)
- Web Components (topic supplement) — DOM-level tests with @testing-library/dom, customElements, events, slots, CSS parts; see [Web Components TDD](rules/generative/frontend/webcomponents/tdd.md)
- Angular Awesome (plugin supplement) — directive wrappers and wa-* components; see [Angular Awesome TDD](rules/generative/frontend/angular-awesome/tdd.md)

SSR/Hydration Considerations (brief)
- If SSR present (Next.js/Nuxt/Angular Universal):
  - Prefer acceptance tests that verify SSR output and hydration success
  - Use DOM content checks that are resilient to streaming; avoid brittle timing
  - For Web Components, prefer Declarative Shadow DOM checks where supported, otherwise assert post-hydration markers

LLM Interpretation Guidance (TypeScript)
- Author/update failing tests first (Vitest/Jest), ask approval (STOP gate), then implement to green, then refactor.
- Choose the appropriate environment (node or jsdom) and explicitly mock network with MSW when needed.
- Avoid testing private internals; assert public behavior and contract shapes (e.g., JSON via partial matchers).
- For frameworks, defer to their TDD override documents; do not mix patterns from different frameworks in the same package unless documented.

Superseded Base Sections (clarifications)
- Coverage thresholds and tool specifics here supersede the Base TDD defaults for TypeScript.
- Testing toolchain enumerated (Vitest/MSW/Playwright) supersedes base generic mentions.

See Also
- Base TDD — [README](rules/generative/architecture/tdd/README.md)
- Angular TDD — [tdd.md](rules/generative/language/angular/tdd.md)
- React TDD — [tdd.md](rules/generative/language/react/tdd.md)
- Vue TDD — [tdd.md](rules/generative/language/vue/tdd.md)
- Next.js TDD — [tdd.md](rules/generative/frontend/nextjs/tdd.md)
- Nuxt TDD — [tdd.md](rules/generative/frontend/nuxt/tdd.md)
- Web Components TDD — [tdd.md](rules/generative/frontend/webcomponents/tdd.md)
- Angular Awesome TDD — [tdd.md](rules/generative/frontend/angular-awesome/tdd.md)
