# WaCallout — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-callout` to highlight information blocks. Behaviors align with ../../webawesome/callout.rules.md.

Usage
- Instantiate `WaCallout` and place in clusters/stacks; configure variant/appearance/size, title/description slots, and optional icon content via fluent setters.
- Use for inline alerts, tips, or contextual notices; avoid nesting other callouts inside.

Patterns
- Keep CRTP chaining; avoid builders.
- Favor semantic headings inside the callout for accessibility.
