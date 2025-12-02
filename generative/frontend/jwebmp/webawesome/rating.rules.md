# WaRating — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-rating` components. Aligns with ../../webawesome/rating.rules.md.

Usage
- Place in clusters/stacks; configure max value, current value, precision, readonly/disabled, and labels via fluent setters.
- Use custom icons/slots for stars when needed; avoid inline HTML.

Patterns
- Keep CRTP chaining; expose aria labels for screen readers.
