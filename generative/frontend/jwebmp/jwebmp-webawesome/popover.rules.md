# Popover Rules

Defines usage rules for the WebAwesome Popover component.

## Overview
- Tag: `<wa-popover>`
- Purpose: Displays contextual content and interactive elements in a floating panel.
- React wrapper: WaPopover (onWaShow, onWaAfterShow, onWaHide, onWaAfterHide)
- Status: stable
- Since: 3.0
- Depends on: `<wa-popup>`

## Slots
- default — Popover content; interactive elements supported.

## Events
- `wa-show` — Emitted when the popover begins to show. Cancelable.
- `wa-after-show` — Emitted after the popover has shown and animations complete.
- `wa-hide` — Emitted when the popover begins to hide. Cancelable.
- `wa-after-hide` — Emitted after the popover has hidden and animations complete.

### React wrapper event props
- Use `onWaShow`, `onWaAfterShow`, `onWaHide`, and `onWaAfterHide` in React (WebAwesome React 3.0.0).

## CSS Parts
- `dialog` — The native dialog element that contains the popover content.
- `body` — The popover's body where content is rendered.
- `popup` — The inner `<wa-popup>` element that positions the popover.
- `popup__popup` — Exported `popup` part from `<wa-popup>`; targets container.
- `popup__arrow` — Exported `arrow` part from `<wa-popup>`; targets arrow.

## CSS Custom Properties
- `--arrow-size` (default `0.375rem`) — Size of the arrow; set to `0` to remove.
- `--max-width` (default `25rem`) — Maximum width of the body content.
- `--show-duration` (default `100ms`) — Show animation speed.
- `--hide-duration` (default `100ms`) — Hide animation speed.

## CSS States
- `open` — Applied when the popover is open.

## Usage Example
```html
<wa-popover id="help-popover">
  <p>Helpful context and actions here.</p>
</wa-popover>

<wa-button onclick="document.getElementById('help-popover').show()">
  Help
</wa-button>
```

## Integration Notes
- You can position `<wa-popover>` via its internal `<wa-popup>`; for low-level control, see `./popup.rules.md`.
- Use `(wa-show)`/`(wa-hide)` to intercept and cancel showing/hiding as needed.
- In React, subscribe using `onWaShow`, `onWaAfterShow`, `onWaHide`, `onWaAfterHide`.
