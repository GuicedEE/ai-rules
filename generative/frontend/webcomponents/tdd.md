# Web Components TDD (Topic Supplement)

Purpose
- Provide Web Components–specific TDD rules that extend and override:
  - Base TDD — [TDD Architecture](rules/generative/architecture/tdd/README.md)
  - TypeScript TDD — [TypeScript TDD](rules/generative/language/typescript/tdd.md)
- Precedence: This Web Components TDD topic supplements and, where necessary, supersedes Base and TypeScript TDD guidance for custom elements.

Scope
- Applies to authoring and consuming Custom Elements with Shadow DOM, slots, CSS parts, and custom events across frameworks (vanilla, Angular, React, Next.js).
- For framework projects, also see the framework’s TDD override (e.g., Angular/React/Vue/Next.js/Nuxt TDD) which supersedes this file where guidance differs.

Core TDD Workflow (inherits)
- Red → Green → Refactor, focusing on observable behavior of the custom element contract:
  - Attributes vs properties mapping
  - Slots and CSS parts rendering
  - CustomEvent emissions (names, detail payloads, bubbles/composed/cancelable)
  - Styling via CSS custom properties/::part exposure
- Outside-in vs Inside-out
  - Outside-in: begin with contract-level behavior (attributes → visible DOM; events on interaction), then drive internal logic.
  - Inside-out: for algorithmic internals; wrap with contract assertions afterward.

Testing Levels and Focus
- Unit (largest)
  - Element class behavior isolated from external services.
  - Assert public contract only (attributes/properties, slots/parts, events); avoid shadow internals.
- Integration (moderate)
  - Interactions with host app/services (e.g., HTTP via host code), or multiple components together.
  - Use MSW for HTTP; compose elements in containers to validate interplay (e.g., dropdown + menu items).
- Acceptance/E2E (smallest)
  - Cross-component flows in a browser with Playwright; assert visual/ARIA/interaction outcomes.

Tooling (recommended)
- Unit/Integration:
  - Runner: Vitest (preferred) or Jest
  - DOM utilities: @testing-library/dom
  - HTTP mocking: MSW (browser/node)
- E2E:
  - Playwright (preferred), stable selectors via roles/text and data-testid where necessary
- Coverage:
  - c8/V8 in Vitest; enforce thresholds in CI (≥ 80% lines/statements/functions; ≥ 70% branches)
- Lint/Format:
  - ESLint + Prettier; Type-check with tsc in CI

Authoring Tests for Custom Elements

Registration and Upgrade
- Ensure the element is defined before use:
  ```ts
  import './my-element.js'; // side-effect registers custom element
  customElements.whenDefined('my-element');
  ```
- Test “upgrade timing”: when HTML is present before registration, the element upgrades after definition; avoid relying on constructor side-effects for assertions without awaiting upgrade.

Attributes vs Properties
- Attributes (string/boolean presence/number tokens) are declarative; properties may be JS-only or reflectable:
  - Tests should assert reflected attributes after property changes if reflection is documented.
  - For JS-only properties (large objects, functions), assign after element is connected and assert behavior.
- Example (attribute reflection):
  ```ts
  const el = document.createElement('my-element');
  el.value = 5;
  await Promise.resolve(); // microtask flush if reflection async
  expect(el.getAttribute('value')).toBe('5');
  ```

Slots and CSS Parts
- Slots:
  - Assign light DOM children to default/named slots and assert visible behavior through public surface.
  - Avoid querying shadow internals; use getByText/getByRole on the host context.
- CSS Parts:
  - Expose ::part tokens; tests may assert computed styles via getComputedStyle on the host or a styled wrapper context.
  - Prefer assertions on visible effects (layout/visibility/state) over raw part presence.

Custom Events
- Emit CustomEvent with typed detail and correct flags:
  - bubbles? composed? cancelable?
- Test dispatch and payload:
  ```ts
  const el = document.createElement('my-element');
  const handler = vi.fn();
  el.addEventListener('value-change', handler);
  // act: simulate user interaction or method call
  el.value = 3;
  el.dispatchEvent(new Event('input')); // if component contract uses input to emit
  expect(handler).toHaveBeenCalled();
  expect(handler.mock.calls[0][0].detail).toEqual({ value: 3 });
  ```

Shadow DOM and Internals
- Do NOT reach into shadowRoot for structure coupling; it is an implementation detail.
- Prefer:
  - Public contract: attributes, properties, events
  - User-facing rendering: text, roles, labels, ARIA
  - CSS parts and custom properties for styling assertions
