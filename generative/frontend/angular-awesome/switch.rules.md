## Angular Directive: Switch

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Selector

`waSwitch`

### Purpose

Wraps the `<wa-switch>` Web Component to expose Angular-style inputs/outputs and integrate with `ngModel` for form compatibility.

### Usage

```html
<wa-switch waSwitch [(ngModel)]="checked" [disabled]="isDisabled" hint="Toggle feature" size="medium">
  Enable Feature
</wa-switch>
```

### Inputs

| Input      | Type      | Description                                                |         |             |                                        |
| ---------- | --------- | ---------------------------------------------------------- | ------- | ----------- | -------------------------------------- |
| `ngModel`  | `boolean` | Whether the switch is checked. Maps to the `checked` attr. |         |             |                                        |
| `disabled` | `boolean` | Disables the switch. Maps to `disabled`.                   |         |             |                                        |
| `hint`     | `string`  | Hint text. Maps to `hint` attribute.                       |         |             |                                        |
| `size`     | \`'small' | 'medium'                                                   | 'large' | 'inherit'\` | Switch size. Maps to `size` attribute. |

### Outputs

| Output        | Description                                          |
| ------------- | ---------------------------------------------------- |
| `changeEvent` | Emits when the checked state changes. Maps `change`. |
| `inputEvent`  | Emits when the switch receives input. Maps `input`.  |
| `focusEvent`  | Emits when the control gains focus. Maps `focus`.    |
| `blurEvent`   | Emits when the control loses focus. Maps `blur`.     |

### Styling Inputs (mapped to CSS Custom Properties)

| Input Name               | CSS Variable                 |
| ------------------------ | ---------------------------- |
| `backgroundColor`        | `--background-color`         |
| `backgroundColorChecked` | `--background-color-checked` |
| `borderColor`            | `--border-color`             |
| `borderColorChecked`     | `--border-color-checked`     |
| `borderStyle`            | `--border-style`             |
| `borderWidth`            | `--border-width`             |
| `boxShadow`              | `--box-shadow`               |
| `height`                 | `--height`                   |
| `thumbColor`             | `--thumb-color`              |
| `thumbColorChecked`      | `--thumb-color-checked`      |
| `thumbShadow`            | `--thumb-shadow`             |
| `thumbSize`              | `--thumb-size`               |
| `width`                  | `--width`                    |

Each of these should be applied via style bindings directly on the host element.

### Form Compatibility

This directive supports `ngModel` two-way binding. The `ngModel` value controls the `checked` state of the switch, and updates when toggled.

### Notes

* Use the default slot to provide the label.
* For SSR, when using the `hint` slot, include the `with-hint` attribute manually.

### Example

```html
<form #form="ngForm">
  <wa-switch
    waSwitch
    name="newsletter"
    [(ngModel)]="model.newsletter"
    hint="Receive monthly updates"
    size="large"
    [disabled]="!model.userAcceptedTerms"
    style="--thumb-size: 36px; --background-color-checked: limegreen"
  >
    Subscribe
  </wa-switch>
</form>
```
