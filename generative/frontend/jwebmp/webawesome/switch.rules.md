# WaSwitch — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-switch` toggle component. Mirrors ../../webawesome/switch.rules.md.

Usage
- Add to clusters/stacks; configure checked/value, disabled/readonly, and form binding via fluent setters and `bind()` when using Angular.
- Provide labels next to the switch using JWebMP components; avoid inline HTML.

Patterns
- Keep CRTP chaining; no builders.
- Ensure aria-checked and focus states follow base guidance.
