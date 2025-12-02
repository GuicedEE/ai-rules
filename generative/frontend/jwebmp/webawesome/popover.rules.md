# WaPopover — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-popover` anchored overlays. Mirrors ../../webawesome/popover.rules.md.

Usage
- Wrap trigger and content with `WaPopover`; configure open state, trigger modes, placement (`WaPopoverPlacements`), and hover/click behavior via fluent setters.
- Use within clusters/stacks; grid utilities on the parent do not alter popover positioning.

Patterns
- Keep CRTP chaining; avoid inline HTML content—use components.
- Provide accessible labels/describedby links per base rules.
