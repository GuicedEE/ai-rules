# Web Components BDD (Topic Supplement)

Purpose
- Provide Web Components–specific BDD rules that extend and override:
  - Base BDD — [BDD Architecture](rules/generative/architecture/bdd/README.md)
  - TypeScript BDD — [TypeScript BDD](rules/generative/language/typescript/bdd.md)
- Precedence: This Web Components BDD topic supplements and, where necessary, supersedes Base/TypeScript BDD guidance for Custom Elements.

Scope
- Authoring and consuming Custom Elements (shadow DOM, slots, CSS parts, custom events) across frameworks (vanilla, Angular, React, Next.js).
- For framework projects, also see the framework’s BDD override (Angular/React/Vue/Next.js/Nuxt), which supersedes this file where guidance differs.

BDD workflow in this context
- Discovery → Formulation → Automation
  - Discovery: examples that describe the element’s public contract (attributes/properties, slots/parts, events).
  - Formulation: write Gherkin scenarios that use domain wording and visible behaviors; avoid internal/shadow coupling.
  - Automation: bind steps that interact through user-visible/UI contract with Playwright; assert public outputs (DOM text/ARIA, event effects).
- Pair with TDD for unit/integration beneath (element class logic, adapters). BDD focuses on behavior; TDD focuses on design and correctness under the hood.

Feature file structure and tagging
- tests/features/<domain-or-component>/<feature>.feature
- Use tags for traceability:
  - @ui or @api (if component triggers HTTP via host glue)
  - @component:my-element, @domain:Catalog
  - @sequence:component-behavior (maps to docs/architecture/sequence-*.md)
  - @slot:prefix, @event:value-change (optional contract tags)
- Keep steps user-centric (labels/roles/text). Avoid references to internal shadow structure.

Tooling
- Runner: @cucumber/cucumber (cucumber-js)
- Browser automation: Playwright (preferred)
- Network mocking: MSW (Node/Browser), when component behavior depends on network through host glue
- Lint/Format/Types: ESLint + Prettier + tsc in CI
- Reporting: cucumber JSON/HTML published in CI

Step design guidelines (contract-first)
- Attributes vs Properties
  - Steps should set attributes declaratively or set public properties through host APIs, then assert visible effects.
  - Do not rely on implementation timing beyond documented upgrade behavior; wait for upgrade with customElements.whenDefined if needed.
- Slots and CSS Parts
  - For slots, assign light DOM content and assert visible text/roles.
  - For parts, assert visible effects via computed styles or state classes; avoid querying shadow internals.
- Custom Events
  - Prefer asserting UI results caused by events; if capturing events is necessary, use page.on('pageerror') or DOM events via Playwright evaluate safely.
  - In framework contexts, assert wrapper outputs or UI state changes that result from events.

Playwright step examples

Navigation and visibility
```ts
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('I open the component showcase page', async function () {
  await this.page.goto('/components/my-element');
});

Then('I should see the heading {string}', async function (text: string) {
  await expect(this.page.getByRole('heading', { name: new RegExp(text, 'i') })).toBeVisible();
});
```

Attribute/property behavior
```ts
When('I set the attribute {string} to {string} on {string}', async function (attr: string, value: string, selector: string) {
  await this.page.evaluate(([sel, a, v]) => {
    const el = document.querySelector(sel)!;
    el.setAttribute(a, v);
  }, [selector, attr, value]);
});

Then('{string} should reflect the attribute {string} as {string}', async function (selector: string, attr: string, expected: string) {
  const actual = await this.page.evaluate(([sel, a]) => document.querySelector(sel)!.getAttribute(a) ?? '', [selector, attr]);
  expect(actual).toMatch(new RegExp(`^${expected}$`, 'i'));
});
```

Slots
```ts
When('I project the text {string} into the default slot of {string}', async function (text: string, selector: string) {
  await this.page.evaluate(([sel, t]) => {
    const host = document.querySelector(sel)!;
    const span = document.createElement('span');
    span.textContent = t;
    host.appendChild(span);
  }, [selector, text]);
});

Then('I should see the slotted text {string}', async function (text: string) {
  await expect(this.page.getByText(new RegExp(text, 'i'))).toBeVisible();
});
```

CSS custom properties and parts
```ts
When('I set CSS variable {string} to {string} on {string}', async function (name: string, value: string, selector: string) {
  await this.page.evaluate(([sel, n, v]) => {
    (document.querySelector(sel)! as HTMLElement).style.setProperty(n, v);
  }, [selector, name, value]);
});

// Visible outcome assertions are preferred; for demonstration, read back the value.
Then('{string} should have CSS variable {string} as {string}', async function (selector: string, name: string, expected: string) {
  const actual = await this.page.evaluate(([sel, n]) => {
    const el = document.querySelector(sel)! as HTMLElement;
    return getComputedStyle(el).getPropertyValue(n).trim();
  }, [selector, name]);
  expect(actual).toBe(expected);
});
```

Event-driven behavior (assert via visible effects)
```ts
When('I click the {string} button', async function (label: string) {
  await this.page.getByRole('button', { name: new RegExp(label, 'i') }).click();
});

Then('the status should display {string}', async function (text: string) {
  await expect(this.page.getByRole('status')).toHaveText(new RegExp(text, 'i'));
});
```

SSR and Declarative Shadow DOM
- If SSR is used with Declarative Shadow DOM:
  - Steps should assert SSR’d content presence prior to hydration (static text visible).
  - Then assert interactivity after client JS loads.

Integration with frameworks
- Angular: keep BDD steps UI-focused via Playwright; wrapper contract details belong in Angular TDD. See [Angular BDD](rules/generative/language/angular/bdd.md).
- React: keep BDD steps UI-focused; use RTL under TDD for component internals. See [React BDD](rules/generative/language/react/bdd.md).
- Next.js: include SSR/Streaming/Hydration and cache/revalidation steps. See [Next.js BDD](rules/generative/frontend/nextjs/bdd.md).

Determinism and MSW
- When the component triggers network via host glue, prefer MSW to fully declare network behavior. Fail builds on unhandled requests.

Living documentation and traceability
- Maintain feature → sequence diagram mapping via @sequence: tags and docs/PROMPT_REFERENCE.md.
- Publish cucumber HTML/JSON reports in CI, link from README or GUIDES.

LLM Interpretation Guidance (Web Components BDD)
- Stage 1/2: write/adjust Gherkin features; STOP for approval before step code.
- Steps must assert public contract and visible behaviors only; do not pierce shadow.
- Choose minimal scope; prefer contract-level assertions (attributes/properties/events/slots/parts).
- Defer framework-specific details to the framework’s BDD/TDD documents when in a framework context.

Superseded Base Sections (clarifications)
- Contract-first approach (attributes/properties, slots/parts, custom events) supersedes generic DOM notes for Custom Elements in Base/TypeScript BDD.

Routing and related BDD/TDD
- Base BDD — [README](rules/generative/architecture/bdd/README.md)
- TypeScript BDD — [bdd.md](rules/generative/language/typescript/bdd.md)
- Angular BDD — [bdd.md](rules/generative/language/angular/bdd.md)
- React BDD — [bdd.md](rules/generative/language/react/bdd.md)
- Next.js BDD — [bdd.md](rules/generative/frontend/nextjs/bdd.md)
- Web Components TDD — [tdd.md](rules/generative/frontend/webcomponents/tdd.md)
