# WaTooltip — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-tooltip`. Aligns with ../../webawesome/tooltip.rules.md.

Usage
- Attach `WaTooltip` to triggers inside clusters/stacks; configure content, `TooltipPlacement`, open/close delays, hover/click triggers, and interactive behavior via fluent setters.
- Popper-style positioning is handled by the component; parent grid utilities do not change placement.

Patterns
- Keep CRTP chaining; avoid inline HTML—use components for rich tooltip content if supported.
- Provide accessible labels/ids per base rules.
