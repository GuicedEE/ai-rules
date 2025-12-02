# WaDialog — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-dialog` modal dialogs. Aligns with ../../webawesome/dialog.rules.md.

Usage
- Place `WaDialog` in clusters/stacks; configure open state, modal/closable options, labels, and size via fluent setters; add header/body/footer content with child components.
- Ensure focus trapping and escape/overlay closing behaviors follow base WebAwesome defaults; expose toggles in host UI when changing.

Patterns
- Avoid inline HTML; use JWebMP components for content and buttons.
- Keep CRTP chaining; no builders.
- Honor accessibility requirements (aria-modal, aria-labelledby/aria-describedby).
