# Tab Panel Rules

Defines usage rules for WebAwesome Tab Panel, used inside `<wa-tab-group>` to display content for the active tab.

## Overview
- Tag: `<wa-tab-panel>`
- Purpose: Displays the content associated with a corresponding `<wa-tab>` in a `<wa-tab-group>`.
- React wrapper: WaTabPanel
- Status: stable
- Since: 2.0
- Related: `<wa-tab-group>`, `<wa-tab>`

## Slots
- default — The tab panel's content.

## CSS Parts
- `base` — The component's base wrapper.

## CSS Custom Properties
- `--padding` — Controls the tab panel's internal padding.

## Accessibility
- Managed by `<wa-tab-group>`, which sets ARIA attributes and ensures the correct panel is shown/hidden.
- Keep panel content focusable; initial focus behavior is managed by the group.

## Example
```html
<wa-tab-group>
  <wa-tab>General</wa-tab>
  <wa-tab>Advanced</wa-tab>

  <wa-tab-panel>
    <p>General settings…</p>
  </wa-tab-panel>
  <wa-tab-panel>
    <p>Advanced settings…</p>
  </wa-tab-panel>
</wa-tab-group>
```

## Integration Notes
- In React, use `<WaTabPanel>` as a child of `<WaTabGroup>`, matching order with `<WaTab>` items.
- Styling can be applied via the `--padding` CSS custom property or the `base` part.
