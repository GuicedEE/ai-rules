# WaTabGroup — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-tab-group`, `wa-tab`, and `wa-tab-panel`. Mirrors ../../webawesome/tab-group.rules.md, tab.rules.md, tab-panel.rules.md.

Usage
- Build tabs with `WaTabGroup` containing `WaTab` headers and `WaTabPanel` content; configure activation (`TabActivation`), placement (`TabPlacement`), and lazy/loading behavior via fluent setters.
- Place inside clusters/stacks; no implicit columns.

Patterns
- Keep CRTP chaining; avoid inline HTML for tab labels—use components/strings via setters.
- Ensure keyboard navigation and aria attributes align with base rules.
