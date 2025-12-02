# WaCard — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-card` containers. Follows ../../webawesome/card.rules.md for slots and styling.

Usage
- Place `WaCard` inside clusters/stacks; use header/body/footer slots via component children rather than inline HTML.
- Configure appearance, hover, and divider behaviors via fluent setters; keep CRTP return types.

Patterns
- Avoid mixing card padding overrides inline; prefer theme variables.
- Combine with WaStack inside the card for column layouts; add grid utilities to the surrounding cluster when needed.
