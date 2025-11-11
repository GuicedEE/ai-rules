# Behavior-Driven Development (BDD) — Architecture and Cross-Topic Rule Precedence

Purpose
- Establish a canonical, docs-first BDD architecture that all languages/frameworks inherit from and extend.
- Define precedence and routing so that:
  - Base BDD (this document) applies to all stacks by default.
  - Language-specific BDD rules override base for that language.
  - Framework-specific BDD rules override both base and language for that framework.
- Integrate tightly with the repository’s stage-gated, documentation-first policy and docs-as-code diagrams to keep acceptance criteria executable and traceable.

Precedence (supersedence)
1) Framework BDD (most specific)
2) Language BDD
3) Base BDD (this file)

When conflicts arise, the more specific rule (framework → language → base) supersedes the less specific. Each specific doc must link back here and explicitly list what it overrides.

Documentation-first integration (stage-gated)
- Stage 1 — Architecture & Foundations (Docs only)
  - Add user stories, acceptance criteria, and discovery notes.
  - Draft initial Gherkin feature outline for critical flows, linked to C4/sequence/ERD diagrams.
  - STOP for explicit user approval before moving to Stage 2.
- Stage 2 — Guides & Design Validation (Docs only)
  - Finalize feature files structure (directories, tags, naming).
  - Define step definition strategy, test environments (browsers/containers), and reporting.
  - STOP for explicit user approval before Stage 3.
- Stage 3 — Implementation Plan (No code yet)
  - Plan glue/step packages, page objects/service clients, and CI publishing (cucumber JSON/HTML).
  - Map feature → sequence steps and data fixtures; risk and validation plan.
  - STOP for explicit user approval before Stage 4.
- Stage 4 — Implementation (Code allowed)
  - Implement steps and minimal app code to satisfy scenarios. Keep executable specs green and publish reports.
  - Iterate in small diffs; present results and ask to continue.

Docs-as-code and traceability
- Store diagrams under docs/architecture/ (C4 L1/L2/L3, sequence, ERD) and ensure Gherkin features reference tagged flows.
- Keep feature titles and scenario names stable (living documentation).
- Use tags to map scenarios to components/segments (e.g., @ui @route:/orders/new @domain:orders).

BDD workflow (canonical)
- Discovery → Formulation → Automation
  - Discovery: collaborate to capture behavior using examples and domain language.
  - Formulation: express examples as Gherkin scenarios (Given/When/Then) with domain terms from the Glossary.
  - Automation: bind steps to code (glue) and run specs continuously.
- Executable specifications are the source of truth for acceptance behavior. TDD complements by driving unit/integration design decisions beneath the acceptance layer.

Artifacts and conventions
- Feature files (.feature)
  - Organized by domain/feature area: tests/features/<domain>/<feature>.feature
  - Use tags: @ui/@api, @critical, @component:Name, @route:/path, @domain:Context
  - Prefer Scenario Outlines with examples for data-table driven coverage where sensible
