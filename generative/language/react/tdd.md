# React TDD (Framework Override)

Purpose
- Provide React-specific TDD rules that extend and override:
  - Base TDD — [TDD Architecture](rules/generative/architecture/tdd/README.md)
  - TypeScript TDD — [TypeScript TDD](rules/generative/language/typescript/tdd.md)
- Precedence: This React TDD framework override supersedes both the Base and TypeScript language TDD where directives differ.

Scope
- Applies to React applications and libraries (CSR/SSR/SSG via frameworks that are not Next.js). For Next.js apps, see [Next.js TDD](rules/generative/frontend/nextjs/tdd.md).
- Coordinates with Web Components usage in React (custom elements, shadow DOM), and with design-system libraries.

Core TDD Workflow (inherits, React specifics)
- Red → Green → Refactor
- Outside-in for user stories:
  - Start with acceptance/E2E test of the route/flow (Playwright), then drive component behavior with React Testing Library (RTL).
- Inside-out for pure logic (reducers, selectors, hooks without IO); later wrap with integration/acceptance.
- Behavior-first: test user-observable outcomes; avoid asserting implementation details (DOM structure internals, component instance fields).

Recommended Tooling
- Unit/Component: Vitest (preferred) or Jest + React Testing Library (RTL) + @testing-library/user-event
- Network mocking: MSW (Mock Service Worker) for browser/node adapters
- E2E: Playwright (preferred) with stable, data-testid selectors
- Coverage: c8/V8 with thresholds enforced in CI
- Lint/Format: ESLint + Prettier; Type-check with tsc

Render Environments
- CSR components: use RTL with jsdom test environment
- SSR (non-Next): pre-render string with frameworks (if applicable) and hydrate via ReactDOM.hydrateRoot in tests that require it; otherwise focus on behavior after mount
- Hooks: test via @testing-library/react with test components or dedicated hook testing utilities; assert behavior rather than internal state

Test Taxonomy (React)
- Unit tests (largest)
  - Pure functions, hooks with isolated effects (mock boundaries), presentational components
  - Prefer RTL queries by role/label/text over test-id unless necessary
- Integration tests (moderate)
  - Component + data-fetch interactions (MSW), router-boundary tests (react-router)
  - State managers (e.g., Redux/Zustand/Context) wired with providers; assert observable outcomes
- Acceptance/E2E (smallest)
  - User flows across routes (Playwright)
  - Critical flows only; deterministic and fast

React Testing Library (RTL) Patterns
- Prefer user-centric queries:
  - getByRole/getByLabelText/getByText/within queries
  - Avoid getByTestId unless UI lacks semantic hooks
- Async rendering
  - Use findBy* for async outcomes; avoid arbitrary timeouts
  - Use user-event for realistic interactions (typing, clicks, tabbing)
- Accessibility checks (optional)
  - Integrate axe-core for a11y smoke checks in CI (fast subset)

Examples

- Component test (RTL + user-event)
```ts
import { render, screen } from '@testing-library/react';
import user from '@testing-library/user-event';
import { Counter } from './Counter';

it('increments on click', async () => {
  render(<Counter />);
  await user.click(screen.getByRole('button', { name: /increment/i }));
  expect(screen.getByRole('status')).toHaveTextContent('1');
});
```

- Hook test (via wrapper component)
```ts
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

it('increments value', () => {
  const { result } = renderHook(() => useCounter());
  act(() => result.current.increment());
  expect(result.current.value).toBe(1);
});
```

- Integration with MSW
```ts
// test/setup.ts
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

export const server = setupServer(
  http.get('/api/users/:id', ({ params }) => HttpResponse.json({ id: params.id, name: 'Jane' }))
);

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

// Component test
import { render, screen } from '@testing-library/react';
import { UserCard } from './UserCard';

it('loads and shows user', async () => {
  render(<UserCard id="42" />);
  expect(await screen.findByText(/jane/i)).toBeInTheDocument();
});
```

Router Testing
- Use react-router test utilities (MemoryRouter with initialEntries) to test routing logic and route components.
- Assert redirects, parameters, and loaders (if using data APIs); keep network via MSW.

State Management Testing
- For Context/Redux/Zustand:
  - Provide a minimal store/provider wrapper
  - Seed store state via providers or setup utilities
  - Assert UI behavior, not store internals
  - For reducers: unit test pure reducer functions with input→output table tests

Web Components in React
- Rendering custom elements: ensure attributes/props map correctly; attach imperative props via refs inside effect hooks when needed
- Events: use addEventListener in effect or React wrappers; test via dispatchEvent in unit/RTL tests or via user interactions in E2E
- Avoid direct shadow DOM queries; assert visible behavior or public parts via CSS ::part with toHaveStyle/toBeVisible

SSR/Hydration (non-Next)
- If SSR is used, write tests that assert pre-hydration HTML (string render), then hydrate and assert interactivity
- Guard browser-only APIs; in tests, simulate environment appropriately (jsdom + hydration routine)

Coverage and Gates (React-specific thresholds)
- Enforce ≥ 80% lines/statements/functions; ≥ 70% branches via Vitest/Jest configuration
- Critical flows (auth, payments, data mutation) must have acceptance-level coverage

CI Pipeline (example)
- Lint/Type-check: eslint . && tsc -p tsconfig.json --noEmit
- Unit/Integration: vitest run --coverage
- E2E: playwright test
- Artifacts: coverage (lcov/html), junit xml (optional); break build on violations

Outside-in Example (feature)
1) Write failing Playwright spec for “checkout flow”
2) Write failing integration test for route + data loader (MSW)
3) Write failing unit tests for checkout reducer and helpers
4) Implement minimal code to pass tests (unit → integration → E2E), then refactor

Inside-out Example (hook)
1) Write failing unit tests for useDebounce edge cases
2) Implement minimal hook
3) Write integration to assert component integrates correctly
4) Refactor for clarity/performance

LLM Interpretation Guidance (React)
- Write/modify failing tests first (unit/component/integration/E2E) based on Stage 1/2 docs; STOP to request approval before implementation.
- Prefer user-centric assertions; avoid component internals and DOM structure coupling.
- For network, default to MSW handlers; test error and edge cases.
- For SSR, prefer tests that verify pre-hydration DOM and post-hydration behavior.

Superseded Base Sections (clarifications)
- RTL + MSW + Playwright patterns supersede generic TypeScript/Base guidance where they differ for React.
- Coverage thresholds and CI gating here supersede base defaults for React projects.

Routing and Related TDD
- Base TDD — [README](rules/generative/architecture/tdd/README.md)
- TypeScript TDD — [tdd.md](rules/generative/language/typescript/tdd.md)
- Next.js TDD — [tdd.md](rules/generative/frontend/nextjs/tdd.md)
- Web Components TDD — [tdd.md](rules/generative/frontend/webcomponents/tdd.md)