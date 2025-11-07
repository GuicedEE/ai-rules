# Angular Awesome BDD (Plugin Supplement and Override)

Purpose
- Provide Angular Awesome–specific BDD guidance for wa-* custom elements used directly or via Angular standalone directive wrappers.
- Precedence and supersedence:
  - Base BDD — [BDD Architecture](rules/generative/architecture/bdd/README.md)
  - TypeScript BDD — [TypeScript BDD](rules/generative/language/typescript/bdd.md)
  - Angular BDD — [Angular BDD](rules/generative/language/angular/bdd.md)
  - Angular Awesome BDD (this file) — supersedes the above where wrapper/wa-* specifics differ.

Scope
- Applies when using Web Awesome components (wa-*) inside Angular templates, with or without thin directive wrappers that mirror attributes/events.
- Focuses on acceptance behavior across:
  - Attribute/property bridging (Angular @Input() → custom element attributes/properties)
  - Event bridging (custom events wa-* → Angular Output()s such as blurEvent/focusEvent)
  - Slots, CSS parts, and CSS custom property mappings
  - SSR/hydration constraints with custom elements and Angular Universal

BDD Workflow (inherits)
- Discovery → Formulation → Automation, with stage-gated, docs-first flow.
- Outside-in recommended:
  - Start with acceptance specifications (Gherkin + Playwright) for flows using wa-* components.
  - Support with component/service integration tests (Angular TestBed) and unit tests (TDD) beneath acceptance.
- Keep steps domain-oriented; avoid framework/private implementation details.

Feature Files and Tagging
- tests/features/<domain>/<feature>.feature
- Tags for traceability:
  - @ui or @api, @critical
  - @route:/orders/new
  - @component:wa-button (optional when component-proximate)
  - @sequence:orders-create (maps to docs/architecture/sequence-orders-create.md)
  - @domain:Orders
  - Optional: @wa-slot:prefix, @wa-event:wa-finish (contract focus)

Tooling
- BDD runner: @cucumber/cucumber (cucumber-js)
- UI acceptance: Playwright (preferred)
- Network mocking: MSW (Node/Browser), or HttpClientTestingModule for integration tests (not BDD)
- Types/Lint/Format: tsc + ESLint + Prettier in CI
- Reports: cucumber JSON/HTML published in CI; fail on undefined/pending steps

