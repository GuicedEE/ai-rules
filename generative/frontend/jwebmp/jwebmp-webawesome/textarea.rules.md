## Web Awesome Angular Wrapper: Textarea

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component Selector

`waTextarea`

### Description

Angular wrapper for the `<wa-textarea>` Web Awesome component. It collects multiline user input with optional labels, hints, resize behaviors, and appearance customization.

### Inputs

| Input            | Type       | Description                                  |                          |             |                       |                                  |                           |                          |                        |
| ---------------- | ---------- | -------------------------------------------- | ------------------------ | ----------- | --------------------- | -------------------------------- | ------------------------- | ------------------------ | ---------------------- |
| `value`          | `string`   | The current value of the textarea.           |                          |             |                       |                                  |                           |                          |                        |
| `placeholder`    | `string`   | Placeholder text when the input is empty.    |                          |             |                       |                                  |                           |                          |                        |
| `label`          | `string`   | A label for accessibility.                   |                          |             |                       |                                  |                           |                          |                        |
| `hint`           | `string`   | A hint that describes how to use the input.  |                          |             |                       |                                  |                           |                          |                        |
| `rows`           | `number`   | The number of rows shown by default.         |                          |             |                       |                                  |                           |                          |                        |
| `resize`         | \`'none'   | 'vertical'                                   | 'horizontal'             | 'both'      | 'auto'\`              | Resize behavior of the textarea. |                           |                          |                        |
| `size`           | \`'small'  | 'medium'                                     | 'large'                  | 'inherit'\` | Size of the textarea. |                                  |                           |                          |                        |
| `appearance`     | \`'filled' | 'outlined'\`                                 | Visual appearance style. |             |                       |                                  |                           |                          |                        |
| `disabled`       | `boolean`  | Disables the textarea.                       |                          |             |                       |                                  |                           |                          |                        |
| `readonly`       | `boolean`  | Makes the textarea read-only.                |                          |             |                       |                                  |                           |                          |                        |
| `name`           | `string`   | Name used in form submission.                |                          |             |                       |                                  |                           |                          |                        |
| `required`       | `boolean`  | Makes the textarea a required field.         |                          |             |                       |                                  |                           |                          |                        |
| `minlength`      | `number`   | Minimum length constraint.                   |                          |             |                       |                                  |                           |                          |                        |
| `maxlength`      | `number`   | Maximum length constraint.                   |                          |             |                       |                                  |                           |                          |                        |
| `autocapitalize` | \`'off'    | 'none'                                       | 'on'                     | 'sentences' | 'words'               | 'characters'\`                   | Auto-capitalization mode. |                          |                        |
| `autocorrect`    | `string`   | Enables/disables browser autocorrection.     |                          |             |                       |                                  |                           |                          |                        |
| `autocomplete`   | `string`   | Autocomplete hint for browsers.              |                          |             |                       |                                  |                           |                          |                        |
| `autofocus`      | `boolean`  | Automatically focus this field on page load. |                          |             |                       |                                  |                           |                          |                        |
| `enterkeyhint`   | \`'enter'  | 'done'                                       | 'go'                     | 'next'      | 'previous'            | 'search'                         | 'send'\`                  | Keyboard enter key hint. |                        |
| `spellcheck`     | `boolean`  | Whether spellchecking is enabled.            |                          |             |                       |                                  |                           |                          |                        |
| `inputmode`      | \`'none'   | 'text'                                       | 'decimal'                | 'numeric'   | 'tel'                 | 'search'                         | 'email'                   | 'url'\`                  | Virtual keyboard type. |
| `withLabel`      | `boolean`  | SSR helper when using `label` slot.          |                          |             |                       |                                  |                           |                          |                        |
| `withHint`       | `boolean`  | SSR helper when using `hint` slot.           |                          |             |                       |                                  |                           |                          |                        |

### Outputs

| Output        | Description                             |
| ------------- | --------------------------------------- |
| `focusEvent`  | Emits when the textarea gains focus.    |
| `blurEvent`   | Emits when the textarea loses focus.    |
| `inputEvent`  | Emits on every value change.            |
| `changeEvent` | Emits when value is committed by user.  |
| `invalid`     | Emits when the form control is invalid. |

### Styling Inputs

| Input             | Description                   |
| ----------------- | ----------------------------- |
| `backgroundColor` | Maps to `--background-color`. |
| `borderColor`     | Maps to `--border-color`.     |
| `borderWidth`     | Maps to `--border-width`.     |
| `boxShadow`       | Maps to `--box-shadow`.       |

These inputs set CSS custom properties directly on the host element.

### CSS States

* `:state(blank)` — applied when the textarea is empty

### CSS Parts

* `label`
* `form-control-input`
* `hint`
* `textarea`
* `base`

### Methods (optional)

| Method                | Description                |
| --------------------- | -------------------------- |
| `focus()`             | Sets focus to the control. |
| `blur()`              | Removes focus.             |
| `select()`            | Selects all text.          |
| `scrollPosition()`    | Gets/sets scroll position. |
| `setSelectionRange()` | Sets the selection range.  |
| `setRangeText()`      | Replaces a range of text.  |

### Form Integration

This component uses `ngModel` for two-way binding.

```html
<wa-textarea [(ngModel)]="value"></wa-textarea>
```

### Slots

* `label`
* `hint`

### Example

```html
<wa-textarea
  label="Feedback"
  hint="Please tell us what you think."
  rows="6"
  resize="auto"
  size="medium"
  [(ngModel)]="feedback"
></wa-textarea>
```

---

*Last updated: 2025-06-04*
