# Select Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

## Component Selector

```ts
@Component({
  selector: 'wa-select-wrapper',
})
```

## Description

Wraps the `<wa-select>` Web Awesome component and provides Angular-style bindings, integration with `ngModel`, and typed outputs. Supports single and multiple selection modes. This wrapper also supports `<wa-option>` elements inside the content projection.

## Inputs

| Input Name          | Type                             | Description                                                          |
| ------------------- | -------------------------------- | -------------------------------------------------------------------- |
| `value`             | `string \| string[]`             | Bound via `ngModel`, corresponds to the `value` attribute.           |
| `label`             | `string`                         | Sets the label of the select.                                        |
| `hint`              | `string`                         | Provides additional guidance to the user.                            |
| `placeholder`       | `string`                         | Placeholder when no option is selected.                              |
| `appearance`        | `'outlined' \| 'filled'`         | Changes visual style.                                                |
| `pill`              | `boolean`                        | Applies pill-style rounded borders.                                  |
| `clearable`         | `boolean`                        | Shows a clear button when an option is selected.                     |
| `disabled`          | `boolean`                        | Disables the select control.                                         |
| `multiple`          | `boolean`                        | Enables multiple selection.                                          |
| `size`              | `'small' \| 'medium' \| 'large'` | Sets size variant.                                                   |
| `placement`         | `'top' \| 'bottom'`              | Preferred dropdown position.                                         |
| `required`          | `boolean`                        | Enables HTML form validation.                                        |
| `maxOptionsVisible` | `number`                         | Controls how many selected tags are visible when `multiple` is true. |
| `form`              | `string`                         | Form association when outside a `<form>`.                            |

### Style Inputs (CSS Custom Properties)

| Input Name               | Maps To CSS Custom Property  |
| ------------------------ | ---------------------------- |
| `backgroundColor`        | `--background-color`         |
| `borderColor`            | `--border-color`             |
| `borderWidth`            | `--border-width`             |
| `boxShadow`              | `--box-shadow`               |
| `backgroundColorCurrent` | `--background-color-current` |
| `backgroundColorHover`   | `--background-color-hover`   |
| `textColorCurrent`       | `--text-color-current`       |
| `textColorHover`         | `--text-color-hover`         |

## Outputs

| Output Name      | Description                                                 |
| ---------------- | ----------------------------------------------------------- |
| `inputEvent`     | Fires when the user selects an option (maps `input`).       |
| `changeEvent`    | Fires when the value changes (maps `change`).               |
| `focusEvent`     | Fires on focus (renamed from `focus`).                      |
| `blurEvent`      | Fires on blur (renamed from `blur`).                        |
| `clearEvent`     | Emitted when the clear button is clicked (maps `wa-clear`). |
| `showEvent`      | Emitted when the dropdown opens (maps `wa-show`).           |
| `afterShowEvent` | After the dropdown is fully opened (maps `wa-after-show`).  |
| `hideEvent`      | Emitted when the dropdown closes (maps `wa-hide`).          |
| `afterHideEvent` | After the dropdown is fully closed (maps `wa-after-hide`).  |
| `invalidEvent`   | When constraint validation fails (maps `wa-invalid`).       |

## Notes

* Always bind to `[(ngModel)]="model"` for both single and multiple selection.
* When using `multiple`, bind `[(ngModel)]` to a space-delimited `string`, or convert `string[]` to/from space-delimited form internally.
* This wrapper does **not** support Angular reactive forms or signal-based binding.

## Example

```html
<wa-select-wrapper
  [(ngModel)]="selectedOption"
  label="Select one"
  placeholder="Choose an option"
  clearable
  [disabled]="false"
  (changeEvent)="onChange($event)"
  style.backgroundColor="white"
  style.borderColor="gray"
>
  <wa-option value="option-1">Option 1</wa-option>
  <wa-option value="option-2">Option 2</wa-option>
  <wa-option value="option-3">Option 3</wa-option>
</wa-select-wrapper>
```

## Custom Tags for Multi-Select

The wrapper does **not** expose a way to provide a `getTag` callback yet. For advanced tagging scenarios, use native Web Awesome and connect to Angular manually.

## Option Support

* `<wa-option>` elements must be placed inside the wrapper content.
* Option-specific attributes like `value`, `label`, and `disabled` are supported natively.
* Option styling via the following mapped inputs is available:

| Input Name               | Maps To CSS Custom Property  |
| ------------------------ | ---------------------------- |
| `backgroundColorCurrent` | `--background-color-current` |
| `backgroundColorHover`   | `--background-color-hover`   |
| `textColorCurrent`       | `--text-color-current`       |
| `textColorHover`         | `--text-color-hover`         |
