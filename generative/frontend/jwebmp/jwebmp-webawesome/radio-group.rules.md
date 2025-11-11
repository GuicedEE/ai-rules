# Radio Group Rules

Defines usage rules for WebAwesome Radio Group.

## Overview
- Tag: `<wa-radio-group>`
- Purpose: Groups multiple `<wa-radio>` elements to function as a single form control.
- React wrapper: WaRadioGroup (onWaInvalid)
- Status: stable
- Since: 2.0
- Depends on: `<wa-radio>`

## Slots
- default — Place `<wa-radio>` elements here.
- `label` — The radio group's label (recommended for accessibility) or use the `label` attribute.
- `hint` — Helper text explaining how to use the group or constraints; or use `hint` attribute.

## Events
- `change` — Emitted when the selected value changes.
- `input` — Emitted upon user input.
- `wa-invalid` — Emitted when validity is checked and constraints aren't satisfied.

### React wrapper event props
- Use `onWaInvalid` to subscribe in React (WebAwesome React 3.0.0).

## CSS Parts
- `form-control` — Wraps label, input, and hint.
- `form-control-label` — Label wrapper.
- `form-control-input` — Radios container wrapper.
- `radios` — Flex container around radio items.
- `hint` — Hint text wrapper.

## Accessibility
- Always provide a visible label via the `label` slot/attribute.
- Manage tab order via natural flow; each `<wa-radio>` is focusable, but group label ties them logically.

## Example
```html
<wa-radio-group label="Shipping Method">
  <wa-radio value="standard">Standard</wa-radio>
  <wa-radio value="express">Express</wa-radio>
</wa-radio-group>
```

## Integration Notes
- In React, use `<WaRadioGroup>` with `<WaRadio>` children. Read selected value via standard form mechanisms or listen to `change`.
- Use `onWaInvalid` to hook into validation states.
