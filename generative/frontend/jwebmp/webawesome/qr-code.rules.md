# WaQRCode — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-qr-code`. Mirrors ../../webawesome/qr-code.rules.md.

Usage
- Add to clusters/stacks; set value, error correction level, size, and label via fluent setters.
- Use for static codes; regenerate value for dynamic content instead of mutating DOM manually.

Patterns
- Keep CRTP chaining; ensure sufficient contrast and include alt/label text.
