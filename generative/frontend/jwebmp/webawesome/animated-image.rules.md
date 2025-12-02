# WaAnimatedImage — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-animated-image` providing play/pause controls and custom icons via `WaAnimatedImagePlayIconSlot` and `WaAnimatedImagePauseIconSlot`. CRTP setters mirror WebAwesome attributes; avoid builders and inline HTML.

Usage
- Instantiate `WaAnimatedImage` and add to `WaCluster`/`WaStack` directly (no implicit grid/columns).
- Configure sources, alt text, and playback via fluent setters; supply icon slot components when overriding default icons.
- Follow base behaviors and accessibility guidance in ../../webawesome/animated-image.rules.md.

Patterns
- Keep wrappers non-final with CRTP return types.
- Prefer asset paths compatible with `WebAwesomePageConfigurator` basePath; avoid hard-coded absolute URLs when theming is active.
- Reference base animation timing and prefers-reduced-motion expectations from the WebAwesome rules.