- Step definitions (glue)
  - Co-locate by layer: test/glue/ui/*.ts|.java, test/glue/api/*.ts|.java
  - Reuse steps across features; avoid app implementation detail leakage
- Support code
  - Page objects/component objects for UI (Playwright recommended); service clients for API (Rest-Assured/undici/etc.)
  - Test data builders and fixtures as typed, minimal, diffable sources
- Reporting
  - Publish cucumber JSON/HTML in CI; keep trend artifacts
  - Fail build on undefined or pending steps; allow @wip tag for local iteration (not in CI)

Interplay with TDD
- BDD acceptance tests drive outside-in design at behavior level.
- TDD drives unit and integration layers (red → green → refactor) underneath the BDD umbrella.
- Both coexist: BDD ensures the right behavior, TDD ensures the right design/quality beneath.

Tooling overview (by ecosystem)
- Java
  - BDD: Cucumber-JVM (JUnit 5 platform)
  - API acceptance: Rest-Assured/HTTP client
  - UI acceptance: Playwright (Node project) or Selenium for JVM-only orgs
  - Integration: Testcontainers, WireMock
- TypeScript
  - BDD: @cucumber/cucumber (cucumber-js)
  - UI acceptance: Playwright
  - Integration: MSW (Mock Service Worker), Testcontainers (node) as needed
  - Unit: Vitest (describe/it style can mirror BDD for formulation-only specs)
- Angular
  - BDD: @cucumber/cucumber with Playwright for route/flow acceptance
  - Component tests: Angular Testing Library; map BDD Given/When/Then to user-event style steps where appropriate
  - SSR/hydration: specific acceptance steps to verify SSR content and hydration success
- React
  - BDD: @cucumber/cucumber + Playwright; component steps via RTL for deterministic user flows
- Next.js
  - BDD: @cucumber/cucumber + Playwright; Route Handlers and Middleware verified via integration steps; SSR/streaming/hydration-specific steps
- Web Components
  - BDD: @cucumber/cucumber + Playwright; contract-level steps for attributes/properties/events; do not pierce shadow internals
- Angular Awesome (wa-*)
  - BDD: @cucumber/cucumber + Playwright; wrapper contract steps (Angular Input/Output ↔ wa-* attribute/property/event); slots/parts assertions via visible behavior

Gherkin examples (conceptual)

Feature — Orders Creation
```gherkin
Feature: Create orders
  In order to purchase items
  As a customer
  I want to create an order successfully

  @ui @route:/orders/new @critical
  Scenario: Create order with valid data
    Given I am on the "New Order" page
    And I enter "ABC" into the "SKU" field
    And I enter "2" into the "Quantity" field
    When I submit the "Create Order" form
    Then I should see a success message "Order created"
    And I should be redirected to the order details page
```

Step definition sketch — TypeScript (cucumber-js)
```ts
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

Step definition sketch — Java (Cucumber-JVM + Rest-Assured)
```java
import io.cucumber.java.en.*;
import static io.restassured.RestAssured.given;
import static org.assertj.core.api.Assertions.assertThat;

public class OrdersSteps {
  private io.restassured.response.Response res;

  @When("I create an order with sku {string} and qty {int}")
  public void i_create_order(String sku, int qty) {
    res = given().contentType("application/json")
      .body("{\"sku\":\"" + sku + "\",\"qty\":" + qty + "}")
      .post("/api/orders");
  }

  @Then("the response status should be {int}")
  public void the_response_status_should_be(Integer status) {
    assertThat(res.statusCode()).isEqualTo(status);
  }
}
```

Tagging and traceability
- Use tags to link to architecture:
  - @sequence:orders-create (maps to docs/architecture/sequence-orders-create.md)
  - @component:OrderService, @route:/orders/new
  - @domain:Orders
- Maintain a small index in docs/PROMPT_REFERENCE.md that maps tags to files for AI prompt seeding.

CI integration
- Run cucumber acceptance before or after unit/integration depending on pipeline strategy.
- Publish cucumber HTML/JSON. Fail on undefined/pending steps.
- Optionally push living documentation to a static site (reports + links to features).
- Keep scenarios fast and deterministic; flakiness is a failure.

LLM interpretation guidance
- Always formulate or update Gherkin scenarios first (Stage 1/2), then request approval (STOP) before step or app code changes.
- Implement step definitions tied to domain terms in Glossary; do not export app internals into steps.
- Choose the minimum scope: API-only steps for API features; UI steps for user flows; keep boundaries clear.
- Leverage TDD underneath for unit/integration coverage driven by BDD acceptance.

Routing and overrides (to be created/extended)
- Java BDD (language override): rules/generative/language/java/bdd.md
- TypeScript BDD (language override): rules/generative/language/typescript/bdd.md
- Angular BDD (framework override): rules/generative/language/angular/bdd.md
- React BDD (framework override): rules/generative/language/react/bdd.md
- Next.js BDD (framework override): rules/generative/frontend/nextjs/bdd.md
- Web Components BDD (topic supplement): rules/generative/frontend/webcomponents/bdd.md
- Angular Awesome BDD (plugin supplement): rules/generative/frontend/angular-awesome/bdd.md

Checklist (for adopters)
- [ ] Project RULES.md declares BDD adoption; links to language/framework overrides.
- [ ] Feature files committed and structured with tags and domain-aligned wording.
- [ ] Step definition strategy and support code (page objects/clients) established.
- [ ] CI publishes cucumber reports and enforces undefined/pending step failures.
- [ ] Scenarios map to diagrams and acceptance criteria; docs kept in sync (living documentation).
