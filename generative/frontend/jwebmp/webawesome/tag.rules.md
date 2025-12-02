# WaTag — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-tag` labels/chips. Aligns with ../../webawesome/tag.rules.md.

Usage
- Add to clusters/stacks; configure appearance (`TagAppearance`), size, removable/disabled states, and optional icon slots via fluent setters.
- Use for metadata labels, filters, or pills; avoid using as layout.

Patterns
- Keep CRTP chaining; handle remove events according to base rules.
- Ensure text contrast meets accessibility requirements.
