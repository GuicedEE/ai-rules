📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

# `wa-color-picker` Angular Integration Rules

## Component Selector

`<wa-color-picker>` → `waColorPicker`

## Inputs

| Name             | Type                                          | Binding Required | Notes                                                                                     |
| ---------------- | --------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------- |
| `label`          | `string`                                      | No               | Always set for accessibility. Supports `slot` alternative.                                |
| `hint`           | `string`                                      | No               | Descriptive hint; use `slot="hint"` for HTML hints.                                       |
| `value`          | `string \| null`                              | Yes              | Format depends on `format`/`opacity`. Binds via `ngModel`; do not use custom `[(value)]`. |
| `format`         | `'hex' \| 'rgb' \| 'hsl' \| 'hsv'`            | No               | Affects the internal format and toggle behavior.                                          |
| `noFormatToggle` | `boolean`                                     | Yes              | Disables user toggle; bind explicitly.                                                    |
| `opacity`        | `boolean`                                     | Yes              | Enables alpha slider.                                                                     |
| `uppercase`      | `boolean`                                     | Yes              | Outputs uppercase color strings.                                                          |
| `size`           | `'small' \| 'medium' \| 'large' \| 'inherit'` | No               | Trigger button sizing.                                                                    |
| `disabled`       | `boolean`                                     | Yes              | Disables picker.                                                                          |
| `required`       | `boolean`                                     | Yes              | Marks input as required.                                                                  |
| `name`           | `string \| null`                              | No               | Used in form submissions.                                                                 |
| `form`           | `string \| null`                              | No               | Link to external form by ID.                                                              |
| `swatches`       | `string \| string[]`                          | Yes if dynamic   | Semicolon-separated string or JS array of color values.                                   |

## Outputs

| Event       | Description                                                   |
| ----------- | ------------------------------------------------------------- |
| `change`    | Fires when the value changes. Required for `ngModel` binding. |
| `input`     | Fires on every user input.                                    |
| `focus`     | Fires when input gains focus.                                 |
| `blur`      | Fires when input loses focus.                                 |
| `waInvalid` | Fires on failed validity check.                               |

## Two-Way Binding (Template-Driven)

Use `[(ngModel)]` for binding form values in Angular template-driven forms. Do not use custom `[(value)]` syntax.

```html
<wa-color-picker [(ngModel)]="selectedColor" name="color" label="Pick a color"></wa-color-picker>
```

The `name` attribute is required for `ngModel` in forms.

## Methods

| Method                      | Description                      |
| --------------------------- | -------------------------------- |
| `focus()`                   | Programmatically focuses picker. |
| `blur()`                    | Removes focus from picker.       |
| `getFormattedValue(format)` | Returns formatted color string.  |
| `reportValidity()`          | Triggers form validation UI.     |
| `getHexString(h,s,v,a)`     | Converts HSV to hex string.      |

## Slot Support

| Slot    | Purpose                 |
| ------- | ----------------------- |
| `label` | Alternate label markup. |
| `hint`  | Alternate hint markup.  |

## Styling

Expose design tokens and custom part styling via Angular host bindings or encapsulation where needed.

## Child Dependencies

Declare and import Angular wrappers for the following Web Awesome components:

* [`wa-button`](./button.rules.md)
* [`wa-button-group`](./buttongroup.rules.md)
* [`wa-dropdown`](./dropdown.rules.md)
* [`wa-icon`](./icon.rules.md)
* [`wa-input`](./input.rules.md)
* [`wa-popup`](./popup.rules.md)
* [`wa-spinner`](./spinner.rules.md)
* wa-visually-hidden

Ensure these are registered or available in your module if not using autoloader.

## Form Integration

Supports **template-driven forms only** using `ngModel`. Reactive forms are not supported. Ensure `name` is set when using `ngModel`.

## Notes

* Always use property binding for boolean and array-based inputs (e.g. `[opacity]="true"`, `[swatches]="swatchArray"`).
* Use `@ViewChild()` to access public methods like `getFormattedValue()`.
* Internally handles a native `<input>` for form submission.
* Enforce consistent format output if format toggle is disabled.
* Use `[(ngModel)]` only — avoid custom binding aliases like `[(value)]`.
