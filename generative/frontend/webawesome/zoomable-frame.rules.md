# Zoomable Frame Rules

Defines usage rules for WebAwesome Zoomable Frame.

## Overview
- Tag: `<wa-zoomable-frame>`
- Purpose: Renders iframe content with built-in zoom and interaction controls.
- React wrapper: WaZoomableFrame
- Status: stable
- Since: 3.0
- Depends on: `<wa-icon>`

## Slots
- `zoom-in-icon` — Slot containing the zoom-in icon.
- `zoom-out-icon` — Slot containing the zoom-out icon.

## Events
- `load` — Emitted when the internal iframe finishes loading.
- `error` — Emitted when the internal iframe fails to load.

## CSS Parts
- `iframe` — The internal `<iframe>` element.
- `controls` — Container that surrounds zoom control buttons.
- `zoom-in-button` — Zoom in button.
- `zoom-out-button` — Zoom out button.

## Example
```html
<wa-zoomable-frame src="/docs/preview.html" style="width: 100%; height: 480px;">
  <wa-icon slot="zoom-in-icon" name="plus"></wa-icon>
  <wa-icon slot="zoom-out-icon" name="minus"></wa-icon>
</wa-zoomable-frame>
```

## Integration Notes
- In React, use `<WaZoomableFrame src="..." />` and optionally provide slotted icons via children.
- Listen for `load` and `error` as needed to manage loading states.
- Use CSS parts to customize control appearance; icons can be swapped via slots.
