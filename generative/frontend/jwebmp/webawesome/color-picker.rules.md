# WaColorPicker — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-color-picker` supporting color selection and swatches. Aligns with ../../webawesome/color-picker.rules.md.

Usage
- Add `WaColorPicker` to clusters/stacks; configure value/default, format (hex/rgb/hsl), swatches, and disabled/read-only states via fluent setters.
- Bind to Angular models with `bind()` if needed; expose labels/hints for accessibility.

Patterns
- Keep CRTP setters; avoid inline script/style for palette definitions—use component APIs or theme CSS variables.
- Respect contrast/accessibility guidance from base WebAwesome rules.
