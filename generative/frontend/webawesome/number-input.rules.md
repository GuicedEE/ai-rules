# Number Input Component Rules

📌 Follows enterprise rules format. See WebAwesome index: ./README.md and group index: ../README.md.

## Overview

`<wa-number-input>` is a numeric form control with optional steppers and rich configuration. It is form-associated and works with native validation.

Key points:
- Use Angular bindings for booleans: `[required]="true"`, `[without-steppers]="true"`.
- For SSR scenarios, use `with-label` / `with-hint` to render slots on initial paint.

---

## Inputs (common)

- `value`: `string | number` — current value
- `size`: `'small' | 'medium' | 'large'` (default: `medium`)
- `appearance`: `'filled' | 'outlined' | 'filled-outlined'` (default: `outlined`)
- `pill`: `boolean`
- `label`: `string`
- `hint`: `string`
- `placeholder`: `string`
- `readonly`: `boolean`
- `required`: `boolean`
- `min`: `number`
- `max`: `number`
- `step`: `number | 'any'` (default: `1`)
- `without-steppers`: `boolean` — hides increment/decrement buttons
- `autocomplete`: `string`
- `autofocus`: `boolean`
- `enterkeyhint`: `'enter' | 'done' | 'go' | 'next' | 'previous' | 'search' | 'send'`
- `inputmode`: `'numeric' | 'decimal'` (default: `numeric`)
- `with-label`: `boolean` — SSR hint
- `with-hint`: `boolean` — SSR hint

## Events

- `input`, `change`, `blur`, `focus`, `wa-invalid`

## Slots

- `label`, `start`, `end`, `increment-icon`, `decrement-icon`, `hint`

## CSS Parts

- `label`, `form-control-label`, `hint`, `base`, `input`, `start`, `end`, `stepper`, `stepper-increment`, `stepper-decrement`

## Angular Usage

```html
<!-- Basic numeric input -->
<wa-number-input label="Quantity" min="1" max="10" step="1"></wa-number-input>

<!-- With steppers hidden and custom placeholder -->
<wa-number-input placeholder="Enter a number" [without-steppers]="true"></wa-number-input>

<!-- Validation and events -->
<wa-number-input
  label="Units"
  [required]="true"
  (input)="$event"
  (wa-invalid)="$event">
</wa-number-input>
```

## Notes

- Use `step="any"` to allow arbitrary decimals.
- Pair with form libraries as a native custom element; constraint validation events will fire as expected.
