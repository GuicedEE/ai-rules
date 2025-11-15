# Angular Awesome TDD (Plugin Supplement and Override)

Purpose
- Provide Angular Awesome–specific TDD guidance for wa-* custom elements used directly or via Angular standalone directive wrappers.
- Precedence and supersedence:
  - Base TDD — [TDD Architecture](rules/generative/architecture/tdd/README.md)
  - TypeScript TDD — [TypeScript TDD](rules/generative/language/typescript/tdd.md)
  - Angular TDD — [Angular TDD](rules/generative/language/angular/tdd.md)
  - Angular Awesome TDD (this file) — supersedes the above where wrapper/wa-* specifics differ.

Scope
- Applies when using Web Awesome components (wa-*) inside Angular templates, with or without thin directive wrappers that mirror attributes/events.
- Focuses on testing:
  - Attribute/property bridging behavior (Angular inputs → custom element attributes/properties)
  - Event bridging (custom events wa-* → Angular outputs like blurEvent/focusEvent)
  - Slots, CSS parts, CSS custom property mappings
  - SSR/hydration constraints with custom elements

Core TDD Workflow (inherits)
- Red → Green → Refactor, stage-gated and docs-first.
- Outside-in recommended:
  - Start with acceptance/E2E (Playwright) covering page/flow using wa-* components.
  - Drive component/service integration tests (Angular TestBed + wrappers), then unit specs for small helpers/pipes.
- Inside-out for logic-only utilities (formatters/validators), then wrap with integration/E2E tests.

Testing Levels and Focus (wa-* specifics)
- Unit tests (largest)
  - Angular wrapper directives (if present): verify that @Input()s set the correct attributes/properties on the host custom element, and that Output()s relay the correct custom events and payloads.
  - Pure helpers (e.g., value mappers, style variable setters).
  - Avoid asserting private internals of wrappers; assert public/contract behavior (host element attributes, events, styles).
- Integration tests (moderate)
  - Composition of wrappers with Angular forms/routing/services.
  - HttpClientTestingModule for feature logic; MSW as alternative for network realism.
  - Component Harnesses when available; otherwise Testing Library for Angular with user-centered queries.
- Acceptance/E2E (smallest)
  - Playwright scenarios for feature flows involving wa-* components (dialogs, menus, inputs).
  - Assert SSR content presence and hydration success where Universal is used.

Tooling
- Runner: Vitest (preferred) or Jest
- Angular: TestBed + Testing Library for Angular
- HTTP: HttpClientTestingModule or MSW
- E2E: Playwright with data-testid for stability where semantics are insufficient
- Coverage: c8/V8 (Vitest) with thresholds enforced (≥ 80% lines/statements/functions; ≥ 70% branches)
- Lint/Format/Types: ESLint + Prettier + tsc/ng tsc in CI

Key Contracts to Test for wa-* Components

1) Attribute vs Property Bridging
- Boolean inputs must be property-bound (e.g., [disabled]="true").
- Attribute-equivalent @Input()s should set attributes on the host custom element.
- JS-only properties (e.g., keyframes/currentTime on wa-animation) must be assigned to element instance (post-init).
- Example (directive wrapper unit):
```ts
import { Component, ViewChild } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { WaButtonDirective } from './button.directive';

@Component({
  standalone: true,
  imports: [WaButtonDirective],
  template: `<wa-button [loading]="loading" [appearance]="'filled'">Save</wa-button>`
})
class HostCmp {
  loading = true;
}

it('sets attributes and boolean properties on host wa-button', () => {
  const fixture = TestBed.configureTestingModule({ imports: [HostCmp] }).createComponent(HostCmp);
  fixture.detectChanges();
  const hostEl = fixture.debugElement.query(By.css('wa-button')).nativeElement as HTMLElement;

  // loading is a boolean property, not an attribute string
  expect(hostEl.hasAttribute('loading')).toBe(false);
  expect((hostEl as any).loading).toBe(true);

  // appearance is an attribute-equivalent input
  expect(hostEl.getAttribute('appearance')).toBe('filled');
});
```

2) Events and Output Relay
- Custom events often use wa-* names (e.g., wa-start, wa-finish) and bubble.
- Wrappers must avoid collisions with native blur/focus (use blurEvent/focusEvent).
- Test that the Angular outputs fire with correct payloads when the host dispatches custom events.
```ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Component, ViewChild } from '@angular/core';
import { By } from '@angular/platform-browser';
import { WaAnimationDirective } from './animation.directive';

@Component({
  standalone: true,
  imports: [WaAnimationDirective],
  template: `<wa-animation name="bounce" (waFinish)="onFinish()"><div></div></wa-animation>`
})
class HostCmp {
  finished = 0;
  onFinish() { this.finished++; }
}

it('relays wa-finish custom event to Angular output', () => {
  const fixture = TestBed.configureTestingModule({ imports: [HostCmp] }).createComponent(HostCmp);
  fixture.detectChanges();
  const hostEl = fixture.debugElement.query(By.css('wa-animation')).nativeElement as HTMLElement;

  hostEl.dispatchEvent(new CustomEvent('wa-finish', { bubbles: true, composed: true }));
  fixture.detectChanges();

  expect(fixture.componentInstance.finished).toBe(1);
});
```

