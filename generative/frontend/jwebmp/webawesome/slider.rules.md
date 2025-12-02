# WaRange (Slider) — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-slider` (range input). Mirrors ../../webawesome/slider.rules.md.

Usage
- Add `WaRange` to clusters/stacks; configure label/hint slots, value/defaultValue, min/max/step, `range` (dual-thumb), disabled/readonly/required, form association, and tooltip position via fluent setters.
- Use `withLabel`/`withHint` flags for SSR slot hints; avoid inline HTML.

Patterns
- Keep CRTP chaining; avoid builders.
- Provide number values as strings/numbers; ensure accessibility for keyboard users.
