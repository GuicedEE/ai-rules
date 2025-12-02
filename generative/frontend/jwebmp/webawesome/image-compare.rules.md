# WaImageCompare — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-image-compare` (comparison slider). Behaves like WaComparison; use whichever naming aligns with prompts. Mirrors ../../webawesome/comparison.rules.md.

Usage
- Place in clusters/stacks; supply before/after slots with images/components; configure handle/labels via fluent setters.
- Keep CRTP chaining; avoid inline HTML.

Patterns
- Ensure alt text on images and keyboard operability for the handle.
- Use either this or WaComparison consistently within a project to avoid duplicate abstractions.
