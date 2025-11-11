# Angular TDD (Framework Override)

Purpose
- Provide Angular-specific TDD rules that extend and override:
  - Base TDD — [TDD Architecture](rules/generative/architecture/tdd/README.md)
  - TypeScript TDD — [TypeScript TDD](rules/generative/language/typescript/tdd.md)
- Precedence: This Angular TDD framework override supersedes both the Base and TypeScript language TDD where directives differ.

Scope
- Applies to Angular 17/19/20+ projects using the modular base + version override model:
  - Base rules — [angular.md](rules/generative/language/angular/angular.md)
  - Version overrides — [angular-17.rules.md](rules/generative/language/angular/angular-17.rules.md), [angular-19.rules.md](rules/generative/language/angular/angular-19.rules.md), [angular-20.rules.md](rules/generative/language/angular/angular-20.rules.md)
- Integrates with Angular Awesome (plugin) and Web Components consumption where present.

Core TDD Workflow (inherits, supersedes specifics)
- Red → Green → Refactor, applied at component, service, and route level.
- Outside-in for feature development:
  - Start with high-level acceptance/E2E for the route/flow.
  - Drive component/service units next to support the flow.
- Inside-out for complex pure logic (pipes, pure services); wrap at integration/acceptance afterward.

Recommended Tooling and Runners
- Unit & Component tests:
  - Runner: Vitest (preferred) or Jest
  - Angular TestBed for module/component/service setup
  - Testing Library for Angular for user-centric queries and interactions
  - Angular Component Harnesses (where available) for stable selectors over internals
- HTTP boundary tests:
  - HttpClientTestingModule with HttpTestingController for request assertions
  - MSW (Mock Service Worker) as an alternative for more realistic HTTP mocking (Node/browser adapters)
- End-to-End (E2E):
  - Playwright (preferred), SSR/hydration-aware flows, stable selectors via data-testid
- Coverage:
  - Vitest coverage (c8/V8) with thresholds enforced in CI (≥ 80% lines/statements/functions; ≥ 70% branches minimum)
- Lint/Format:
  - ESLint + Prettier; type-check with ng tsc or tsc in CI

Project Structure (typical)
- src/app/… (modules, standalone components, services)
- src/app/**/*.spec.ts — colocated unit/component tests
- test/setup.ts — global testing setup (MSW, zone.js config if needed)
- e2e/**/*.spec.ts — Playwright tests in separate project/root

Test Taxonomy for Angular
- Unit tests (largest count)
  - Pure services, pipes, and components with isolated DOM expectations
  - Use shallow rendering where appropriate; prefer user-visible behavior over internal state
  - Avoid relying on private members; assert rendered output and public API
- Integration tests (moderate)
  - Feature module composition (routing, providers, interceptors, guards)
  - HttpClientTestingModule + HttpTestingController or MSW integration for HTTP
  - Component Harnesses to assert widget behavior independently of DOM details
- Acceptance/E2E tests (smallest)
  - Route-level flows (navigation, form submit, SSR/hydration, error handling)
  - Playwright with SSR/hydration checks; stable data-testid-based selectors
  - Critical flows only; keep fast and deterministic

Angular TestBed Patterns
- Minimal example with a standalone component
```ts
import { render, screen } from '@testing-library/angular';
import { MyComponent } from './my.component';

it('renders heading', async () => {
  await render(MyComponent);
  expect(screen.getByRole('heading', { name: /welcome/i })).toBeInTheDocument();
});
```

- Service with HttpClientTestingModule
```ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { UsersService } from './users.service';

describe('UsersService', () => {
  let svc: UsersService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UsersService]
    });
    svc = TestBed.inject(UsersService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  it('fetches user by id', (done) => {
    svc.getUser('42').subscribe(user => {
      expect(user).toEqual({ id: '42', name: 'Jane' });
      done();
    });
    const req = httpMock.expectOne('/api/users/42');
    req.flush({ id: '42', name: 'Jane' });
  });

  afterEach(() => httpMock.verify());
});
```

- Harness-based interaction (if harness is provided)
```ts
// Example (pseudo if no official harness exists)
import { MyWidgetHarness } from './testing/my-widget.harness';
import { TestbedHarnessEnvironment } from '@angular/cdk/testing/testbed';

it('increments value when clicked', async () => {
  const fixture = TestBed.createComponent(MyWidgetComponent);
  const loader = TestbedHarnessEnvironment.loader(fixture);
  const widget = await loader.getHarness(MyWidgetHarness);

  await widget.clickIncrement();
  expect(await widget.getValue()).toBe(1);
});
```

Router and Guards Testing
- Use RouterTestingHarness/RouterTestingModule to simulate navigation and guard outcomes.
- Assert redirects, data resolvers, and route params handling via navigation events and DOM outcomes.

Forms Testing
- Template-driven: user-event style input, then assert form validity and submitted payload.
- Reactive forms: setValue/patchValue + DOM assertions; prefer user-oriented checks where possible.