Project Layout (suggested)
- tests/
  - features/<domain>/<feature>.feature
  - steps/<domain>/*.steps.ts
  - support/world.ts, support/hooks.ts, support/msw.ts
  - pages/** (thin Playwright page objects)
  - fixtures/** (typed data)
- src/app/** — application code (use Angular TDD for unit/component specs)
- e2e/ (optional): Playwright specs if shared by steps

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

Support: World and Hooks (Playwright)
```ts
// tests/support/world.ts
import { setWorldConstructor, World } from '@cucumber/cucumber';
import type { Browser, Page } from 'playwright';

export class WaWorld extends World {
  browser!: Browser;
  page!: Page;
}
setWorldConstructor(WaWorld);

// tests/support/hooks.ts
import { BeforeAll, AfterAll, Before, After } from '@cucumber/cucumber';
import { chromium } from 'playwright';
import { WaWorld } from './world';

let browser: import('playwright').Browser;

BeforeAll(async () => { browser = await chromium.launch(); });
AfterAll(async () => { await browser?.close(); });

Before<WaWorld>(async function () {
  this.page = await browser.newPage();
});
After<WaWorld>(async function () {
  await this.page?.close();
});
```

Step Design Guidelines (wa-* specifics)
- Attribute vs Property Bridging
  - Treat Angular boolean inputs as properties on the custom element (not string attributes).
  - Attribute-equivalent inputs should set attributes on the host element; JS-only properties must be set on the element instance.
- Events
  - Use the element’s CustomEvents (e.g., wa-finish) for behavior; wrappers should relay to Outputs like (waFinish) or blurEvent/focusEvent to avoid collisions.
  - Assert user-visible outcomes; only assert event payloads when the scenario demands it.
- Slots and CSS Parts
  - Assert visible/ARIA outcomes for slotted content; avoid shadow internals.
  - For ::part styling, assert visible effects (e.g., computed style or DOM state) via Playwright; prefer semantic role assertions when applicable.
- SSR/Hydration
  - Include scenarios that assert SSR’d content presence prior to hydration and successful interactivity post-hydration.
  - Avoid brittle timing assertions; use Playwright locator auto-waits and findBy* patterns.

Example Feature
```gherkin
Feature: Save order with Web Awesome button

  @ui @route:/orders/new @critical @component:wa-button
  Scenario: Clicking Save triggers submission and success feedback
    Given I am on the "New Order" page
    And I enter "ABC" into the "SKU" field
    And I enter "2" into the "Quantity" field
    When I click the "Save" button
    Then I should see a success message "Order created"
```

Example UI Steps (Playwright)
```ts
// tests/steps/orders.wa.ui.steps.ts
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('I am on the {string} page', async function (_: string) {
  await this.page.goto('/orders/new');
});

When('I click the {string} button', async function (label: string) {
  await this.page.getByRole('button', { name: new RegExp(label, 'i') }).click();
});

Then('I should see a success message {string}', async function (msg: string) {
  await expect(this.page.getByText(new RegExp(msg, 'i'))).toBeVisible();
});
```

Contract-Focused Steps (attributes/properties)
```ts
When('I set {string} to {string} on the wa-button', async function (attr: string, value: string) {
  await this.page.evaluate(([a, v]) => {
    const el = document.querySelector('wa-button') as HTMLElement;
    el.setAttribute(a, v);
  }, [attr, value]);
});

Then('the wa-button should have attribute {string} = {string}', async function (attr: string, expected: string) {
  const actual = await this.page.evaluate((a) => document.querySelector('wa-button')!.getAttribute(a) ?? '', attr);
  expect(actual).toMatch(new RegExp(`^${expected}$`, 'i'));
});
```

Forms Policy Interactions
- Input (wa-input): acceptance scenarios should use user-centric interactions; two-way binding ([(ngModel)]) belongs to TDD integration/unit tests. In BDD, assert visible form behavior and submit outcomes.
- Checkbox (wa-checkbox): if reactive forms are used, acceptance scenarios still assert visible behavior (checked state, validation messages) rather than Angular internals.

SSR/Hydration and Web Components
- Use scenarios to assert that SSR content is visible pre-hydration and that interactivity works post-hydration without flicker/regressions.
- Do not pierce shadow DOM; assert visible outcomes (text/roles/status) or ::part styling effects.

MSW Strategy
- For acceptance with mocked backend, prefer MSW with onUnhandledRequest: 'error' to ensure all requests are declared.
- For full parity, run real backend in a separate CI job; keep tests deterministic (no flaky retries).

Living Documentation
- Keep features aligned to Glossary terms for wa-* components and wrapper terminology.
- Publish cucumber HTML/JSON; add index entries in docs/PROMPT_REFERENCE.md linking features to sequence diagrams and domain models.

LLM Interpretation Guidance (Angular Awesome BDD)
- Stage 1/2: write/refine Gherkin features; STOP and request approval before glue implementation.
- Keep steps domain-oriented and user-centric; do not rely on Angular private APIs or shadow internals.
- For wrapper contract specifics (Inputs→attributes/properties, Outputs→CustomEvents), rely on visible UI behavior in BDD; push detailed assertions into Angular TDD tests.

Superseded Base Sections (clarifications)
- This document fixes cucumber-js + Playwright as the acceptance toolchain for wa-* UI flows in Angular projects.
- Wrapper bridging notes here supersede generic TypeScript/Angular guidance for BDD where they differ.

Routing and Related BDD/TDD
- Base BDD — [README](rules/generative/architecture/bdd/README.md)
- TypeScript BDD — [bdd.md](rules/generative/language/typescript/bdd.md)
- Angular BDD — [bdd.md](rules/generative/language/angular/bdd.md)
- Angular Awesome TDD — [tdd.md](rules/generative/frontend/angular-awesome/tdd.md)
- Web Components BDD — [bdd.md](rules/generative/frontend/webcomponents/bdd.md)