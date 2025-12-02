# WaCheckbox — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-checkbox`. Attributes/events mirror ../../webawesome/checkbox.rules.md; use CRTP setters on `WaCheckbox<J>`.

Usage
- Instantiate and add to clusters/stacks; no implicit column wrappers.
- Configure checked/indeterminate states, value/name, disabled/readonly, and form association via fluent setters.
- Provide label via component children or label attributes; keep accessible `aria-*` as needed.

Patterns
- Avoid inline HTML for labels; use JWebMP components.
- Keep two-way binding with Angular via `bind()` when needed, consistent with WebAwesome semantics.
