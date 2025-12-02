# WaComparison — WebAwesome (JWebMP Wrapper)

Wrapper for image/content comparison slider (`wa-comparison`). Mirrors ../../webawesome/comparison.rules.md.

Usage
- Place `WaComparison` inside clusters/stacks; configure before/after slots with child components (images, divs) instead of inline HTML.
- Adjust position/handle/label options via fluent setters; keep CRTP returns.

Patterns
- Ensure images have alt text; maintain keyboard accessibility for the handle.
- Avoid mixing with grid semantics on stacks; apply layout utilities on the surrounding cluster.
