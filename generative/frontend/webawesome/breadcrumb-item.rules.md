# Breadcrumb Item Rules

This file defines usage rules for the WebAwesome breadcrumb item component.

## Overview
- Tag: `<wa-breadcrumb-item>`
- Purpose: Represents a single item within a breadcrumb trail. Supports links and current page indication.
- Typical usage: placed inside `<wa-breadcrumb>`.

## Attributes / Properties
- `href: string` — When set, renders the item as a link.
- `target: string` — Target for links (e.g., `_blank`).
- `rel: string` — Rel attribute for links.
- `disabled: boolean` — Marks the item as non-interactive.
- `ariaCurrent: 'page' | 'step' | 'location' | 'date' | 'time' | 'true' | 'false'` — Indicates the current item in the set; usually `page`.

## Slots
- default — The label/content of the breadcrumb item.
- `prefix` — Optional leading icon or content.
- `suffix` — Optional trailing icon or content.

## Events
- `(blur)` — Bubbles from internal focusable (rename to `blurEvent` if integrating into frameworks that conflict with native events).
- `(focus)` — Bubbles from internal focusable (rename to `focusEvent` in wrappers).

## Accessibility
- Set `aria-current="page"` (or the appropriate token) on the current crumb.
- Ensure link text is descriptive and unique for screen readers.

## CSS Parts
- `base` — Host container.
- `label` — Text/label container.
- `prefix` — Prefix slot wrapper.
- `suffix` — Suffix slot wrapper.

## Examples
```html
<wa-breadcrumb>
  <wa-breadcrumb-item href="/">Home</wa-breadcrumb-item>
  <wa-breadcrumb-item href="/products">Products</wa-breadcrumb-item>
  <wa-breadcrumb-item aria-current="page">Widgets</wa-breadcrumb-item>
</wa-breadcrumb>
```

## Notes
- Pair with `./breadcrumbs.rules.md` for the parent container.
- For React 3.0.0: use `WaBreadcrumbItem` from the React wrappers.