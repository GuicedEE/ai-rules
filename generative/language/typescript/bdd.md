# TypeScript BDD (Language Override)

Purpose
- Provide TypeScript-specific BDD rules that extend and override the Base BDD architecture.
- Precedence: TypeScript BDD supersedes [BDD Architecture](rules/generative/architecture/bdd/README.md) for TypeScript projects; framework-specific BDD (Angular, React, Vue, Next.js, Nuxt, Angular Awesome, Web Components) supersedes this file.

Scope
- Applies to Node and browser targets.
- Coordinates with Angular/React/Vue/Next.js/Nuxt/Web Components where scenarios exercise those surfaces.

Precedence and Links
- Base BDD → [BDD Architecture](rules/generative/architecture/bdd/README.md)
- Language override (this file) → TypeScript specifics
- Framework overrides → Supersede both for framework concerns

Core BDD Workflow (inherits base)
- Discovery → Formulation → Automation with executable Gherkin specs.
- Use domain language from the Glossary; scenarios map to C4/sequence/ERD via tags.
- BDD drives outside-in behavior; use TDD for unit/integration beneath.

Project Structure (suggested)
- tests/
  - features/<domain>/<feature>.feature
  - steps/<domain>/*.steps.ts (glue)
  - support/world.ts, support/hooks.ts
  - fixtures/**, clients/**, pages/** (support code)
- e2e/ for Playwright tests reused by steps (optional)
- vitest for unit/integration (separate from cucumber run)

Tooling
- BDD runner: @cucumber/cucumber (cucumber-js)
- E2E UI: Playwright (preferred)
- Network mocking: MSW (Node/Browser adapters)
- Unit/Integration: Vitest
- Coverage: c8/V8 (via Vitest) for code-level coverage; cucumber itself is for acceptance, not coverage metrics
- Lint/Format/Types: ESLint + Prettier + tsc in CI

Cucumber Config (examples)

cucumber.mjs
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
    worldParameters: {
      baseUrl: 'http://localhost:3000'
    }
  }
};
```

package.json scripts
```json
{
  "scripts": {
    "bdd": "cucumber-js -r ts-node/register",
    "test:unit": "vitest run --coverage"
  }
}
```

Playwright integration for steps
- Either run Playwright via its test runner and call from steps through a shared context, or launch a single browser in BeforeAll and attach to world.
- Keep browser lifecycle deterministic; fail on flakiness.

Support: World and hooks (sketch)
```ts
// tests/support/world.ts
import { setWorldConstructor, World } from '@cucumber/cucumber';
import { Browser, chromium, Page } from 'playwright';

export class CustomWorld extends World {
  browser!: Browser;
  page!: Page;
}

setWorldConstructor(CustomWorld);

// tests/support/hooks.ts
import { BeforeAll, AfterAll, Before, After } from '@cucumber/cucumber';
import { chromium } from 'playwright';
import { CustomWorld } from './world';

let browser: import('playwright').Browser;

BeforeAll(async function () {
  browser = await chromium.launch();
});

AfterAll(async function () {
  await browser?.close();
});

Before<CustomWorld>(async function () {
  this.browser = browser;
  this.page = await browser.newPage();
});

After<CustomWorld>(async function () {
  await this.page?.close();
});
```

Step Definitions (glue) examples

UI flow (Playwright)
```ts
// tests/steps/orders.ui.steps.ts
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('I am on the {string} page', async function (pageName: string) {
  await this.page.goto('/orders/new');
});

When('I submit the {string} form', async function (formName: string) {
  await this.page.getByRole('button', { name: /create order/i }).click();
});

Then('I should see a success message {string}', async function (msg: string) {
  await expect(this.page.getByText(new RegExp(msg, 'i'))).toBeVisible();
});
```

API flow (undici/fetch)
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

MSW integration (Node)
```ts
// tests/support/msw.ts
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';
export const server = setupServer(
  http.post('http://localhost:3000/api/orders', async () => {
    return HttpResponse.json({ id: 1 }, { status: 201 });
  })
);
// in hooks
import { BeforeAll, AfterAll, After } from '@cucumber/cucumber';
import { server } from './msw';

BeforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
After(() => server.resetHandlers());
AfterAll(() => server.close());
```

Feature File Example
```gherkin
Feature: Create orders

  @ui @route:/orders/new @critical
  Scenario: Create order with valid data
    Given I am on the "New Order" page
    And I enter "ABC" into the "SKU" field
    And I enter "2" into the "Quantity" field
    When I submit the "Create Order" form
    Then I should see a success message "Order created"
```

Tags and traceability
- Use tags to map scenarios to components/routes/domains:
  - @ui/@api, @critical, @route:/orders/new, @domain:Orders, @sequence:orders-create
- Maintain tag→file mapping in docs/PROMPT_REFERENCE.md.

CI pipeline (suggested)
- Lint/Type-check: eslint . && tsc --noEmit
- Unit/Integration: vitest run --coverage
- BDD acceptance: cucumber-js (publish html/json to reports/)
- Fail on undefined/pending steps; archive reports; ensure determinism.

SSR/Hydration and Web Components
- For SSR (Next.js/Nuxt/Angular Universal), include steps that assert SSR content present before hydration.
- For Web Components, assert public contract (attributes/properties/events/slots/parts); avoid shadow internals.

LLM Interpretation Guidance (TypeScript BDD)
- In Stage 1/2: write or adjust features; STOP for approval before implementing steps.
- Glue code must use domain wording; do not leak implementation details.
- Choose minimal scope: API-only vs UI; keep steps reusable and decoupled.
- Use MSW for network realism and determinism; avoid custom ad-hoc mocks where possible.

Superseded Base Sections (clarifications)
- Tooling specifics (cucumber-js, Playwright, MSW) supersede Base BDD generic lists for TypeScript.
- Project layout, config, and CI ordering as above supersede base where applicable.

See Also
- Base BDD — [README](rules/generative/architecture/bdd/README.md)
- TypeScript TDD — [tdd.md](rules/generative/language/typescript/tdd.md)
- Angular BDD — [bdd.md](rules/generative/language/angular/bdd.md)
- React BDD — [bdd.md](rules/generative/language/react/bdd.md)
- Vue BDD — [bdd.md](rules/generative/language/vue/bdd.md)
- Next.js BDD — [bdd.md](rules/generative/frontend/nextjs/bdd.md)
- Nuxt BDD — [bdd.md](rules/generative/frontend/nuxt/bdd.md)
- Web Components BDD — [bdd.md](rules/generative/frontend/webcomponents/bdd.md)
- Angular Awesome BDD — [bdd.md](rules/generative/frontend/angular-awesome/bdd.md)
