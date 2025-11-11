# Button Group

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

📎 This component wraps [`<wa-button>`](./button.rules.md), and those buttons inherit size and variant unless overridden.

`<wa-button-group>` is a container component for grouping related `<wa-button>` elements. It supports shared attributes (like `size`, `variant`, `orientation`) and works with slots and accessibility features.

## Angular Usage

Use the `waButtonGroup` directive to enhance an HTML element wrapping Web Awesome button groups:

```html
<div waButtonGroup label="Alignment">
  <wa-button>Left</wa-button>
  <wa-button>Center</wa-button>
  <wa-button>Right</wa-button>
</div>
```

## Inputs

| Input         | Type           | Description                                                     |                        |                                                   |            |                                                   |
| ------------- | -------------- | --------------------------------------------------------------- | ---------------------- | ------------------------------------------------- | ---------- | ------------------------------------------------- |
| `label`       | `string`       | Required for accessibility. Describes the purpose of the group. |                        |                                                   |            |                                                   |
| `size`        | \`'small'      | 'medium'                                                        | 'large'\`              | Inherited by contained buttons unless overridden. |            |                                                   |
| `variant`     | \`'neutral'    | 'brand'                                                         | 'success'              | 'warning'                                         | 'danger'\` | Inherited by contained buttons unless overridden. |
| `orientation` | \`'horizontal' | 'vertical'\`                                                    | Default is horizontal. |                                                   |            |                                                   |

All inputs should support string values even when bound dynamically (e.g., `[size]="'small'"` or `size="small"`).

## Projected Content

Use the default slot for projecting `<wa-button>` elements or any component with compatible button behavior:

* [`<wa-button>`](./button.rules.md)
* Native `<button>` (with styling)
* `<wa-dropdown>` with button triggers

## Accessibility

* `label` is strongly recommended as it enables screen readers to describe the group context.
* Use `aria-label` on the host element if `label` is unavailable.

## Examples

### Basic Horizontal Group

```html
<wa-button-group label="Alignment">
  <wa-button>Left</wa-button>
  <wa-button>Center</wa-button>
  <wa-button>Right</wa-button>
</wa-button-group>
```

### Vertical Group

```html
<wa-button-group orientation="vertical" label="Options">
  <wa-button>New</wa-button>
  <wa-button>Open</wa-button>
  <wa-button>Save</wa-button>
</wa-button-group>
```

### Size Inheritance

```html
<wa-button-group size="small" label="Small Group">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>
```

### Variant Inheritance

```html
<wa-button-group variant="brand" label="Action Group">
  <wa-button>Yes</wa-button>
  <wa-button>No</wa-button>
</wa-button-group>
```

## Notes

* Do not mix button sizes or variants within a single group unless intentional.
* Buttons within a group can override inherited size/variant.
* The `pill` attribute must be applied on individual buttons.
* You can wrap buttons in `<wa-tooltip>` for additional hints.
* Use Angular wrappers for dropdowns and native buttons to ensure consistent styles.

## Styling and Layout

Use the `::ng-deep` selector if styling slotted content from Angular context is needed. For layout spacing, apply styles to the host element or project via a wrapper element:

```css
::ng-deep wa-button-group:not(:last-child) {
  margin-right: var(--wa-space-xs);
}
```

## Slot Support

| Slot        | Description                           |
| ----------- | ------------------------------------- |
| `(default)` | Buttons and controls inside the group |

## CSS Parts

| Part   | Description              |
| ------ | ------------------------ |
| `base` | The wrapper of the group |

## Summary

Use `<wa-button-group>` for logically grouping buttons with shared size, variant, and orientation. Ensure accessibility with the `label` attribute. Avoid mixing styles within a group unless explicitly required.
