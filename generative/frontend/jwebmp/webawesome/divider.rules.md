# WaDivider — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-divider` horizontal/vertical separators. Mirrors ../../webawesome/divider.rules.md.

Usage
- Insert between components in clusters/stacks; configure orientation, spacing, and optional text/slot via fluent setters.
- Avoid treating as layout grid; it simply separates content.

Patterns
- Keep CRTP chaining; avoid inline HR tags.
- Use meaningful aria labels when including text.
