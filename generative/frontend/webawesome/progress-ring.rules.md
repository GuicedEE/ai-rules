## Progress Ring Rules (Angular Wrapper)

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component Overview

Wraps the `<wa-progress-ring>` Web Awesome component. Used to display determinate progress in a circular form.

---

### Angular Selector

```ts
waProgressRing
```

---

### Inputs

#### Value Binding

* `[(ngModel)]`: Binds to the `value` attribute (from 0 to 100).

  ```html
  <wa-progress-ring [(ngModel)]="progress"></wa-progress-ring>
  ```

#### Accessibility

* `label: string` — sets the accessible label.

#### Style Inputs (mapped to CSS custom properties)

| Input Name                    | CSS Variable                      |
| ----------------------------- | --------------------------------- |
| `size`                        | `--size`                          |
| `trackWidth`                  | `--track-width`                   |
| `trackColor`                  | `--track-color`                   |
| `indicatorWidth`              | `--indicator-width`               |
| `indicatorColor`              | `--indicator-color`               |
| `indicatorTransitionDuration` | `--indicator-transition-duration` |

These accept string values (e.g. `"6px"`, `"deeppink"`, `"200ms"`).

---

### Outputs

#### Focus and Blur

Use distinct output names to avoid clashing with native methods:

* `(focusEvent)`: emitted on `focus`
* `(blurEvent)`: emitted on `blur`

---

### Slots

* `default` — Used to project a label or content into the center of the ring.
* `prefix` — (Optional) Icon or content before the label.

---

### Example

```html
<wa-progress-ring
  [(ngModel)]="value"
  label="Progress Ring Example"
  [size]="'150px'"
  [trackWidth]="'4px'"
  [indicatorWidth]="'8px'"
  [trackColor]="'#eee'"
  [indicatorColor]="'#2196f3'"
>
  {{ value }}%
</wa-progress-ring>
```

---

### Notes

* This directive is non-reactive and fully compatible with template-driven forms.
* Do **not** use signals or reactive primitives.
* Ensure all style values are strings; numeric values like `8` should be passed as `'8px'` when relevant.
