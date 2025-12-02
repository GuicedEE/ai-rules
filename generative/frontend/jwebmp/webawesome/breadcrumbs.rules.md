# WaBreadcrumbs — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-breadcrumbs` and `wa-breadcrumb-item` navigation. Mirrors ../../webawesome/breadcrumbs.rules.md and breadcrumb-item rules.

Usage
- Compose `WaBreadcrumbs` with `WaBreadcrumbItem` children; set separators via `BreadcrumbSeparator` when customizing.
- Add to clusters/stacks as needed; no implicit column/grid.
- Provide href/label for each item; mark current page appropriately.

Patterns
- Keep CRTP setters; avoid inline anchor HTML.
- Ensure accessible nav semantics (aria-current) per base WebAwesome guidance.
