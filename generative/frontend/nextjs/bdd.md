# Next.js BDD (Framework Override)

Purpose
- Provide Next.js-specific BDD rules that extend and override:
  - Base BDD — [BDD Architecture](rules/generative/architecture/bdd/README.md)
  - TypeScript BDD — [TypeScript BDD](rules/generative/language/typescript/bdd.md)
- Precedence: This Next.js BDD framework override supersedes both Base and TypeScript BDD where directives differ.

Scope
- Applies to Next.js App Router apps (Server/Client Components, Route Handlers, Middleware) across Node and Edge runtimes.
- Integrates SSR/Streaming/Hydration and data caching/revalidation semantics into executable specifications.
- For React (non-Next) apps, see [React BDD](rules/generative/language/react/bdd.md).

BDD Workflow (inherits, Next.js specifics)
- Discovery → Formulation → Automation
  - Discovery: use domain language (Glossary) to define behavior for routes, handlers, and middleware.
  - Formulation: author Gherkin features that cover SSR output, streaming, hydration, and cache behavior (headers, revalidation).
  - Automation: implement step definitions using Playwright for UI flows and direct invocation/tests for Route Handlers and Middleware; keep steps domain-oriented.
- Use TDD for lower-level unit/integration tests (helpers, data-fetch wrappers); BDD acceptance drives outside-in.

Feature Files and Tagging
- tests/features/<domain>/<feature>.feature
- Tag scenarios for routing/traceability:
  - @ui, @api, @critical
  - @route:/products/[id]
  - @runtime:edge or @runtime:node
  - @revalidate:60 or @dynamic:force-dynamic
  - @sequence:product-view (maps to docs/architecture/sequence-product-view.md)
  - @domain:Catalog

Tooling
- BDD runner: @cucumber/cucumber (cucumber-js)
- UI acceptance: Playwright (preferred)
- Unit/Integration (supporting): Vitest
- Network mocking (client tests): MSW; server-side handlers tested via direct calls/mocks to global fetch
- Lint/Format/Types: ESLint + Prettier + tsc in CI
- Reports: cucumber JSON/HTML published in CI

Project Layout (suggested)
- tests/
  - features/<domain>/<feature>.feature
  - steps/ui/*.steps.ts — Playwright
  - steps/api/*.steps.ts — route handler invocation
  - support/world.ts, support/hooks.ts, support/msw.ts
  - pages/** page objects (thin)
  - fixtures/** typed data
- app/** — application code (Route Handlers, middleware, components)
- e2e/ (optional) — Playwright specs used by steps

Cucumber Config (example)
```js
// cucumber.mjs
export default {
  default: {
    require: [
      'tests/support/world.ts',
      'tests/support/hooks.ts',
      'tests/steps/**/*.steps.ts'
    ],
    publishQuiet: true,
    format: [
      'progress-bar',
      'html:reports/cucumber-report.html',
      'json:reports/cucumber.json',
      'summary'
    ],
    parallel: 2,
    paths: ['tests/features/**/*.feature'],
    worldParameters: { baseUrl: 'http://localhost:3000' }
  }
};
```

Support: World, Hooks, Playwright
```ts
// tests/support/world.ts
import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { Browser, Page } from 'playwright';

export class NextWorld extends World {
  browser!: Browser;
  page!: Page;
}
setWorldConstructor(NextWorld);

// tests/support/hooks.ts
import { BeforeAll, AfterAll, Before, After } from '@cucumber/cucumber';
import { chromium } from 'playwright';
import { NextWorld } from './world';

let browser: import('playwright').Browser;

BeforeAll(async () => { browser = await chromium.launch(); });
AfterAll(async () => { await browser?.close(); });

Before<NextWorld>(async function () {
  this.page = await browser.newPage();
});
After<NextWorld>(async function () {
  await this.page?.close();
});
```

Route Handler Steps (unit/integration)
```ts
// tests/steps/handlers.api.steps.ts
import { When, Then } from '@cucumber/cucumber';
import { NextRequest } from 'next/server';
import { expect } from 'vitest';

