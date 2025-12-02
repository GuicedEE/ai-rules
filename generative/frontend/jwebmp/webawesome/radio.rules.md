# WaRadio — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-radio` and `wa-radio-group`. Aligns with ../../webawesome/radio.rules.md and radio-group rules.

Usage
- Use `WaRadioGroup` to wrap `WaRadio` items; configure orientation (`RadioOrientation`), appearance (`RadioAppearance`), value/name, and disabled/required states via fluent setters.
- Place groups in clusters/stacks; no implicit columns.

Patterns
- Keep CRTP chaining; avoid inline HTML labels.
- Support keyboard navigation and set `aria-checked` per base rules.
