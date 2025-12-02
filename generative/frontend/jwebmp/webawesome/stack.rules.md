# WaStack — WebAwesome (JWebMP Wrapper)

`WaStack` is the vertical layout primitive (columns) that applies the `wa-stack` class and inherits gap/vertical alignment helpers.

Usage
- Create a `WaStack` and add children components directly; gap and alignment setters come from `GapCapable` and `AlignVerticalCapable`.
- Favor stacks for form sections and dialog bodies; pair with `WaCluster` for nested horizontal rows.
- Keep CRTP behavior (`WaStack` already extends `DivSimple<WaStack>`); avoid builders or final classes that would block extension.

Patterns
- `WaStack` is a simple vertical list—no grid semantics. Grid/utility classes applied to a cluster will not affect a stack unless added directly to the stack.
- Prefer CSS-driven spacing; only use inline gap styles when composing dynamic UI in Java.
- Align prompt language to “WaStack” for column/stacked layouts to avoid ambiguous “row/column” phrasing.
- Combine with WaButton/WaInput rules when building form layouts.

See also
- Row layout — ./cluster.rules.md
- Components — ./button.rules.md, ./input.rules.md#number-input
- Base layout guidance — ../../webawesome/page.rules.md
