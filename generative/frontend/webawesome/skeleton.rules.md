# Skeleton Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

The Angular wrapper for `<wa-skeleton>` is a structural directive used to scaffold content placeholders with optional animation effects. It does **not** use `ngModel` or emit output events.

---

## Selector

```ts
@Directive({
  selector: '[waSkeleton]'
})
```

## Usage

The directive is applied as an attribute to a placeholder element:

```html
<div waSkeleton effect="sheen"></div>
```

## Inputs

| Input     | Type                           | Description                                                 |
| --------- | ------------------------------ | ----------------------------------------------------------- |
| `effect`  | `'none' \| 'sheen' \| 'pulse'` | Animation effect. Defaults to `'none'`.                     |
| `style.*` | `string`                       | Angular-style inputs for CSS custom properties (see below). |

### Supported CSS Custom Properties (Angular Inputs)

| Input name     | Maps to CSS variable |
| -------------- | -------------------- |
| `borderRadius` | `--border-radius`    |
| `color`        | `--color`            |
| `sheenColor`   | `--sheen-color`      |

Each of these is set directly on the host element using Angular binding:

```html
<div
  waSkeleton
  effect="sheen"
  [borderRadius]="'var(--wa-border-radius-circle)'"
  [color]="'tomato'"
  [sheenColor]="'#ffb094'"
></div>
```

## Notes

* `<wa-skeleton>` does not emit events and is not bindable via `ngModel`.
* This directive may be used on native elements or Web Awesome `<wa-skeleton>` tags interchangeably.
* For advanced shape rendering, developers may use `::part(indicator)` in CSS, but this is outside the scope of this directive.

## Examples

```html
<!-- Basic Skeleton -->
<div waSkeleton></div>

<!-- Skeleton with Sheen Effect -->
<div waSkeleton effect="sheen"></div>

<!-- Styled Skeleton -->
<div
  waSkeleton
  effect="sheen"
  [borderRadius]="'50%'"
  [color]="'lightgray'"
  [sheenColor]="'rgba(255,255,255,0.3)'"
></div>
```
