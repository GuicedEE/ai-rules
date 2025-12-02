# WaSelect — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-select` and `wa-option`. Mirrors ../../webawesome/select.rules.md and option rules.

Usage
- Use `WaSelect` with `WaSelectOption` children; configure appearance (`SelectAppearance`), placement (`SelectPlacement`), value/name, clear/searchable states, disabled/readonly, and form binding via fluent setters.
- Add to clusters/stacks; no implicit columns.

Patterns
- Keep CRTP chaining; avoid inline option HTML—use `WaSelectOption`.
- Support keyboard navigation and aria attributes per base rules.
