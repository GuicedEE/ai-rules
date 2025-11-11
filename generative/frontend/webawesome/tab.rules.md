# Tab Rules

Defines usage rules for WebAwesome Tab, used inside `<wa-tab-group>` to activate `<wa-tab-panel>`.

## Overview
- Tag: `<wa-tab>`
- Purpose: Represents and activates a corresponding tab panel within a tab group.
- React wrapper: WaTab
- Status: stable
- Since: 2.0
- Related: `<wa-tab-group>`, `<wa-tab-panel>`

## Slots
- default — The tab's label/content.

## CSS Parts
- `base` — The component's base wrapper.

## Accessibility
- Tabs are managed by `<wa-tab-group>` which assigns appropriate ARIA roles and keyboard navigation.
- Provide concise, descriptive labels as the tab content.

## Example
```html
<wa-tab-group>
  <wa-tab>Account</wa-tab>
  <wa-tab>Security</wa-tab>
  <wa-tab>Billing</wa-tab>

  <wa-tab-panel>Account content…</wa-tab-panel>
  <wa-tab-panel>Security content…</wa-tab-panel>
  <wa-tab-panel>Billing content…</wa-tab-panel>
</wa-tab-group>
```

## Integration Notes
- In React, use `<WaTab>` as a child of `<WaTabGroup>` with corresponding `<WaTabPanel>` elements.
- Selection is controlled by the tab group; individual tabs do not emit events directly.
