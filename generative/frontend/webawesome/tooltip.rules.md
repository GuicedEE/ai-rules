## Tooltip Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component: `<wa-tooltip>`

Tooltips display contextual information when hovering, focusing, clicking, or programmatically toggling visibility on a target element. The tooltip is bound via the `for` attribute to the `id` of another element.

---

### Angular Directive Selector

`waTooltip`

---

### Inputs

| Input       | Type      | Description                                                                                                       |           |         |               |             |          |                |              |        |              |              |                                     |
| ----------- | --------- | ----------------------------------------------------------------------------------------------------------------- | --------- | ------- | ------------- | ----------- | -------- | -------------- | ------------ | ------ | ------------ | ------------ | ----------------------------------- |
| `for`       | `string`  | The `id` of the target element this tooltip is attached to. Required.                                             |           |         |               |             |          |                |              |        |              |              |                                     |
| `placement` | \`'top'   | 'top-start'                                                                                                       | 'top-end' | 'right' | 'right-start' | 'right-end' | 'bottom' | 'bottom-start' | 'bottom-end' | 'left' | 'left-start' | 'left-end'\` | Preferred placement of the tooltip. |
| `disabled`  | `boolean` | If `true`, disables tooltip display.                                                                              |           |         |               |             |          |                |              |        |              |              |                                     |
| `distance`  | `number`  | Distance in pixels to offset the tooltip. Default is `8`.                                                         |           |         |               |             |          |                |              |        |              |              |                                     |
| `skidding`  | `number`  | Skidding offset in pixels along the target. Default is `0`.                                                       |           |         |               |             |          |                |              |        |              |              |                                     |
| `open`      | `boolean` | Programmatically control tooltip visibility. Must be used with `trigger='manual'`.                                |           |         |               |             |          |                |              |        |              |              |                                     |
| `showDelay` | `number`  | Delay before showing (ms). Default `150`.                                                                         |           |         |               |             |          |                |              |        |              |              |                                     |
| `hideDelay` | `number`  | Delay before hiding (ms). Default `0`.                                                                            |           |         |               |             |          |                |              |        |              |              |                                     |
| `trigger`   | `string`  | Trigger method: `click`, `hover`, `focus`, `manual`, or space-separated combinations. Default is `'hover focus'`. |           |         |               |             |          |                |              |        |              |              |                                     |

---

### Outputs

| Output        | Description                                |
| ------------- | ------------------------------------------ |
| `waShow`      | Emitted when the tooltip starts showing.   |
| `waAfterShow` | Emitted after the tooltip is fully shown.  |
| `waHide`      | Emitted when the tooltip starts hiding.    |
| `waAfterHide` | Emitted after the tooltip is fully hidden. |

---

### Styling Inputs (CSS Custom Properties)

Set directly on the host element:

```ts
@Input() backgroundColor: string; // maps to --background-color
@Input() borderRadius: string;    // maps to --border-radius
@Input() maxWidth: string;        // maps to --max-width
@Input() padding: string;         // maps to --padding
@Input() arrowSize: string;       // maps to --wa-tooltip-arrow-size
```

These values are bound to the host element via `style.setProperty('--property-name', value)`.

---

### Manual Control Example

When using `trigger='manual'`, toggle the `open` input programmatically to show or hide:

```ts
@ViewChild('tooltip') tooltip: ElementRef;

showTooltip() {
  this.tooltip.nativeElement.open = true;
}

hideTooltip() {
  this.tooltip.nativeElement.open = false;
}
```

---

### Notes

* The `for` input must match the `id` of the element receiving the tooltip.
* Avoid putting interactive content (e.g., buttons) inside tooltips.
* This component automatically imports `<wa-popup>`.

---

### Spec + Index + Example files

Ensure the Angular generator also creates:

* `wa-tooltip.directive.ts`
* `wa-tooltip.directive.spec.ts`
* `index.ts` export barrel
* `README.md` referencing this `rules.md`
* `examples.md` with placement, trigger, arrow size, and HTML content samples.
