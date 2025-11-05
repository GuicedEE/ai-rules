## Progress Bar

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Selector

```ts
waProgressBar
```

### Description

The `waProgressBar` Angular wrapper enables binding and interaction with the `<wa-progress-bar>` Web Component, used to visualize the progression of a task.

---

### Inputs

| Input           | Type      | Description                                                          |
| --------------- | --------- | -------------------------------------------------------------------- |
| `value`         | `number`  | Current progress percentage, 0–100.                                  |
| `indeterminate` | `boolean` | If true, shows indeterminate loading. Value and content are ignored. |
| `label`         | `string`  | Label for screen readers.                                            |

---

### Outputs

| Output       | Description                           |
| ------------ | ------------------------------------- |
| `focusEvent` | Emits when the component gains focus. |
| `blurEvent`  | Emits when the component loses focus. |

---

### Two-way Binding

| Input   | Binding Name  |
| ------- | ------------- |
| `value` | `[(ngModel)]` |

Use `ngModel` to bind to the `value` property.

---

### Styling Inputs (CSS Custom Properties)

Supports the following style inputs mapped from CSS custom properties:

| Input name       | Maps to CSS custom property |
| ---------------- | --------------------------- |
| `indicatorColor` | `--indicator-color`         |
| `display`        | `--display`                 |

---

### Slots

| Slot Name | Description                                                                       |
| --------- | --------------------------------------------------------------------------------- |
| (default) | The default slot can be used to show the current value as text (e.g., `50%`).     |
| `prefix`  | For an optional icon or element before the bar (e.g., `<wa-icon slot="prefix">`). |

---

### Example Usage

```html
<wa-progress-bar
  [(ngModel)]="progressValue"
  label="Upload Progress"
  [indicatorColor]="'green'"
  [display]="'block'">
  {{ progressValue }}%
</wa-progress-bar>
```

---

### Notes

* Do **not** use reactive forms or signals—this component must bind using `ngModel`.
* You can toggle between indeterminate and standard modes using the `indeterminate` boolean.
* For dynamic content updates, use direct DOM manipulation or template interpolation.

---

### Accessibility

Ensure that the `label` input is set for screen reader support, especially when using the indeterminate state.
