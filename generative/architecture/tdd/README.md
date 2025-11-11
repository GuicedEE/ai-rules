# Test-Driven Development (TDD) — Architecture and Cross-Topic Rule Precedence

Purpose
- Establish a canonical, docs-first TDD architecture that all languages/frameworks in this repository inherit from and extend.
- Define precedence and routing so that:
  - Base TDD (this document) applies to all stacks by default.
  - Language-specific TDD rules override base for that language.
  - Framework-specific TDD rules override both base and language for that framework.
- Integrate with the repository’s stage-gated workflow and docs-as-code policy to ensure tests/specs are first-class and version-controlled.

Precedence (supersedence)
1) Framework TDD (most specific)
2) Language TDD
3) Base TDD (this file)

When conflicts arise, the more specific rule (framework → language → base) supersedes the less specific. Each specific doc must link back here and explicitly list what it overrides.

Documentation-first integration
- Stage-gated workflow: no code until docs are approved.
  - Stage 1: Architecture & Foundations must include testing strategy and coverage plan tied to C4 diagrams and key flows.
  - Stage 2: Guides & Design Validation must include test plans per route/component/service with acceptance criteria and traceability from diagrams/flows.
  - Stage 3: Implementation Plan must define test scaffolding (frameworks, runners, environments, containers) and CI gates.
  - Stage 4: Implementation proceeds only after approval; tests lead code (red → green → refactor).
