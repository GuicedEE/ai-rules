# WaDetails — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-details` (disclosure/accordion). Matches ../../webawesome/details.rules.md.

Usage
- Add `WaDetails` to clusters/stacks; set summary/content via child components; control open state, appearance, and icon position through fluent setters.
- Choose `DetailsAppearance` and `IconPosition` enums as needed; keep CRTP returns.

Patterns
- Provide keyboard-accessible summaries; avoid inline HTML strings.
- Nesting details is allowed but avoid deep nesting for usability.
