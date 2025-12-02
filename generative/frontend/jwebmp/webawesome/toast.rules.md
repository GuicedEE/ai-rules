# WaToast — WebAwesome (JWebMP Wrapper)

Wrapper set for toast notifications: `WaToastContainer`, `WaToastItem`, and `WaToastDataService`. No base WebAwesome rule exists; align with Angular Awesome toast docs.

Usage
- Place a single `WaToastContainer` in the layout (clusters/stacks) with position, max, duration, gap, z-index configured via fluent setters or `[binding]` helpers.
- Use `WaToastDataService`/`WaToastItem` to enqueue toasts on the client; expose priority, message, and variant per Angular Awesome API.
- Keep containers/layout grid utilities on the parent cluster; stacks remain unaffected by grid classes.

Patterns
- Keep CRTP chaining; avoid builders and inline HTML for toast body—use components or plain text via setters.
- Ensure accessibility: provide role/status and dismiss controls matching base toast semantics.
- Tests should assert container attributes and rendered toast markup via Java Micro Harness.
