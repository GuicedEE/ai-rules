# WaZoomableFrame — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-zoomable-frame`. Aligns with ../../webawesome/zoomable-frame.rules.md.

Usage
- Wrap content that needs pan/zoom (e.g., images, diagrams); configure min/max zoom, initial scale, and panning options via fluent setters.
- Place in clusters/stacks; grid utilities on parents do not affect zoom behavior.

Patterns
- Keep CRTP chaining; avoid inline HTML.
- Provide keyboard controls or alternative views for accessibility when zooming.
