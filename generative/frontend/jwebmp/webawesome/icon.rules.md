# WaIcon — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-icon` with support for `IconFamily` and `IconVariant`. Aligns with ../../webawesome/icon.rules.md.

Usage
- Add to clusters/stacks or prefix/suffix slots on other Wa* components.
- Configure name, family (e.g., Font Awesome), variant/style, and label for accessibility via fluent setters.
- Use CSS variables for sizing/color per theme instead of inline styles.

Patterns
- Keep CRTP chaining; avoid builders.
- Provide `aria-hidden`/label according to base rules to prevent duplicate announcements.
