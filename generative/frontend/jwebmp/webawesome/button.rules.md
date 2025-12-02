# WaButton — WebAwesome (JWebMP Wrapper)

Use `WaButton<J extends WaButton<J>>` for WebAwesome buttons rendered from Java. Wraps the `wa-button` custom element and exposes slots/attributes as CRTP setters.

Usage
- Construct with text/variant (`new WaButton<>("Save", Variant.Brand)`) or default then call fluent setters returning `(J) this`; avoid builders.
- Attributes: `variant`, `appearance`, `size`, `pill`, `withCaret`, `loading`, `disabled`, `type` (HTML button type), form attributes (`form`, `formAction`, `formEnctype`, `formMethod`, `formNoValidate`, `formTarget`).
- Slots: `prefix` and `suffix` components get slot attributes set automatically when provided.
- Events: `wa-blur`, `wa-focus`, `wa-invalid` map to string handlers; avoid inline JS bodies longer than a simple call.
- Link usage: call `setAsLink(href, target, download)` to render hyperlink attributes on the button host.

Patterns
- Keep CRTP chaining without unchecked casts in subclasses; extend `WaButton` only when adding typed properties.
- Prefer enums (`Variant`, `Appearance`, `Size`) for styling; downcase values to match WebAwesome expectations.
- Avoid manual `setTag` changes; `WaButton` already sets `wa-button`.
- Align prompt language to “WaButton” and refer to base styling/behavior via `../../webawesome/button.rules.md`.

See also
- Input/Number Input — ./input.rules.md#number-input
- Layout — ./cluster.rules.md, ./stack.rules.md
- Base component behaviors — ../../webawesome/button.rules.md
- Testing — ./testing.rules.md
