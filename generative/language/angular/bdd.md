# Angular BDD (Framework Override)

Purpose
- Provide Angular-specific BDD rules that extend and override:
  - Base BDD — [BDD Architecture](rules/generative/architecture/bdd/README.md)
  - TypeScript BDD — [TypeScript BDD](rules/generative/language/typescript/bdd.md)
- Precedence: This Angular BDD framework override supersedes both the Base and TypeScript BDD where directives differ.

Scope
- Applies to Angular 17/19/20+ projects using the modular base + version override model:
  - Base rules — [angular.md](rules/generative/language/angular/angular.md)
  - Version overrides — [angular-17.rules.md](rules/generative/language/angular/angular-17.rules.md), [angular-19.rules.md](rules/generative/language/angular/angular-19.rules.md), [angular-20.rules.md](rules/generative/language/angular/angular-20.rules.md)
- Integrates with Angular Awesome (plugin) and Web Components consumption where present.

BDD Workflow (inherits, Angular specifics)
- Discovery → Formulation → Automation
  - Discovery: collaborate on examples using the project Glossary terms.
  - Formulation: express features as Gherkin scenarios (Given/When/Then), link with tags to routes and components.
  - Automation: implement steps (glue) that exercise UI flows via Playwright and API via HTTP clients; keep steps domain-oriented.
- BDD acceptance drives outside-in behavior; Angular unit/component tests (TDD) support internals beneath.

Feature Files and Tagging
- Place features by domain:
  - tests/features/<domain>/<feature>.feature
- Use tags for routing and traceability:
  - @ui, @api, @critical
  - @route:/orders/new
  - @component:MyComponent (optional, when component-specific)
  - @sequence:orders-create (maps to docs/architecture/sequence-orders-create.md)
  - @domain:Orders
- Keep scenario steps user-centric (labels/roles/visible text), not framework internals.

Tooling
- BDD runner: @cucumber/cucumber (cucumber-js)
- UI acceptance: Playwright (preferred)
- Component-level checks within BDD: prefer user-event style via Playwright; for lower-level component specs use Angular Testing Library in TDD (unit/integration) rather than BDD
- Network mocking: MSW for realistic HTTP behavior (Node/Browser)
- Lint/Format/Types: ESLint + Prettier + ng tsc/tsc in CI
- Reports: cucumber JSON/HTML, published in CI

Project Layout (suggested)
- tests/
  - features/<domain>/<feature>.feature
  - steps/<domain>/*.steps.ts
  - support/world.ts, support/hooks.ts, support/msw.ts
  - pages/** (page objects as thin Playwright wrappers)
  - fixtures/** (typed data)
- src/app/** — application code (unit/component tests live here, TDD)
- e2e/ (optional): if you keep separate Playwright specs leveraged by steps

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
    worldParameters: { baseUrl: 'http://localhost:4200' }
  }
};
```

Support: World, Hooks, and Playwright
```ts
// tests/support/world.ts
import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { Browser, Page } from 'playwright';

export class NgWorld extends World {
  browser!: Browser;
  page!: Page;
}
setWorldConstructor(NgWorld);

// tests/support/hooks.ts
import { BeforeAll, AfterAll, Before, After } from '@cucumber/cucumber';
import { chromium } from 'playwright';
import { NgWorld } from './world';

let browser: import('playwright').Browser;

BeforeAll(async () => { browser = await chromium.launch(); });
AfterAll(async () => { await browser?.close(); });

Before<NgWorld>(async function () {
  this.page = await browser.newPage();
});
After<NgWorld>(async function () { await this.page?.close(); });
```

UI Steps (Playwright) — Examples
```ts
// tests/steps/orders.ui.steps.ts
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('I am on the {string} page', async function (_: string) {
  await this.page.goto('/orders/new');
});

When('I submit the {string} form', async function (_: string) {
  await this.page.getByRole('button', { name: /create order/i }).click();
});

Then('I should see a success message {string}', async function (msg: string) {
  await expect(this.page.getByText(new RegExp(msg, 'i'))).toBeVisible();
});
```

API Steps — Examples
```ts
// tests/steps/orders.api.steps.ts
import { When, Then } from '@cucumber/cucumber';
import { strict as assert } from 'node:assert';

let res: Response;

When('I create an order with sku {string} and qty {int}', async function (sku: string, qty: number) {
  res = await fetch(`http://localhost:4200/api/orders`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ sku, qty })
  });
});

Then('the response status should be {int}', async function (status: number) {
  assert.equal(res.status, status);
});
```

SSR/Hydration (Angular Universal)
- Include scenarios that:
  - Assert SSR content pre-hydration (static text visible without client JS)
  - Assert interactive behavior post-hydration (buttons, forms)
  - Avoid brittle timing; rely on findBy* or Playwright locator waiting

Angular Awesome and Web Components
- When using wa-* components:
  - Assert public contract (attributes/properties/events/slots/parts)
  - Prefer user-centric steps (clicking labels, reading messages)
  - Do not pierce shadow DOM; rely on visible outcomes and ::part styling for state
- For wrappers: acceptance steps should exercise the wrapper via visible UI; detailed wrapper contract belongs in TDD component tests

Forms and Routing
- Steps should refer to labels and roles rather than form control names
- Use navigation assertions (URL, title, heading) and guard/redirect checks via user-visible outcomes

MSW Strategy
- Prefer MSW in Node for API steps during BDD runs to keep determinism
- For full-stack flows, run backend in CI job or use Testcontainers in a separate service job

Living Documentation
- Keep feature files aligned with Glossary terms
- Publish cucumber HTML/JSON; link to docs/architecture/ (C4/sequence/ERD) in README or PROMPT_REFERENCE.md

LLM Interpretation Guidance (Angular BDD)
- Stage 1/2: author/refine features and STOP for approval before step code
- Steps must be domain-worded; no Angular internals
- Choose minimal scope: API-only or UI; UI via Playwright; keep steps reusable
- For deeper component rules (inputs, outputs, harness-level checks), prefer TDD unit/component tests rather than BDD

Superseded Base Sections (clarifications)
- This document fixes Playwright + cucumber-js as the primary BDD toolchain for Angular UI acceptance, superseding generic base lists where they differ.
- SSR/hydration and Web Components notes supersede base in Angular contexts.

Routing and Related BDD/TDD
- Base BDD — [README](rules/generative/architecture/bdd/README.md)
- TypeScript BDD — [bdd.md](rules/generative/language/typescript/bdd.md)
- Angular TDD — [tdd.md](rules/generative/language/angular/tdd.md)
- Angular Awesome BDD — [bdd.md](rules/generative/frontend/angular-awesome/bdd.md)
- Web Components BDD — [bdd.md](rules/generative/frontend/webcomponents/bdd.md)