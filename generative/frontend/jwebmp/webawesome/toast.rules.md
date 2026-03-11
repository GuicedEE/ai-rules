# WaToast — WebAwesome (JWebMP Wrapper)

Wrapper set for toast notifications: `WaToastContainer`, `WaToastItem`, and `WaToastDataService`. Aligns with Angular Awesome toast docs and the official `<wa-toast>` + `<wa-toast-item>` web components.

Usage
- Place a single `WaToastContainer` in the layout (renders `<wa-toast>`) with placement, max, duration, newestOnTop configured via fluent setters or `[binding]` helpers.
- `gap` is set via the `--gap` CSS custom property on `<wa-toast>`, not as a Java setter. `zIndex` is managed natively by the component.
- `closable` is handled natively by the `<wa-toast-item>` web component and is not part of the Java API.
- Use `WaToastDataService`/`WaToastItem` to enqueue toasts on the client; expose message, variant, and duration per Angular Awesome API.
- Keep containers/layout grid utilities on the parent cluster; stacks remain unaffected by grid classes.

Patterns
- Keep CRTP chaining; avoid builders and inline HTML for toast body—use components or plain text via setters.
- Ensure accessibility: provide role/status and dismiss controls matching base toast semantics.
- Tests should assert container attributes and rendered toast markup via Java Micro Harness.
