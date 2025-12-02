# WaCopyButton — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-copy-button` to copy text/content to clipboard. Aligns with ../../webawesome/copy-button.rules.md.

Usage
- Instantiate and place in clusters/stacks; configure copy target/value, feedback text, and disabled/loading states via fluent setters.
- Provide accessible labels/tooltips per base rules; avoid inline script blocks.

Patterns
- Keep CRTP chaining; no builders.
- When copying dynamic values, ensure value is present during SSR to avoid empty clipboard entries.