HTTP Mocking Strategy
- Default: HttpTestingController for precise request expectations in unit/integration.
- Alternative: MSW for contract-level tests closer to runtime (integration/E2E parity, composed with Node/browser).
- Avoid overly brittle mocks that assert implementation details; prioritize contract shapes and status/error paths.

State, SSR, and Hydration
- SSR (Angular Universal):
  - Do not access browser-only APIs in unit tests for SSR paths; guard within code and tests
  - Acceptance tests should assert SSR’d content presence before hydration
  - For Web Components, prefer Declarative Shadow DOM where available; otherwise use hydration markers/guards
- Hydration:
  - Assert that content remains stable across hydration; avoid brittle timing assertions
  - For streaming, assert incremental rendering using Playwright or SSR integration tests

Web Components and Angular Awesome Integration
- Angular Awesome (wa-*) components:
  - Unit: render the custom element/directive wrapper; assert behavior via slots/parts and public attributes/events, not internals
  - Integration: MSW or HttpTestingController if component triggers HTTP via host service interaction
  - E2E: user flows with Playwright; prefer data-testid on host wrappers
- Web Components:
  - DOM tests with @testing-library/angular (jsdom) or Playwright (real browser)
  - Avoid directly querying shadow internals; prefer ::part exposure and visible behavior

Change Detection and Async
- Use fakeAsync/tick or async/await with flush when testing scheduled tasks/microtasks.
- Prefer await-based patterns with Testing Library to better reflect user timing.
- Do not assert exact microtask order; assert final, user-visible states.

Test Data, Time, and Isolation
- Time: fake timers with Jest/Vitest as needed; ensure Zone.js compatibility when applicable
- Randomness: inject seeded RNG or deterministic provider
- Isolation: no global mutable state; per-spec setup and teardown; avoid leaking scheduled timers

Coverage and Gates (supersedes base numbers if stricter)
- Enforce ≥ 80% lines/statements/functions; ≥ 70% branches via Vitest/Jest configuration in CI
- Critical components (auth, payment, data mutation) must have acceptance-level coverage

CI Pipeline (example)
- Lint/Type-check: ng lint (or eslint) + ng tsc
- Unit/Component: vitest run --coverage
- Integration: vitest run --config vitest.integration.config.ts (or tags)
- E2E: playwright test (install browsers in CI job)
- Artifacts: coverage (lcov/html), junit XML (optional); break on violations

Outside-in Example (feature route)
1) Write failing Playwright test for /orders create flow (form → submit → confirmation)
2) Add failing integration test for component + service, HTTP interaction, navigation on success
3) Add unit tests for form validators and service helpers
4) Implement minimal code to pass tests (unit → integration → e2e), then refactor

Inside-out Example (pure pipe)
1) Write failing unit tests for edge cases and locale specifics
2) Implement minimal pipe logic to green tests
3) Add integration test rendering the pipe in a component
4) Refactor for clarity/performance as needed

Minimal Examples

- Component render with Testing Library
```ts
await render(MyFormComponent);
await user.type(screen.getByLabelText(/name/i), 'Jane');
await user.click(screen.getByRole('button', { name: /save/i }));
expect(await screen.findByText(/saved/i)).toBeInTheDocument();
```

- HttpTestingController expectation
```ts
const req = httpMock.expectOne('/api/orders');
expect(req.request.method).toBe('POST');
req.flush({ id: 123 }, { status: 201, statusText: 'Created' });
```

- Playwright E2E
```ts
import { test, expect } from '@playwright/test';

test('orders create flow', async ({ page }) => {
  await page.goto('/orders/new');
  await page.getByLabel('Name').fill('Jane');
  await page.getByRole('button', { name: /save/i }).click();
  await expect(page.getByText(/order created/i)).toBeVisible();
});
```

LLM Interpretation Guidance (Angular)
- Write/modify failing tests first (unit/component/integration/E2E) based on Stage 1/2 docs; STOP to request approval before implementation.
- Prefer user-centric assertions with Testing Library or Harnesses; do not assert framework internals or private members.
- For HTTP, start with HttpTestingController; use MSW when integration realism is required.
- Respect SSR/hydration constraints; guard browser-only APIs; prefer acceptance tests to validate SSR+hydrate success.
- For Angular Awesome/Web Components, assert public behavior (attributes, events, slots/parts); avoid shadow internals.

Superseded Base Sections (clarifications)
- Angular TestBed + Testing Library + Harnesses patterns supersede generic TypeScript DOM-testing and Base TDD guidance where they differ.
- Coverage thresholds and CI gating here supersede base defaults for Angular projects.

Routing and Related TDD
- Base TDD — [README](rules/generative/architecture/tdd/README.md)
- TypeScript TDD — [tdd.md](rules/generative/language/typescript/tdd.md)
- Angular Awesome TDD — [tdd.md](rules/generative/frontend/angular-awesome/tdd.md)
- Web Components TDD — [tdd.md](rules/generative/frontend/webcomponents/tdd.md)
- React TDD — [tdd.md](rules/generative/language/react/tdd.md)
- Next.js TDD — [tdd.md](rules/generative/frontend/nextjs/tdd.md)