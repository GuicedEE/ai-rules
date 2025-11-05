# Format Number Rules for Angular Wrapper

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

## Component

Wraps the `<wa-format-number>` Web Awesome component.

```html
<wa-format-number [value]="value" [type]="'decimal'" [currency]="'USD'"></wa-format-number>
```

## Angular Bindings

### Inputs

* `[(ngModel)]`: Binds to the `value` attribute of the component (must be a number).
* `type`: `'currency' | 'decimal' | 'percent'` — the number formatting style. Default is `'decimal'`.
* `currency`: ISO 4217 code (e.g. `USD`, `EUR`). Only used when `type="currency"`.
* `currencyDisplay`: `'symbol' | 'narrowSymbol' | 'code' | 'name'` — how currency should be displayed.
* `lang`: Locale string (e.g. `en`, `de`, `ru`).
* `noGrouping`: `true` disables thousands separators.
* `minimumIntegerDigits`: Minimum integer digits (1-21).
* `minimumFractionDigits`: Minimum fraction digits (0-100).
* `maximumFractionDigits`: Maximum fraction digits (0-100).
* `minimumSignificantDigits`: Minimum significant digits (1-21).
* `maximumSignificantDigits`: Maximum significant digits (1-21).

### Outputs

None (display-only component).

### Styling Inputs

These CSS custom properties should be available as Angular-style `[styleX]` inputs:

* `--color`
* `--font-size`
* `--font-weight`
* `--display`
* `--text-align`
* `--padding`

(If more are listed in future component spec, they should also be reflected here.)

## Notes

* This is a read-only formatter — for user-entered values use an input component instead.
* The wrapper must support `ngModel` binding for `value`, but should not use reactive forms.
* Values passed via `ngModel` must be numbers.

## Example

```html
<wa-format-number
  [(ngModel)]="amount"
  type="currency"
  currency="EUR"
  lang="de"
  [minimumFractionDigits]="2"
  [maximumFractionDigits]="2"
></wa-format-number>
```

## Dependencies

None (standalone component).