3) Slots and CSS Parts
- Verify slot usage (default/prefix/suffix/separator) by asserting rendered content and roles/text, not shadow internals.
- CSS parts are asserted via visible effects or computed styles after setting CSS custom properties on host.
```ts
import { render, screen } from '@testing-library/angular';

it('renders prefix slot with icon', async () => {
  await render(`<wa-button><wa-icon slot="prefix" name="gear"></wa-icon>Save</wa-button>`);
  expect(screen.getByText(/save/i)).toBeInTheDocument();
});
```

4) CSS Custom Property Mappings
- If wrappers expose inputs that map to CSS custom properties (e.g., [textColor] → --text-color), test that style properties are applied to host element.
```ts
const btn = document.createElement('wa-button') as HTMLElement;
btn.style.setProperty('--text-color', 'rebeccapurple');
document.body.appendChild(btn);
expect(getComputedStyle(btn).getPropertyValue('--text-color').trim()).toBe('rebeccapurple');
```

5) SSR and Hydration
- Prefer SSR tests that assert server-rendered content exists without client JS.
- On hydration, assert interactive behavior works without flicker/regressions.
- For Declarative Shadow DOM, confirm server templates render; otherwise assert post-hydration markers.

6) Forms Policy Interactions
- Input: template-driven only with [(ngModel)] per rules; assert two-way binding correctness and name attribute requirements.
- Checkbox: supports reactive forms; test formControlName binding and validity transitions.

Examples by Component

- wa-input template-driven ngModel
```ts
await render(`<form><wa-input name="email" [(ngModel)]="value" label="Email"></wa-input></form>`, {
  componentProperties: { value: '' }
});
// Simulate typing with user-event then assert model update via bindings or element property
```

- wa-checkbox reactive forms
```ts
import { ReactiveFormsModule, FormControl, FormGroup } from '@angular/forms';
await render(
  `<form [formGroup]="form"><wa-checkbox formControlName="accept">Accept</wa-checkbox></form>`,
  {
    imports: [ReactiveFormsModule],
    componentProperties: { form: new FormGroup({ accept: new FormControl(false) }) }
  }
);
```

- wa-animation JS-only properties
```ts
await render(`<wa-animation></wa-animation>`);
const el = document.querySelector('wa-animation') as any;
el.keyframes = [{ offset: 0, transform: 'rotate(0deg)' }, { offset: 1, transform: 'rotate(90deg)' }];
el.currentTime = 0.25;
// Assert behavior through downstream effects (e.g., event emission, style), not internals
```

Playwright E2E Patterns
- Prefer role/label/text selectors; use data-testid only when required.
- Typical flows:
  - Button: click/save; assert spinner/disabled states and eventual success message
  - Dialog/Drawer: open/close/confirm
  - Menu/Dropdown: open, navigate via keyboard, select item, assert command executed
  - Input/Checkbox/Select: fill/select and assert reflected value and emitted change events via UI state

Anti-Patterns to Avoid
- Querying shadow DOM internals (unstable; violates encapsulation)
- Binding boolean inputs as strings (e.g., disabled="true")
- Over-mocking to assert internal implementation; prefer contract-level verification
- Asserting microtask order; prefer final state assertions

Coverage and CI Gates (supersedes where stricter)
- Enforce ≥ 80% lines/statements/functions and ≥ 70% branches via Vitest/Jest config.
- Fail CI on unhandled network (MSW with onUnhandledRequest: 'error' in CI).
- No flaky test retries; fix root cause.

LLM Interpretation Guidance (Angular Awesome)
- Write/modify failing tests first based on Stage 1/2 docs; STOP and request approval before implementation.
- For wrappers:
  - Assert @Input() → attribute/property effects on host custom element
  - Assert Output() → custom event relay with detail and event flags
  - Assert CSS variable mappings and ::part styling via visible effects
- For SSR/hydration: separate SSR assertions (content presence) from hydration assertions (interactivity).
- Defer to Angular TDD for TestBed/Test Harness patterns; this supplement focuses on wrapper/wa-* contracts.

Routing and Related TDD
- Base TDD — [README](rules/generative/architecture/tdd/README.md)
- TypeScript TDD — [tdd.md](rules/generative/language/typescript/tdd.md)
- Angular TDD — [tdd.md](rules/generative/language/angular/tdd.md)
- Web Components TDD — [tdd.md](rules/generative/frontend/webcomponents/tdd.md)