# React BDD (Framework Override)

Purpose
- Provide React-specific BDD rules that extend and override:
  - Base BDD — [BDD Architecture](rules/generative/architecture/bdd/README.md)
  - TypeScript BDD — [TypeScript BDD](rules/generative/language/typescript/bdd.md)
- Precedence: This React BDD framework override supersedes both the Base and TypeScript BDD where directives differ.

Scope
- Applies to React applications and libraries (CSR/SSR/SSG not using Next.js). For Next.js apps, see [Next.js BDD](rules/generative/frontend/nextjs/bdd.md).
- Coordinates with Web Components usage in React (custom elements, shadow DOM), and with design-system libraries.

BDD Workflow (inherits, React specifics)
- Discovery → Formulation → Automation
  - Discovery: collaborate on examples using project Glossary terms.
  - Formulation: write Gherkin features (Given/When/Then). Tag routes/components/domains for traceability.
  - Automation: implement step definitions using Playwright (UI) and fetch/HTTP clients (API), keeping steps domain-oriented and reusable.
- Use TDD for lower-level unit/integration tests (hooks, reducers, utilities). BDD acceptance drives outside-in behavior at user-flow boundaries.

Feature Files and Tagging
- tests/features/<domain>/<feature>.feature
- Tags for routing and traceability:
  - @ui or @api
  - @critical for must-pass flows
  - @route:/products/abc
  - @domain:Catalog
  - @component:ProductCard (optional)
  - @sequence:product-view (maps to docs/architecture/sequence-product-view.md)
- Steps should be user-centric (labels/roles/text), not React internals.

Tooling
- BDD runner: @cucumber/cucumber (cucumber-js)
- UI acceptance: Playwright (preferred)
- Component checks within BDD: keep to user flows via Playwright; use React Testing Library (RTL) under TDD for component-level specs
- Network mocking: MSW (Mock Service Worker) for Node/Browser
- Lint/Format/Types: ESLint + Prettier + tsc in CI
- Reports: cucumber JSON/HTML published in CI

Project Layout (suggested)
- tests/
  - features/<domain>/<feature>.feature
  - steps/<domain>/*.steps.ts
  - support/world.ts, support/hooks.ts, support/msw.ts
  - pages/** (page objects as thin Playwright wrappers)
  - fixtures/** (typed data)
- src/** — app/library code (unit/integration tests under TDD)
- e2e/ (optional) — Playwright specs, if shared

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

export class ReactWorld extends World {
  browser!: Browser;
  page!: Page;
}
setWorldConstructor(ReactWorld);

// tests/support/hooks.ts
import { BeforeAll, AfterAll, Before, After } from '@cucumber/cucumber';
import { chromium } from 'playwright';
import { ReactWorld } from './world';

let browser: import('playwright').Browser;

BeforeAll(async () => { browser = await chromium.launch(); });
AfterAll(async () => { await browser?.close(); });

Before<ReactWorld>(async function () {
  this.page = await browser.newPage();
});
After<ReactWorld>(async function () {
  await this.page?.close();
});
```

UI Steps (Playwright) — Examples
```ts
// tests/steps/catalog.ui.steps.ts
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('I am on the {string} page', async function (_: string) {
  await this.page.goto('/products/abc');
});

When('I add the product to the cart', async function () {
  await this.page.getByRole('button', { name: /add to cart/i }).click();
});

Then('the cart count should be {int}', async function (count: number) {
  await expect(this.page.getByRole('status')).toHaveText(new RegExp(`^${count}$`));
});
```

API Steps (fetch/undici) — Examples
```ts
// tests/steps/orders.api.steps.ts
import { When, Then } from '@cucumber/cucumber';
import { strict as assert } from 'node:assert';

let res: Response;

When('I create an order with sku {string} and qty {int}', async function (sku: string, qty: number) {
  res = await fetch(`${this.parameters.baseUrl}/api/orders`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ sku, qty })
  });
});

Then('the response status should be {int}', async function (status: number) {
  assert.equal(res.status, status);
});
```

MSW Strategy
- For BDD runs that mock the backend, prefer MSW in Node with onUnhandledRequest: 'error' to ensure all network is declared.
- For end-to-end parity, run a real backend in a separate CI job or use Testcontainers-based services.

SSR/Hydration (non-Next)
- If SSR is used, include scenarios that:
  - Assert SSR content before client JS (static text visible on first paint)
  - Assert interactive behavior after hydration (buttons/forms work)
- Keep timing assertions robust: prefer Playwright locators with auto-wait and findBy* patterns.

Web Components in React
- When using custom elements:
  - Assert public contract (attributes/properties/events/slots/parts)
  - Steps remain user-centric (visible text/roles). Avoid shadow DOM queries
- Imperative props: attach via refs in Client-only components; BDD should assert visible behavior not internal effects

Living Documentation
- Keep features aligned with Glossary terms; map @sequence tags to sequence diagrams in docs/architecture/.
- Publish cucumber HTML/JSON; index significant features in docs/PROMPT_REFERENCE.md.

CI Pipeline (example)
- Lint/Type-check: eslint . && tsc --noEmit
- Unit/Integration (TDD): vitest run --coverage
- BDD acceptance: cucumber-js (publish html/json reports)
- Break build on undefined/pending steps; ensure determinism (no flaky retries)

Interplay with TDD
- BDD acceptance defines behavior; TDD tests drive hook/reducer/component internals.
- Keep BDD focused on user flows; push complexity into TDD layers for speed and isolation.

LLM Interpretation Guidance (React BDD)
- Stage 1/2: draft/refine features and STOP for approval before glue code.
- Write reusable, domain-named steps; avoid exposing component internals in step code.
- Choose minimal scope: API-only vs UI flows. For UI, use Playwright; for component-level, defer to TDD with RTL.

Superseded Base Sections (clarifications)
- Tooling specifics (cucumber-js, Playwright, MSW) supersede Base BDD for React.
- SSR/hydration notes here supersede generic guidance for non-Next SSR React apps.

Routing and Related BDD/TDD
- Base BDD — [README](rules/generative/architecture/bdd/README.md)
- TypeScript BDD — [bdd.md](rules/generative/language/typescript/bdd.md)
- React TDD — [tdd.md](rules/generative/language/react/tdd.md)
- Web Components BDD — [bdd.md](rules/generative/frontend/webcomponents/bdd.md)