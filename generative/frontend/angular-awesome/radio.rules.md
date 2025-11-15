📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

# Radio Group

The Angular wrapper exposes `<wa-radio-group>` along with its companion components `<wa-radio>` and `<wa-radio-button>`. It binds via `[(ngModel)]` for the `value` attribute. This directive must **not** use reactive patterns.

## Usage

```html
<wa-radio-group [(ngModel)]="selectedValue" label="Select an option" name="group1">
  <wa-radio value="1">Option 1</wa-radio>
  <wa-radio value="2">Option 2</wa-radio>
  <wa-radio value="3">Option 3</wa-radio>
</wa-radio-group>
```

## Inputs

* `label: string`
* `hint: string`
* `name: string`
* `orientation: 'horizontal' | 'vertical'`
* `size: 'small' | 'medium' | 'large' | 'inherit'`
* `required: boolean`
* `withLabel: boolean`
* `withHint: boolean`

## Outputs

* `(blurEvent)`: emitted when the control loses focus
* `(focusEvent)`: emitted when the control gains focus
* `(input)`: emitted on user input
* `(change)`: emitted when selected value changes
* `(waInvalid)`: emitted when validation fails

## Styling Inputs

These Angular-style inputs map to the CSS custom properties exposed by the underlying Web Awesome components:

**`wa-radio-group`**:

* `styleRadiosGap` → `--gap`

**`wa-radio`**:

* `styleBackgroundColor` → `--background-color`
* `styleBackgroundColorChecked` → `--background-color-checked`
* `styleBorderColor` → `--border-color`
* `styleBorderColorChecked` → `--border-color-checked`
* `styleBorderStyle` → `--border-style`
* `styleBorderWidth` → `--border-width`
* `styleBoxShadow` → `--box-shadow`
* `styleCheckedIconColor` → `--checked-icon-color`
* `styleCheckedIconScale` → `--checked-icon-scale`
* `styleToggleSize` → `--toggle-size`

**`wa-radio-button`**:

* `styleIndicatorColor` → `--indicator-color`
* `styleIndicatorWidth` → `--indicator-width`
* `styleDisplay` → `--display`

## Notes

* Use `<wa-radio>` for traditional selection UI.
* Use `<wa-radio-button>` for a button-like UX (e.g., pill, icons).
* Slotted icons via `slot="prefix"` or `slot="suffix"` are supported inside `wa-radio-button`.
* `formControlName` is not supported; only `[(ngModel)]` binding is allowed.
* Do not use reactive forms.

## Accessibility

* `label` is required for proper accessibility.
* `hint` is optional but recommended when relevant.

## SSR

Enable SSR-friendly flags as needed:

* `withLabel`
* `withHint`
* `withPrefix`
* `withSuffix`

## Example

```html
<wa-radio-group [(ngModel)]="mood" label="Mood" orientation="horizontal" name="mood">
  <wa-radio-button value="happy">
    <wa-icon name="face-smile" slot="prefix" label="Happy"></wa-icon>
    Happy
  </wa-radio-button>
  <wa-radio-button value="sad">
    <wa-icon name="face-frown" slot="prefix" label="Sad"></wa-icon>
    Sad
  </wa-radio-button>
</wa-radio-group>
```
