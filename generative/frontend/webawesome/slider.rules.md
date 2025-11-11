# Slider Component Rules for Angular Wrapper

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

## Component Overview

`<wa-slider>` is a range input component that supports labeling, hints, min/max values, tooltips, and custom styling.

## Angular Wrapper Requirements

### Selector

`waSlider`

### Module Declaration

```ts
import { WaSliderDirective } from './wa-slider.directive';
```

### Inputs

| Input Name  | Type       | Description                                   |          |                   |
| ----------- | ---------- | --------------------------------------------- | -------- | ----------------- |
| `min`       | `number`   | Minimum value allowed                         |          |                   |
| `max`       | `number`   | Maximum value allowed                         |          |                   |
| `step`      | `number`   | Step size                                     |          |                   |
| `disabled`  | `boolean`  | Whether the slider is disabled                |          |                   |
| `tooltip`   | \`'top' \\ | 'bottom' \\                                   | 'none'\` | Tooltip placement |
| `label`     | `string`   | Label text (or use label slot)                |          |                   |
| `hint`      | `string`   | Hint text (or use hint slot)                  |          |                   |
| `name`      | `string`   | Form name                                     |          |                   |
| `form`      | `string`   | Form association (by id)                      |          |                   |
| `withLabel` | `boolean`  | SSR optimization for label slot               |          |                   |
| `withHint`  | `boolean`  | SSR optimization for hint slot                |          |                   |
| `style.*`   | `string`   | Set custom properties as Angular-style inputs |          |                   |

Use camelCase Angular inputs to bind CSS custom properties:

* `trackColorActive` → `--track-color-active`
* `trackColorInactive` → `--track-color-inactive`
* `trackHeight` → `--track-height`
* `trackActiveOffset` → `--track-active-offset`
* `thumbColor`, `thumbGap`, `thumbShadow`, `thumbSize`, `tooltipOffset`

### Outputs

| Output Name    | Description                       |
| -------------- | --------------------------------- |
| `blurEvent`    | Emits when the slider loses focus |
| `focusEvent`   | Emits when the slider gains focus |
| `changeEvent`  | Emits when the value is committed |
| `inputEvent`   | Emits on value change (real-time) |
| `invalidEvent` | Emits when validity check fails   |

### Forms Compatibility

✅ Supports `ngModel`

```html
<wa-slider [(ngModel)]="value" [min]="0" [max]="100" label="Volume"></wa-slider>
```

🔁 Reactive forms **not supported**.

### Slots

You may optionally use the `label` and `hint` slots if HTML content is needed instead of plain strings.

### Methods

Methods like `stepUp()`, `stepDown()`, `focus()`, and `blur()` are accessible via `@ViewChild()` in Angular if needed.

### Styling

Use Angular-style inputs that directly map to CSS custom properties on the host element:

```ts
@Input() trackColorActive?: string; // maps to --track-color-active
@Input() trackHeight?: string;      // maps to --track-height
```

### Example Usage

```html
<wa-slider
  [(ngModel)]="volume"
  [min]="0"
  [max]="100"
  [step]="5"
  tooltip="bottom"
  label="Volume"
  hint="Controls the volume of the current song."
  [trackColorActive]="'var(--wa-color-brand-fill-loud)'"
  [trackColorInactive]="'var(--wa-color-brand-fill-normal)'"
></wa-slider>
```

---

Refer to the base [Web Awesome Angular Rules](../../../RULES.md) for shared conventions and binding behaviors.
