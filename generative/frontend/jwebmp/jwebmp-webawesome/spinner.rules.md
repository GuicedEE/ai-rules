## Spinner Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Overview

This Angular wrapper corresponds to the `<wa-spinner>` Web Awesome component.
It is used to show the progress of an indeterminate operation.

### Selector

```ts
waSpinner
```

### Usage

```html
<wa-spinner></wa-spinner>
```

### Inputs

| Input Name       | Type   | Description                                              |
| ---------------- | ------ | -------------------------------------------------------- |
| `fontSize`       | string | Sets the `font-size` style directly on the host element. |
| `trackWidth`     | string | Sets `--track-width` CSS custom property.                |
| `trackColor`     | string | Sets `--track-color` CSS custom property.                |
| `indicatorColor` | string | Sets `--indicator-color` CSS custom property.            |
| `speed`          | string | Sets `--speed` CSS custom property.                      |

> ❗ All style-related inputs are applied via CSS custom properties directly to the host element.

### Outputs

None.

### CSS Custom Properties

These are mapped to Angular inputs above:

* `--track-width`
* `--track-color`
* `--indicator-color`
* `--speed`

### Example

```html
<wa-spinner
  [fontSize]="'3rem'"
  [trackWidth]="'10px'"
  [trackColor]="'pink'"
  [indicatorColor]="'deeppink'"
  [speed]="'1s'"
></wa-spinner>
```

### Notes

* This component does **not** support `ngModel`, as it is purely visual and stateless.
* It uses `font-size` as a sizing mechanism and does not define a fixed size.
* All styles should be modified through inputs that map to CSS custom properties.

---

This file was automatically generated according to the Web Awesome Angular component wrapper specification.
