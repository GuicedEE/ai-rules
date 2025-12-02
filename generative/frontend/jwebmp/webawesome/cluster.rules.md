# WaCluster — WebAwesome (JWebMP Wrapper)

`WaCluster<J extends WaCluster<J>>` provides horizontal layout (rows) using the `wa-cluster` class with configurable gaps, alignment, and optional nowrap behavior.

Usage
- Instantiate and add children directly (there is no Bootstrap-style column wrapper); `wa-cluster` class is set by default.
- Apply gap/vertical alignment via `GapCapable` and `AlignVerticalCapable` setters (inherit from JWebMP mixins).
- Call `setNoWrap()` to force `flex-wrap: nowrap` for marquee/toolbars.
- Responsive/grid utility classes (e.g., `wa-grid-*`) belong on the cluster; they do not attach to `WaStack` and do not create implicit columns.
- Keep CRTP chaining (`(J) this`) when extending; avoid builders.

Patterns
- Use clusters for horizontal stacks (rows); for vertical columns use `WaStack` inside the cluster as needed per instance (no automatic nesting).
- Avoid inline styles beyond gap/alignment; prefer CSS variables or utility classes defined by WebAwesome themes.
- When prompting, refer to layout rows as “WaCluster” to maintain language alignment.

See also
- Column layout — ./stack.rules.md
- Buttons and inputs — ./button.rules.md, ./input.rules.md#number-input
- Base layout guidance — ../../webawesome/page.rules.md
- Glossary — ./GLOSSARY.md
