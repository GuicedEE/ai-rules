# WaFlank — WebAwesome (JWebMP Wrapper)

Layout helper for flank sections using `wa-flank` utility classes (start/end). No base component file in WebAwesome rules.

Usage
- Add `WaFlank` to clusters/stacks to flank content; default adds `wa-flank`, constructor overload adds `wa-flank:start` or `wa-flank:end`.
- Use `setDisplayAsLink()` to render as an anchor when a flank acts as navigation.
- Combine with gap/align helpers from implemented interfaces.

Patterns
- Keep CRTP chaining; avoid inline HTML.
- Apply grid utilities on the surrounding cluster if needed; stacks remain unaffected.
