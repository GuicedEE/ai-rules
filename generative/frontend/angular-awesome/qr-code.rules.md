## QR Code Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component Selector

`wa-qr-code`

### Angular Wrapper Selector

`waQrCode`

### Description

Renders a QR code using the Canvas API based on the input `value`. Typically used to provide users with scannable links or data. Supports customization of colors, size, radius, and error correction level.

### Inputs

| Input             | Type               | Description                                                         |     |       |                                        |
| ----------------- | ------------------ | ------------------------------------------------------------------- | --- | ----- | -------------------------------------- |
| `value`           | `string`           | The data encoded in the QR code. Required. Binds via `[(ngModel)]`. |     |       |                                        |
| `label`           | `string`           | Accessible label. Defaults to `value` if not specified.             |     |       |                                        |
| `size`            | `number`           | Size of the rendered QR code in pixels. Default is `128`.           |     |       |                                        |
| `fill`            | `string`           | Foreground color. Any valid CSS color.                              |     |       |                                        |
| `background`      | `string`           | Background color. Any valid CSS color.                              |     |       |                                        |
| `radius`          | `number (0 - 0.5)` | Rounding for each module. Default `0`.                              |     |       |                                        |
| `errorCorrection` | \`'L'              | 'M'                                                                 | 'Q' | 'H'\` | Error correction level. Default `'H'`. |

### Styling Inputs

Supports these Angular-style inputs for styling, applied to the host:

* `--size`
* `--fill`
* `--background`
* `--radius`
* `--color`
* `--display`

> ⚠️ `fill` and `background` must be concrete values, not CSS custom properties.

### Outputs

| Output Event | Payload Type | Description                                 |
| ------------ | ------------ | ------------------------------------------- |
| `focusEvent` | `FocusEvent` | Fired when the QR code element is focused.  |
| `blurEvent`  | `FocusEvent` | Fired when the QR code element loses focus. |

### Accessibility

If `label` is not set, the `value` will be used as the accessible label.

### Forms Support

This component binds `value` via `[(ngModel)]` and integrates with Angular forms. Do **not** use reactive forms or `FormControl`.

### Example Usage

```html
<wa-qr-code [(ngModel)]="websiteUrl" label="Scan to visit"></wa-qr-code>
<wa-input [(ngModel)]="websiteUrl" label="Website URL"></wa-input>
```

### Slots

| Slot Name | Description                               |
| --------- | ----------------------------------------- |
| `prefix`  | Shown inside the code, typically an icon. |

### CSS Parts

| Part   | Description                   |
| ------ | ----------------------------- |
| `base` | The component's base wrapper. |

### Notes

* Ensure there is sufficient contrast between `fill` and `background`.
* The size and radius affect visual clarity; test across devices.
* The component redraws on `value` change.

---

Component reference: `<wa-qr-code>`
