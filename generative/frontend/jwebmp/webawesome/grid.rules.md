# WaGrid — WebAwesome (JWebMP Wrapper)

Layout helper adding `wa-grid` utilities. No base component file in WebAwesome rules; use this for responsive grids built from utility classes.

Usage
- Add `WaGrid` inside clusters/stacks to create responsive grids; configure gap/split via inherited `GapCapable`/`SplitCapable` setters.
- Use `setMinColumnSize("15rem")` to control `--min-column-size` custom property for auto-wrapping columns.
- Call `spanFullRow()` on children that should span the grid; grid utilities belong on the cluster parent as needed.

Patterns
- Avoid treating `WaStack` as a grid; keep grid semantics on `WaGrid` or clusters per layout guidance.
- Keep CRTP chaining; avoid inline HTML.
