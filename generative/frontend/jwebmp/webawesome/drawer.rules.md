# WaDrawer — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-drawer` sliding panels. Aligns with ../../webawesome/drawer.rules.md.

Usage
- Place in clusters/stacks; configure placement, open state, modal/overlay behavior, and size via fluent setters.
- Populate header/body/footer with child components; avoid inline HTML.

Patterns
- Keep CRTP chaining; no builders.
- Ensure focus management/escape close aligns with base behavior.
