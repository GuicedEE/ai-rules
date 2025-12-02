# WaAnimation — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-animation` utilities using `WaAnimation`, `Animation`, `FillMode`, and `PlaybackDirection`. Use this to apply keyframe animations to WebAwesome components via fluent setters; behavior mirrors ../../webawesome/animation.rules.md.

Usage
- Create `WaAnimation` and bind to target components via CRTP setters for name, duration, delay, iteration count, easing, direction, and fill mode.
- Compose with `WaCluster`/`WaStack` layouts; animation does not change layout semantics.
- Align with prefers-reduced-motion guidance; expose toggles in host UI where appropriate.

Patterns
- Avoid inline string style blobs; prefer named animations and CSS variables when extending themes.
- Keep CRTP chaining; avoid Lombok builders.
- Validate timing values (ms/s) to match WebAwesome expectations.
