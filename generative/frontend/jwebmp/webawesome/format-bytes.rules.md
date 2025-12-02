# WaFormatBytes — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-format-bytes` to format byte values. Mirrors ../../webawesome/format-bytes.rules.md.

Usage
- Add to clusters/stacks; set value, unit preferences, locale, and formatting options via fluent setters.
- Output is display-only; avoid mixing with form controls.

Patterns
- Keep CRTP chaining; ensure values are numeric and localized as needed.
