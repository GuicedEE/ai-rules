📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

# Input

The Angular wrapper exposes `<wa-input>` for text input fields. It binds via `[(ngModel)]` for the `value` attribute. This directive must **not** use reactive patterns.

## Usage

```html
<wa-input [(ngModel)]="username" 
          label="Username" 
          placeholder="Enter your username"
          required>
</wa-input>
```

## Inputs

* `type: string` - Input type (text, password, email, number, etc.)
* `value: string | number | null` - Input value
* `size: 'small' | 'medium' | 'large' | 'inherit'` - Input size
* `appearance: 'filled' | 'outlined'` - Input appearance style
* `pill: boolean` - Whether to use pill-shaped input
* `label: string` - Label text
* `hint: string` - Hint text displayed below the input
* `clearable: boolean` - Whether to show a clear button
* `placeholder: string` - Placeholder text
* `readonly: boolean` - Whether the input is read-only
* `passwordToggle: boolean` - Whether to show password toggle button (for password type)
* `passwordVisible: boolean` - Whether password is initially visible
* `noSpinButtons: boolean` - Whether to hide spin buttons (for number type)
* `form: string` - Form ID to associate with
* `required: boolean` - Whether the input is required
* `pattern: string` - Validation pattern
* `minlength: number | string` - Minimum input length
* `maxlength: number | string` - Maximum input length
* `min: number | string` - Minimum value (for number type)
* `max: number | string` - Maximum value (for number type)
* `step: number | 'any'` - Step value (for number type)
* `autocapitalize: 'off' | 'none' | 'on' | 'sentences' | 'words' | 'characters'` - Autocapitalization behavior
* `autocorrect: 'on' | 'off'` - Autocorrection behavior
* `autocomplete: string` - Autocomplete behavior
* `autofocus: boolean` - Whether to autofocus the input
* `enterkeyhint: 'enter' | 'done' | 'go' | 'next' | 'previous' | 'search' | 'send'` - Customize enter key behavior
* `spellcheck: boolean` - Whether to enable spellcheck
* `inputmode: 'none' | 'text' | 'decimal' | 'numeric' | 'tel' | 'search' | 'email' | 'url'` - Input mode hint
* `withLabel: boolean` - SSR flag for label presence
* `withHint: boolean` - SSR flag for hint presence

## Outputs

* `(input)`: emitted on user input
* `(change)`: emitted when value changes
* `(focusEvent)`: emitted when the input gains focus
* `(blurEvent)`: emitted when the input loses focus
* `(waClear)`: emitted when the clear button is clicked
* `(waInvalid)`: emitted when validation fails

## Styling Inputs

These Angular-style inputs map to the CSS custom properties exposed by the underlying Web Awesome component:

* `backgroundColor` → `--background-color`
* `borderColor` → `--border-color`
* `borderWidth` → `--border-width`
* `boxShadow` → `--box-shadow`

## Methods

The directive exposes several methods for programmatic control:

* `focus(options?: FocusOptions)`: Programmatically focuses the input
* `blur()`: Programmatically blurs the input
* `select()`: Programmatically selects all text in the input
* `setSelectionRange(start: number, end: number, direction?: 'forward' | 'backward' | 'none')`: Sets the selection range
* `setRangeText(replacement: string, start: number, end: number, selectMode?: 'select' | 'start' | 'end' | 'preserve')`: Sets the range text
* `showPicker()`: Shows the picker (for date, color, etc. inputs)
* `stepUp()`: Steps up the value (for number inputs)
* `stepDown()`: Steps down the value (for number inputs)

## Notes

* Supports all standard HTML input types
* For password inputs, use `passwordToggle` to enable visibility toggle
* For number inputs, use `min`, `max`, and `step` for constraints
* `formControlName` is not supported; only `[(ngModel)]` binding is allowed
* Do not use reactive forms

## Accessibility

* `label` is required for proper accessibility
* `hint` is optional but recommended when relevant
* Use appropriate `type` attribute for semantic correctness

## SSR

Enable SSR-friendly flags as needed:

* `withLabel`
* `withHint`

## Examples

### Text Input

```html
<wa-input [(ngModel)]="name" 
          label="Full Name" 
          placeholder="Enter your full name"
          required>
</wa-input>
```

### Password Input

```html
<wa-input [(ngModel)]="password" 
          type="password" 
          label="Password" 
          passwordToggle="true"
          minlength="8">
</wa-input>
```

### Number Input

```html
<wa-input [(ngModel)]="quantity" 
          type="number" 
          label="Quantity" 
          min="1" 
          max="100" 
          step="1">
</wa-input>
```

### Email Input with Validation

```html
<wa-input [(ngModel)]="email" 
          type="email" 
          label="Email Address" 
          hint="We'll never share your email"
          required>
</wa-input>
```

### Styled Input

```html
<wa-input [(ngModel)]="username" 
          label="Username" 
          appearance="outlined"
          pill="true"
          borderColor="#3366ff"
          boxShadow="0 0 5px rgba(51, 102, 255, 0.5)">
</wa-input>
```
