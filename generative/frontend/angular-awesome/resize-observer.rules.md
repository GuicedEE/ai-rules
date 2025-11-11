# Resize Observer Rules

Defines usage rules for WebAwesome Resize Observer.

## Overview
- Tag: `<wa-resize-observer>`
- Purpose: Declarative interface for the ResizeObserver API; emits events when observed elements resize.
- React wrapper: WaResizeObserver (onWaResize)
- Status: stable
- Since: 2.0

## Slots
- default — One or more elements to observe for size changes.

## Events
- `wa-resize` — Detail: `{ entries: ResizeObserverEntry[] }` when the element(s) are resized.

### React wrapper event props
- Use `onWaResize` to subscribe in React (WebAwesome React 3.0.0).

## Example
```html
<wa-resize-observer id="ro">
  <div style="resize: both; overflow: auto; width: 200px; height: 100px; border: 1px solid #ccc;">
    Drag the handle to resize me
  </div>
</wa-resize-observer>
<script>
  document.getElementById('ro').addEventListener('wa-resize', (ev) => {
    for (const entry of ev.detail.entries) {
      const cr = entry.contentRect;
      console.log('New size:', cr.width, cr.height);
    }
  });
</script>
```

## Integration Notes
- Prefer this component when you need to react to element size changes without manual observers.
- For configuration options, refer to WebAwesome docs; otherwise, fall back to native ResizeObserver for specialized cases.
