📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

# `wa-checkbox` Angular Integration Rules

## Component Selector

`<wa-checkbox>` → `waCheckbox`

## Inputs

| Name           | Type                                          | Binding Required | Notes                                                                                     |
| -------------- | --------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------- |
| `checked`      | `boolean \| string`                           | Yes              | Determines if the checkbox is checked.                                                    |
| `value`        | `string \| null`                              | No               | Value attribute for the checkbox.                                                         |
| `name`         | `string`                                      | No               | Used in form submissions.                                                                 |
| `form`         | `string \| null`                              | No               | Link to external form by ID.                                                              |
| `hint`         | `string`                                      | No               | Descriptive hint text.                                                                    |
| `disabled`     | `boolean \| string`                           | Yes              | Disables the checkbox.                                                                    |
| `required`     | `boolean \| string`                           | Yes              | Marks checkbox as required.                                                               |
| `indeterminate`| `boolean \| string`                           | Yes              | Sets checkbox to indeterminate state.                                                     |
| `size`         | `'small' \| 'medium' \| 'large' \| 'inherit'` | No               | Controls the size of the checkbox.                                                        |

## Outputs

| Event           | Description                                                   |
| --------------- | ------------------------------------------------------------- |
| `checkedChange` | Fires when the checked state changes.                         |
| `input`         | Fires on every user input.                                    |
| `blurEvent`     | Fires when checkbox loses focus.                              |
| `focusEvent`    | Fires when checkbox gains focus.                              |
| `change`        | Fires when the value changes.                                 |
| `waInvalid`     | Fires on failed validity check.                               |

## Two-Way Binding (Template-Driven)

Use `[(ngModel)]` for binding form values in Angular template-driven forms. Do not use custom `[(checked)]` syntax.

```html
<wa-checkbox [(ngModel)]="isAccepted" name="accept" hint="Accept terms and conditions">
  I accept the terms
</wa-checkbox>
```

The `name` attribute is required for `ngModel` in forms.

## Methods

| Method              | Description                                |
| ------------------- | ------------------------------------------ |
| `focus()`           | Programmatically focuses checkbox.         |
| `blur()`            | Removes focus from checkbox.               |
| `click()`           | Programmatically clicks the checkbox.      |
| `setCustomValidity()`| Sets custom validity message.             |

## CSS Custom Properties

These properties allow external styling of the checkbox through its parent, avoiding the need for inline styles or direct DOM access.

| Name                      | Description                                         |
| ------------------------- | --------------------------------------------------- |
| `--background-color`      | The checkbox's background color.                    |
| `--background-color-checked` | The checkbox's background color when checked.    |
| `--border-color`          | The color of the checkbox's borders.                |
| `--border-color-checked`  | The color of the checkbox's borders when checked.   |
| `--border-radius`         | The radius of the checkbox's corners.               |
| `--border-style`          | The style of the checkbox's borders.                |
| `--border-width`          | The width of the checkbox's borders. Expects a single value. |
| `--box-shadow`            | The shadow effects around the edges of the checkbox. |
| `--checked-icon-color`    | The color of the checkbox's icon.                   |
| `--toggle-size`           | The size of the checkbox.                           |

## Examples

```html
<!-- Basic checkbox -->
<wa-checkbox label="Accept terms"></wa-checkbox>

<!-- Checked checkbox with custom styling -->
<wa-checkbox 
  [checked]="true" 
  [backgroundColor]="'#f0f0f0'" 
  [backgroundColorChecked]="'#4a90e2'" 
  [borderColor]="'#cccccc'"
  [borderColorChecked]="'#2a70c2'"
  [borderRadius]="'4px'"
  [checkedIconColor]="'white'">
  Custom styled checkbox
</wa-checkbox>

<!-- Required checkbox in a form -->
<form>
  <wa-checkbox 
    name="agreement" 
    [required]="true" 
    hint="You must agree to continue">
    I agree to the terms
  </wa-checkbox>
</form>

<!-- Indeterminate state checkbox -->
<wa-checkbox [indeterminate]="true">Select all items</wa-checkbox>

<!-- Different sizes -->
<wa-checkbox size="small">Small checkbox</wa-checkbox>
<wa-checkbox size="medium">Medium checkbox</wa-checkbox>
<wa-checkbox size="large">Large checkbox</wa-checkbox>

<!-- Using ngModel in a form -->
<form #myForm="ngForm" (ngSubmit)="onSubmit(myForm)">
  <wa-checkbox 
    [(ngModel)]="user.acceptTerms" 
    name="acceptTerms" 
    [required]="true">
    I accept the terms and conditions
  </wa-checkbox>
  <button type="submit" [disabled]="!myForm.valid">Submit</button>
</form>
```

## Form Integration

Supports both **template-driven forms** using `ngModel` and **reactive forms**. When using with template-driven forms, ensure the `name` attribute is set.

```html
<!-- Template-driven form -->
<form #myForm="ngForm">
  <wa-checkbox [(ngModel)]="user.acceptTerms" name="acceptTerms" required>
    Accept Terms
  </wa-checkbox>
</form>

<!-- Reactive form -->
<form [formGroup]="myForm">
  <wa-checkbox formControlName="acceptTerms">
    Accept Terms
  </wa-checkbox>
</form>
```

## Notes

* Always use property binding for boolean inputs (e.g., `[checked]="true"`, `[required]="isRequired"`).
* For accessibility, ensure checkboxes have associated text content or labels.
* Use `indeterminate` state for parent checkboxes that control a group of child checkboxes.
* Custom styling can be applied through CSS custom properties or direct style binding.
* When using `ngModel`, always include the `name` attribute for proper form integration.
* For reactive forms, use `formControlName` or `formControl` directives.
