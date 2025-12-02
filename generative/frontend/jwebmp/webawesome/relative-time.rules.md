# WaRelativeTime — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-relative-time`. Mirrors ../../webawesome/relative-time.rules.md.

Usage
- Configure date/time value, format, and locale via fluent setters; place in clusters/stacks as display text.
- Output-only; no form binding.

Patterns
- Keep CRTP chaining; ensure time source is timezone-aware.