- If a testing hook is necessary for deep assertions, document it as part of the contract (discouraged unless critical).

Styling Hooks
- Tests may assert that changing CSS custom properties affects rendered outcome (e.g., color/size) via computed styles.
- Use host classes and style.setProperty on the element to set CSS variables.

SSR and Declarative Shadow DOM
- SSR (no client JS): assert the static HTML content if Declarative Shadow DOM is used (<template shadowrootmode="open">).
- Hydration:
  - After client JS loads, assert interactive behavior (click handlers, dynamic content).
- Streaming (framework-integrated): assert progressive rendering via Playwright by awaiting content appearance in order.

Playwright E2E Guidance
- Prefer user-centric selectors:
  - By role/name/label; fall back to data-testid where necessary
- Assert:
  - Initial SSR content visibility (if applicable)
  - Interaction outcomes (events causing DOM updates)
  - Visual state changes (e.g., aria-expanded, aria-selected)

Integration with Frameworks
- Angular:
  - Prefer Testing Library for Angular or TestBed; for wa-* or other custom elements, add CUSTOM_ELEMENTS_SCHEMA if no wrappers exist.
  - Use wrapper directives (if present) and assert attribute/property/event bridging at the host wrapper level.
- React:
  - RTL + user-event; attach imperative props via refs in effects; listen to custom events via addEventListener.
- Next.js:
  - SSR with static output checks; Client Components attach imperative props; E2E verifies hydration and flows.

Test Data and Determinism
- Time: vi.useFakeTimers(), vi.setSystemTime for deterministic behavior.
- Randomness: inject seeded RNG or deterministic generators in element’s config if applicable.
- Network: MSW handlers with per-test lifecycles to avoid bleed.

Examples

- Unit: attribute/property mapping
```ts
import { describe, it, expect } from 'vitest';
import '@webcomponents/my-element';

describe('<my-element>', () => {
  it('reflects value property to attribute', async () => {
    const el = document.createElement('my-element') as any;
    document.body.appendChild(el);
    el.value = 42;
    await Promise.resolve();
    expect(el.getAttribute('value')).toBe('42');
  });
});
```

- Integration: custom event contract
```ts
import { describe, it, expect, vi } from 'vitest';
import '@webcomponents/my-toggle';

describe('<my-toggle>', () => {
  it('emits change event with detail', () => {
    const el = document.createElement('my-toggle');
    const spy = vi.fn();
    el.addEventListener('toggle-change', spy);
    document.body.appendChild(el);

    // user-like action – depends on contract (e.g., click on host)
    el.click();

    expect(spy).toHaveBeenCalled();
    const evt = spy.mock.calls[0][0] as CustomEvent;
    expect(evt.detail).toEqual({ checked: true });
  });
});
```

- E2E: SSR + hydrate
```ts
import { test, expect } from '@playwright/test';

test('renders SSR content and hydrates', async ({ page }) => {
  await page.goto('/components/my-element');
  await expect(page.getByRole('heading', { name: /my element/i })).toBeVisible(); // SSR’d text
  await page.getByRole('button', { name: /toggle/i }).click(); // hydration
  await expect(page.getByRole('status')).toHaveTextContent(/on/i);
});
```

Coverage and CI Gates (supersedes base where stricter)
- Enforce ≥ 80% lines/statements/functions; ≥ 70% branches in Vitest config.
- Fail on unhandled network requests in MSW (CI=1 with ‘error’ policy).
- Disallow flaky test retries; fix root causes.

LLM Interpretation Guidance (Web Components)
- Always author/update failing tests first based on Stage 1/2 docs; STOP to request approval before implementation.
- Assert public contract (attributes/properties/events/slots/parts). Do not query shadow internals.
- Prefer user-centric DOM queries and visible effects; use CSS custom properties/::part for styling assertions.
- For SSR/hydration, separate assertions for pre-hydration content vs post-hydration interactivity.
- In framework contexts, defer to the framework’s TDD override where guidance differs.

Superseded Base Sections (clarifications)
- Contract-first testing of attributes/properties, slots/parts, and custom events supersedes generic DOM-testing notes in Base/TypeScript sections for Custom Elements.

Routing and Related TDD
- Base TDD — [README](rules/generative/architecture/tdd/README.md)
- TypeScript TDD — [tdd.md](rules/generative/language/typescript/tdd.md)
- Angular TDD — [tdd.md](rules/generative/language/angular/tdd.md)
- React TDD — [tdd.md](rules/generative/language/react/tdd.md)
- Next.js TDD — [tdd.md](rules/generative/frontend/nextjs/tdd.md)
