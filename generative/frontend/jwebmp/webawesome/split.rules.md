# WaSplit — WebAwesome (JWebMP Wrapper)

Layout helper for split layouts using `wa-split` utilities. No dedicated base component file.

Usage
- Add `WaSplit` within clusters/stacks to align two regions; default adds `wa-split` class.
- Call `row()` or `column()` to choose direction; use `alignItems("center")` and gap helpers for spacing/alignment.

Patterns
- Keep CRTP chaining; avoid inline HTML.
- Apply grid utilities on the surrounding cluster when needed; stacks remain unaffected.
