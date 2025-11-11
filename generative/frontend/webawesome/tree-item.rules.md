# Tree Item Rules

Defines usage rules for WebAwesome Tree Item, used within `<wa-tree>`.

## Overview
- Tag: `<wa-tree-item>`
- Purpose: A hierarchical node that lives inside a `<wa-tree>`; supports expansion, selection, lazy loading, and multiselect.
- React wrapper: WaTreeItem (onWaExpand, onWaAfterExpand, onWaCollapse, onWaAfterCollapse, onWaLazyChange, onWaLazyLoad)
- Status: stable
- Since: 2.0
- Depends on: `<wa-checkbox>`, `<wa-icon>`, `<wa-spinner>`

## Events
- `wa-expand` — Emitted when the item expands.
- `wa-after-expand` — Emitted after expand animations complete.
- `wa-collapse` — Emitted when the item collapses.
- `wa-after-collapse` — Emitted after collapse animations complete.
- `wa-lazy-change` — Emitted when the item's lazy state changes.
- `wa-lazy-load` — Emitted when a lazy item is selected; load data and append children, then remove `lazy`.

## Slots
- default — The item's label and any inline content.
- `expand-icon` — Icon to show when the item is expanded.
- `collapse-icon` — Icon to show when the item is collapsed.

## CSS Parts
- `base` — Component base wrapper.
- `item` — Container wrapping the row content.
- `indentation` — Indentation container.
- `expand-button` — Wrapper around expand button and spinner.
- `spinner` — Spinner shown during lazy loading.
- `spinner__base` — Exported `base` part of the spinner.
- `label` — Label content container.
- `children` — Wrapper for nested child items.
- `checkbox` — Checkbox shown when using multiselect.
- `checkbox__base` — Exported `base` part of the checkbox.
- `checkbox__control` — Exported `control` part of the checkbox.
- `checkbox__checked-icon` — Exported `checked-icon` part of the checkbox.
- `checkbox__indeterminate-icon` — Exported `indeterminate-icon` part of the checkbox.
- `checkbox__label` — Exported `label` part of the checkbox.

## CSS Custom Properties
- `--show-duration` (default `200ms`) — Expand animation duration.
- `--hide-duration` (default `200ms`) — Collapse animation duration.

## CSS States
- `disabled` — Applied when disabled.
- `expanded` — Applied when expanded.
- `indeterminate` — Applied when selection is indeterminate.
- `selected` — Applied when selected.

## Example
```html
<wa-tree selection="multiple">
  <wa-tree-item expanded>
    Parent
    <wa-tree-item>Child A</wa-tree-item>
    <wa-tree-item lazy>Child B (lazy)</wa-tree-item>
  </wa-tree-item>
</wa-tree>
<script>
  const tree = document.querySelector('wa-tree');
  tree.addEventListener('wa-lazy-load', (ev) => {
    const item = ev.target;
    // simulate async
    setTimeout(() => {
      const child = document.createElement('wa-tree-item');
      child.textContent = 'Loaded child';
      item.appendChild(child);
      item.removeAttribute('lazy');
    }, 500);
  });
</script>
```

## Integration Notes
- In React, subscribe using `onWaExpand`, `onWaAfterExpand`, `onWaCollapse`, `onWaAfterCollapse`, `onWaLazyChange`, and `onWaLazyLoad` on `<WaTreeItem>`.
- When using multiselect, the parent `<wa-tree>` manages checkbox state; avoid manually toggling checkbox parts.
