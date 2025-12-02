# WaScroller — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-scroller` virtualized scroll container. Aligns with ../../webawesome/scroller.rules.md.

Usage
- Wrap scrollable content; configure orientation, scrollbars, and thresholds via fluent setters.
- Place within clusters/stacks; grid utilities on parents do not change scrolling behavior.

Patterns
- Keep CRTP chaining; ensure focusable content remains reachable via keyboard.
