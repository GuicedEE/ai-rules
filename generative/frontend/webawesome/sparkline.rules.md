# Sparkline Component Rules

📌 Enterprise-format rule file for WebAwesome `<wa-sparkline>`. See the index at ./README.md.

## Overview

`<wa-sparkline>` renders compact, inline data trends. Choose an appearance (solid, line, gradient), optionally indicate a trend, and select a curve.

---

## Inputs

- `label`: `string` — accessible label for screen readers
- `data`: `string` — space-separated numbers, e.g. `"10 20 40 25 35"`
- `appearance`: `'gradient' | 'line' | 'solid'` (default: `solid`)
- `trend`: `'positive' | 'negative' | 'neutral'`
- `curve`: `'linear' | 'natural' | 'step'` (default: `linear`)

## CSS Custom Properties

- `--fill-color` — fill under the line
- `--line-color` — stroke color
- `--line-width` — stroke width

## CSS Parts

- `base`, `line`, `fill`

## Angular Usage

```html
<!-- Solid appearance with explicit colors -->
<wa-sparkline
  label="Sessions"
  data="5 8 6 12 10 14 9"
  appearance="solid"
  style="--fill-color: rgba(0, 102, 255, .2); --line-color: #0066ff; --line-width: 2px;">
</wa-sparkline>

<!-- Line appearance with natural curve and trend -->
<wa-sparkline
  label="Revenue"
  data="10 20 40 25 35 45"
  appearance="line"
  curve="natural"
  trend="positive">
</wa-sparkline>
```

## Notes

- Ensure `label` communicates context for assistive technologies.
- Provide the `data` series as a space-separated string; sanitize/format upstream if building dynamically.
