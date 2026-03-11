# WaToast - WebAwesome (JWebMP Wrapper)

Wrapper set for toast notifications: `WaToastContainer`, `WaToastItem`, and `WaToastDataService`. Aligns with the `wa-toast` implementation and examples.

Usage
- Place a single `WaToastContainer` in the layout (renders `<wa-toast>`), using `placement`, `max`, `duration`, and `newestOnTop` where needed.
- `gap` is configured through CSS custom property `--gap` on `<wa-toast>`, not a Java setter. `zIndex` is managed natively.
- Close behavior is handled by native `<wa-toast-item>` semantics and the service API (`close`/`clearAll`).
- Use `WaToastDataService` and `WaToastItem` for programmatic notifications: `setConfig`, `show`, `update`, `close`, `clearAll`.
- Variant helper methods are available: `success`, `warning`, `danger`, `brand`, `neutral`.

Patterns
- Keep CRTP chaining; avoid builders and inline HTML for toast body.
- Use plain text or component content for message/title fields.
- Keep docs/tests aligned with official placement values:
  `top-start`, `top-center`, `top-end`, `bottom-start`, `bottom-center`, `bottom-end`.
