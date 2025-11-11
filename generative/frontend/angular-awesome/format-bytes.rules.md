## Format Bytes Rules for Angular Wrapper

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component Selector

`wa-format-bytes`

### Angular Selector

`waFormatBytes`

### Inputs

* `value: number` — The number to format. Supports `[(ngModel)]` for two-way binding (template-driven forms only).
* `unit: 'byte' | 'bit'` — The unit to use for formatting. Defaults to `'byte'`.
* `display: 'long' | 'short' | 'narrow'` — Controls verbosity of the output. Defaults to `'short'`.
* `lang: string` — Optional locale string for localization (e.g., 'de', 'en-US').

### Outputs

None.

### Usage

Use this directive to format a number (e.g., a file size) into a human-readable byte or bit representation.

```html
<!-- Simple usage -->
<wa-format-bytes [value]="fileSize"></wa-format-bytes>

<!-- Two-way binding -->
<wa-format-bytes [(ngModel)]="fileSize"></wa-format-bytes>

<!-- Bits and localization -->
<wa-format-bytes [value]="fileSize" unit="bit" lang="de"></wa-format-bytes>
```

### Styling Inputs

This component does **not** expose visual styles or custom CSS properties and is purely functional in output.

### Notes

* Must not use reactive forms. Template-driven forms only.
* The directive should pass primitive bindings directly to the underlying Web Component.
* When `[(ngModel)]` is used, Angular should update the `value` property directly.
* Supports localized formatting via the `lang` attribute.

### Example

```html
<label>
  Enter file size:
  <input type="number" [(ngModel)]="fileSize">
</label>
<p>
  File size: <wa-format-bytes [value]="fileSize"></wa-format-bytes>
</p>
```
