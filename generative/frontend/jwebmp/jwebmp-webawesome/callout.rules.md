# Callout Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

## Overview

`<wa-callout>` displays inline messages or alerts. It supports color variants, size and appearance options, and an optional icon via slot.

This wrapper ensures Angular compatibility with proper type coercion and slot projection.

---

## Inputs

| Input      | Type     | Binding                        | Description                                                                 |
|------------|----------|--------------------------------|-----------------------------------------------------------------------------|
| `variant`  | `'brand' \| 'neutral' \| 'success' \| 'warning' \| 'danger' \| 'inherit'` | `[variant]` or string | Sets the semantic color theme. Default is `'inherit'`.                     |
| `appearance` | `'accent' \| 'filled' \| 'outlined' \| 'plain' \| 'outlined filled' \| 'outlined accent'` | `[appearance]` or string | Visual appearance. Can be a space-separated combination. Default: `'outlined filled'`. |
| `size`     | `'small' \| 'medium' \| 'large' \| 'inherit'` | `[size]` or string      | Affects spacing and icon size. Default is `'inherit'`.                     |

> ✅ All inputs must support both string literals and Angular bindings.

---

## Slots

| Slot     | Description                                                   |
|----------|---------------------------------------------------------------|
| `default`| Main content of the callout.                                   |
| `icon`   | Optional icon slot. Typically used with `<wa-icon>`.           |

---

## Usage Guidelines

- Use `[variant]`, `[appearance]`, and `[size]` to bind dynamically, or set as string literals.
- Slot support must allow projected icon elements (e.g., `<wa-icon slot="icon">`).
- Component does not emit custom events.
- Boolean inputs (if added in future) must follow `true => attr=""` and falsy => omit.

---

## Example

```html
<wa-callout variant="success" appearance="outlined filled" size="medium">
  <wa-icon slot="icon" name="circle-check" variant="regular"></wa-icon>
  <strong>Success!</strong><br />
  Your changes have been saved.
</wa-callout>
```

 This directive follows the Angular Web Awesome integration guide as outlined in RULES.md.
