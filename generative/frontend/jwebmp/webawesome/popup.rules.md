# WaPopup — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-popup` overlays with arrow/strategy controls. Aligns with ../../webawesome/popup.rules.md.

Usage
- Use `WaPopup` around trigger/content; configure placement (`WaPopupPlacements`), strategy (`WaPopupStrategy`/`WaPopupFallbackStrategy`), arrow visibility, auto-size (`WaPopupAutoSize`), and sync (`WaPopupSync`) via fluent setters.
- Place within clusters/stacks; layout utilities on the parent do not affect popup positioning.

Patterns
- Keep CRTP chaining; avoid inline HTML; ensure focus/escape handling matches base behavior.
- Test cross-browser positioning; include BrowserStack when altering placement defaults.