let res: Response;

When('I GET {string}', async function (path: string) {
  const { GET } = await import(`../../app${path}/route.ts`);
  const req = new NextRequest(new URL(`http://localhost${path}`));
  res = await GET(req as any);
});

Then('the response status should be {int}', async function (status: number) {
  expect(res.status).toBe(status);
});
```

Middleware Steps
```ts
// tests/steps/middleware.steps.ts
import { When, Then } from '@cucumber/cucumber';
import { NextRequest } from 'next/server';
import middleware from '../../middleware';
import { strict as assert } from 'node:assert';

let mwRes: Response;

When('I navigate to {string}', async function (path: string) {
  const req = new NextRequest(new URL(`http://localhost${path}`));
  mwRes = middleware(req) as any;
});

Then('I should be redirected to {string}', function (location: string) {
  assert.equal(mwRes.headers.get('location'), location);
});
```

UI Steps (Playwright)
```ts
// tests/steps/catalog.ui.steps.ts
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('I visit {string}', async function (path: string) {
  await this.page.goto(path);
});

Then('I should see SSR content {string}', async function (text: string) {
  await expect(this.page.getByText(new RegExp(text, 'i'))).toBeVisible();
});

When('I click the {string} button', async function (label: string) {
  await this.page.getByRole('button', { name: new RegExp(label, 'i') }).click();
});

Then('the counter should show {int}', async function (n: number) {
  await expect(this.page.getByRole('status')).toHaveText(new RegExp(`^${n}$`));
});
```

SSR/Streaming/Hydration Steps
- SSR: assert text visible on initial paint (before client JS)
- Streaming: assert progressive appearance of content (Playwright locator waits)
- Hydration: assert interactive behavior post-hydration (buttons/forms work)

Cache/Revalidation Steps
- Tag scenarios with @revalidate:seconds or @dynamic:force-dynamic
- Steps assert:
  - Cache-control headers on responses (Route Handlers)
  - Behavior after invoking revalidatePath()/revalidateTag() (via test helper endpoint or admin route)
  - Fresh content is served after invalidation

Runtimes (Edge vs Node)
- Tag @runtime:edge or @runtime:node
- Guard Node-only APIs in code; in steps, ensure scenarios validate behavior for each runtime where applicable

Web Components Integration
- In UI steps, assert public contract (visible behavior, attributes reflected in DOM, events resulting in UI updates)
- Do not pierce shadow DOM; rely on roles/text and ::part styling effects

Living Documentation
- Link features and tags to docs/architecture/ diagrams in docs/PROMPT_REFERENCE.md
- Publish cucumber HTML/JSON; include links in README/Guides

CI Pipeline (example)
- Lint/Type-check: eslint . && tsc --noEmit
- Unit/Integration: vitest run --coverage
- BDD acceptance: cucumber-js (publish reports)
- Fail on undefined/pending steps; no flaky retries

Interplay with TDD
- BDD acceptance defines route-level and end-user behavior
- TDD unit/integration tests drive handler logic, helpers, and client components beneath

LLM Interpretation Guidance (Next.js BDD)
- Stage 1/2: draft/refine features; STOP for approval before implementing steps
- Choose minimal scope (handler vs middleware vs UI)
- Respect runtime constraints; mock network where applicable; prefer Playwright for UI
- For caching scenarios, validate both headers and observable content changes

Superseded Base Sections (clarifications)
- Route Handler/Middleware direct invocation, SSR/Streaming/Hydration, run-times, and cache/revalidation specifics supersede Base and TypeScript BDD in Next.js projects.

Routing and Related BDD/TDD
- Base BDD — [README](rules/generative/architecture/bdd/README.md)
- TypeScript BDD — [bdd.md](rules/generative/language/typescript/bdd.md)
- Next.js TDD — [tdd.md](rules/generative/frontend/nextjs/tdd.md)