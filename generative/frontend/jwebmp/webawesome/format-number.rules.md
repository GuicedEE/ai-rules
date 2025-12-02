# WaFormatNumber — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-format-number` to localize numbers. Mirrors ../../webawesome/format-number.rules.md.

Usage
- Set value, style (decimal/currency/percent/unit), currency, minimum/maximum digits, and grouping via fluent setters.
- Place in clusters/stacks; output-only.

Patterns
- Keep CRTP chaining; supply locale/currency codes explicitly when needed.