- Docs-as-code: all test strategies and system test flows are stored alongside architecture diagrams under docs/architecture/* with traceability into RULES/GUIDES and then to implementation and CI.

TDD Workflow (canonical)
- Red → Green → Refactor
  - Red: Author a failing test that expresses the next slice of behavior. The test must be meaningful and tied to acceptance criteria.
  - Green: Implement the minimal code to pass the test.
  - Refactor: Improve design without changing behavior. Maintain green. Update tests when refactoring surface requires more precise assertions (do not weaken semantics).
- Outside-in vs Inside-out
  - Outside-in: Start with high-level (acceptance) tests to define behavior, then drive down into units. Recommended for product features and API routes.
  - Inside-out: Start with core domain units first. Recommended for algorithmic or domain-centric components where boundaries are stable and test doubles are precise.
- Test semantics
  - Tests describe behavior (specifications), not implementation details.
  - Avoid testing private internals; prefer public or contract-level behavior. For framework-specific components, rely on framework testing APIs/harnesses (e.g., component harnesses).

Test taxonomy (pyramid with pragmatic balance)
- Acceptance/E2E tests (smallest number)
  - Validate end-to-end routes and key user flows. Exercise boundaries (auth, DB, external APIs) with realistic environments (containers/mocks).
- Integration tests (moderate number)
  - Validate module/service boundaries (HTTP handlers ↔ services; services ↔ DBs; services ↔ external APIs) using Testcontainers/WireMock or framework peers.
- Unit tests (largest number)
  - Validate isolated logic with deterministic execution, fast feedback, and comprehensive branch/edge coverage.

Coverage and quality gates (baseline)
- Target: 80% instruction coverage overall with risk-based exceptions noted in RULES.md at project level.
- Critical paths (auth, payments, data mutation) must have acceptance-level coverage.
- Mutation testing recommended for critical domain modules (language/framework support dependent).
- Static analysis and format/lint checks run with tests in CI.
- Flakiness: test jobs must be repeatable; non-deterministic tests are failures to be fixed, not re-run.

Test data, environments, and isolation
- Unit tests: pure in-memory; deterministic clocks/random sources (inject Clock/Random providers).
- Integration tests: ephemeral resources via containers/mocks; cleanup guaranteed; parallel-friendly by isolated resources or schemas.
- Acceptance tests: environment parity (schemas, seeds) declared and versioned. Use containers and seeded data fixtures stored under test resources (text-based, diffable).

CI integration (pipeline)
- Stages:
  1) Lint/Static analysis
  2) Unit tests (fast)
  3) Integration tests (containers/mocks)
  4) Acceptance/E2E tests (playwright/cypress/etc.)
  5) Reports (coverage/tests) published as artifacts; quality gates enforced
- Break build on violations; forward-only: fix or explicitly override with rationale in RULES.md.

Common patterns and anti-patterns
- Do:
  - Write tests first for new behavior; commit red → green → refactor steps coherently.
  - Use focused, behavior-oriented names and a Given/When/Then structure in test code/comments.
  - Prefer dependency injection for time/IO/random to make tests deterministic.
  - For DB work, use Testcontainers with short lifecycle and stable seeds/migrations.
- Avoid:
  - Overspecifying internals (brittle tests).
  - Broad mocks that re-implement logic; mock only hard boundaries and verify contracts.
  - Shared global test state; tests must be order-independent.

Tooling (routing and selection)
- Java:
  - Unit: JUnit 5 (Jupiter), AssertJ (fluent assertions), Mockito/MockK (Kotlin alt), JsonUnit for JSON shape.
  - Integration: Testcontainers for DB/brokers; WireMock for HTTP; Awaitility for async.
  - Acceptance/API: Rest-Assured or HTTP clients + containers; Playwright for UI (if applicable).
- Kotlin:
  - Unit: JUnit 5 or Kotest; MockK for mocking; AssertJ/Kotest assertions.
  - Integration/Acceptance analogous to Java stack with Testcontainers/WireMock.
- TypeScript (Node/Browser):
  - Unit: Vitest (preferred) or Jest; ts-node/ts-jest as needed; MSW for HTTP mocking in browser contexts.
  - Integration: Vitest with node test env + containers/mocks.
  - Acceptance/UI: Playwright preferred (headless, cross-browser), or Cypress if org standard.
- Angular:
  - Unit/Component: Vitest (or Jest) + Testing Library for Angular; Angular TestBed; Harnesses where available.
  - Integration: TestBed with module wiring; MSW or interceptors for HTTP; Testcontainers for backend services (run in CI job).
  - E2E: Playwright with SSR/hydration guards; use data-testid for stable selectors.
- React:
  - Unit/Component: Vitest/Jest + React Testing Library; user-event; MSW for network.
  - E2E: Playwright; SSR/CSR nuances documented in framework-specific overrides.
- Next.js (App Router):
  - Server Components: unit tests for pure functions and data fetch wrappers; mock fetch/cache boundaries.
  - Route Handlers: supertest/undici/next test utils; inject headers/cookies via NextRequest mocks.
  - E2E: Playwright with routing and streaming assertions; hydration guards for web components.

Tracing from diagrams to tests
- Each C4 L2/L3 component must have a mapped test plan:
  - Units for core logic
  - Integration for boundary adapters (DB, HTTP, message bus)
  - Acceptance for cross-component flows
- Sequence diagrams define acceptance test scripts: each step maps to an assertion or fixture stage.

LLM interpretation guidance
- When asked to implement a feature:
  1) Generate or update the test(s) first, tied to acceptance criteria derived from Stage 1/2 docs.
  2) Ask for approval (STOP gate) before adding implementation code.
  3) After approval, implement minimal code to pass tests, then refactor while keeping tests green.
  4) Update docs and coverage reports; link tests to diagrams and criteria.
- When choosing test level(s):
  - Start at the boundary the user story targets; add unit tests to drive design if internals are unstable or complex.
- Do not invent frameworks; use the stack declared in project RULES.md and topic-specific TDD docs (language/framework overrides).

Routing and overrides (to be created/extended)
- Java TDD (language override): rules/generative/language/java/tdd.md
- Kotlin TDD (language override): rules/generative/language/kotlin/tdd.md
- TypeScript TDD (language override): rules/generative/language/typescript/tdd.md
- Angular TDD (framework override): rules/generative/language/angular/tdd.md
- React TDD (framework override): rules/generative/language/react/tdd.md
- Next.js TDD (framework override): rules/generative/frontend/nextjs/tdd.md
- Web Components TDD (topic supplement): rules/generative/frontend/webcomponents/tdd.md
- Angular Awesome TDD (plugin supplement): rules/generative/frontend/angular-awesome/tdd.md

Policy linkage
- This TDD architecture integrates with:
  - Documentation-First, Stage-Gated Workflow — See [rules/README.md](rules/README.md)
  - Docs-as-Code Diagrams Policy — See [rules/README.md](rules/README.md)
  - Glossary precedence (topic-first) — See [rules/README.md](rules/README.md)
  - Language/Framework topic glossaries — see each topic’s GLOSSARY.md

Minimal examples (conceptual)

Java — service unit test (Given/When/Then; JUnit 5 + AssertJ)
```java
// Given
when(repo.findById(id)).thenReturn(Optional.of(entity));
// When
var actual = service.findName(id);
// Then
assertThat(actual).isEqualTo("name");
```

TypeScript — function unit test (Vitest)
```ts
import { describe, it, expect } from 'vitest';
import { sum } from './sum';

describe('sum()', () => {
  it('adds two numbers', () => {
    expect(sum(2, 3)).toBe(5);
  });
});
```

Angular — component test (Testing Library)
```ts
import { render, screen } from '@testing-library/angular';
import { MyComponent } from './my.component';

it('renders title', async () => {
  await render(MyComponent);
  expect(screen.getByRole('heading', { name: /title/i })).toBeInTheDocument();
});
```

Next steps (repository tasks)
- Create the language/framework override files listed in “Routing and overrides” with concrete guidance, tool configuration, and CI examples that supersede this base where necessary.
- Update RULES taxonomy to include tdd/ under generative/architecture/.
- Update prompt templates to include TDD under Architecture selection and to route test-first steps in the stage-gated process.

Checklist (for adopters)
- [ ] Project RULES.md declares TDD adoption and links to language/framework overrides.
- [ ] Test tools configured (build files), CI stages defined and enforced.
- [ ] Test plans exist and trace to diagrams and acceptance criteria.
- [ ] New features follow red → green → refactor with STOP gates between docs and code stages.
