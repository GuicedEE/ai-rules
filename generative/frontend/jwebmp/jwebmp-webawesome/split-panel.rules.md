## Angular Wrapper: Split Panel (`wa-split-panel`)

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Selector

```ts
waSplitPanel
```

### Description

Wraps the `<wa-split-panel>` Web Awesome component, which displays two adjacent panels (start/end) separated by a resizable divider. This wrapper provides Angular binding for panel configuration but no form-binding is required.

### Inputs

| Input              | Type               | Description                                                                    |
| ------------------ | ------------------ | ------------------------------------------------------------------------------ |
| `position`         | `number`           | Percentage (0–100) of initial divider position. Reflects `position` attribute. |
| `positionInPixels` | `number`           | Initial divider position in pixels. Reflects `position-in-pixels` attribute.   |
| `vertical`         | `boolean`          | Whether the split orientation is vertical.                                     |
| `disabled`         | `boolean`          | Prevents resizing the divider.                                                 |
| `primary`          | `'start' \| 'end'` | Designates the primary panel that maintains size during host resize.           |
| `snap`             | `string`           | Space-separated values (in px or %) to which the divider can snap.             |
| `snapThreshold`    | `number`           | Proximity threshold in pixels to trigger snapping. Default is 12.              |

### Outputs

| Output            | Description                                                      |
| ----------------- | ---------------------------------------------------------------- |
| `repositionEvent` | Emits when the divider is repositioned. Maps to `wa-reposition`. |

### Slots

* `start`: Content of the start panel.
* `end`: Content of the end panel.
* `divider`: Slot for a custom divider icon or handle.

### CSS Custom Properties (as Inputs)

Use Angular-style inputs to control style via CSS custom properties directly on the host element:

```ts
@Input() dividerColor?: string; // -> --divider-color
@Input() dividerWidth?: string; // -> --divider-width
@Input() dividerHitArea?: string; // -> --divider-hit-area
@Input() min?: string; // -> --min
@Input() max?: string; // -> --max
```

These are written to the host element as style properties.

### Notes

* Use `ng-content select="[slot=start]"`, `select="[slot=end]"`, and `select="[slot=divider]"` for projected content.
* This component does **not** use `ngModel`.
* Use the Angular host binding to apply style variables.

### Example Usage

```html
<wa-split-panel
  [position]="60"
  vertical
  snap="25% 75%"
  [primary]="'start'"
  [dividerColor]="'var(--wa-color-red-50)'"
  (repositionEvent)="onReposition($event)">

  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
  <wa-icon slot="divider" name="grip-vertical"></wa-icon>

</wa-split-panel>
```
