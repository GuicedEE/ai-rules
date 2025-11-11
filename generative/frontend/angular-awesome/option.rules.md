# Option Rules

Defines usage rules for WebAwesome Option, used within `<wa-select>`.

## Overview
- Tag: `<wa-option>`
- Purpose: Defines a selectable item within `<wa-select>`.
- React wrapper: WaOption
- Status: stable
- Since: 2.0

## Attributes / Properties
- `value: string` — The option’s value.
- `disabled: boolean` — Disables selection of this option.
- `selected: boolean` — Marks as selected (usually managed by parent `<wa-select>`).
- `title: string` — Optional tooltip/label for the option.

Note: Keep `selected` source of truth in the parent where possible. Prefer setting/selecting via the parent component’s API.

## Slots
- default — The option’s label/content.
- `start` — Content (e.g., `<wa-icon>`) placed before the label.
- `end` — Content placed after the label.

## CSS Parts
- `checked-icon` — The checked icon (`<wa-icon>`).
- `label` — The label container.
- `start` — Wrapper around `start` slot.
- `end` — Wrapper around `end` slot.

## CSS States
- `current` — The user has keyed into (navigated to) the option.
- `selected` — The option is selected (`aria-selected="true"`).
- `hover` — Hover-like state used during drag interactions (Safari compatibility).

## Accessibility
- Must be contained in a `<wa-select>` which manages `role="listbox"`/`role="option"` semantics.
- Provide meaningful text in the default slot for screen readers.

## Example
```html
<wa-select label="Favorite">
  <wa-option value="apples">Apples</wa-option>
  <wa-option value="bananas" selected>Bananas</wa-option>
  <wa-option value="cherries" disabled>
    <wa-icon slot="start" name="circle-xmark"></wa-icon>
    Cherries (out of stock)
  </wa-option>
</wa-select>
```

## Integration Notes
- In React, use `<WaOption value="...">Label</WaOption>` children of `<WaSelect>`.
- Do not bind to `selected` directly; prefer setting `value`/`defaultValue` on the parent select.