# WaFrame — WebAwesome (JWebMP Wrapper)

Layout helper for aspect-ratio frames using `wa-frame`. No base component file in WebAwesome rules.

Usage
- Add `WaFrame` to clusters/stacks to maintain aspect ratios for media; set `setAspectRatio("16 / 9")` or similar.
- Use gap/vertical alignment via inherited helpers; avoid treating as grid.

Patterns
- Keep CRTP chaining; avoid builders.
- Place media/content as children components; do not inline HTML strings.
