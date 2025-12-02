# WaTree — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-tree` and `wa-tree-item`. Aligns with ../../webawesome/tree.rules.md and tree-item rules.

Usage
- Compose `WaTree` with `WaTreeItem` children; configure selection mode (`TreeSelectionMode`), expanded state, icons/labels via fluent setters.
- Place in clusters/stacks; no implicit grid.

Patterns
- Keep CRTP chaining; avoid inline HTML for labels.
- Ensure keyboard navigation, aria roles, and selection semantics match base rules.
