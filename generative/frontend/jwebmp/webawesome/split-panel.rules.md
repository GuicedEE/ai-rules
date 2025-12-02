# WaSplitPanel — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-split-panel` for resizable panes. Aligns with ../../webawesome/split-panel.rules.md.

Usage
- Add `WaSplitPanel` with primary/secondary content; configure orientation, min/max sizes, and initial split via fluent setters; `SplitPanelPrimary` controls which pane sizes.
- Place within clusters/stacks; grid utilities stay on the parent container.

Patterns
- Keep CRTP chaining; ensure handles are keyboard-accessible and respect RTL when applicable.
