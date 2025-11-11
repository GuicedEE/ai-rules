## Copy Button Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component Tag

```html
<wa-copy-button></wa-copy-button>
```

### Angular Selector

```ts
waCopyButton
```

### Inputs

| Input              | Type      | Binding Required | Notes                                                      |          |          |                    |
| ------------------ | --------- | ---------------- | ---------------------------------------------------------- | -------- | -------- | ------------------ |
| `value`            | `string`  | Optional         | Text value to copy. Ignored if `from` is set.              |          |          |                    |
| `from`             | `string`  | Optional         | Target element's ID. Supports `[attr]` and `.prop` syntax. |          |          |                    |
| `copyLabel`        | `string`  | Optional         | Tooltip label before copy.                                 |          |          |                    |
| `successLabel`     | `string`  | Optional         | Tooltip label on success.                                  |          |          |                    |
| `errorLabel`       | `string`  | Optional         | Tooltip label on error.                                    |          |          |                    |
| `feedbackDuration` | `number`  | Optional         | Tooltip visibility duration in ms.                         |          |          |                    |
| `tooltipPlacement` | \`'top'   | 'right'          | 'bottom'                                                   | 'left'\` | Optional | Tooltip placement. |
| `disabled`         | `boolean` | Optional         | Use with `booleanAttribute` binding.                       |          |          |                    |

### Outputs

| Event     | Description                      |
| --------- | -------------------------------- |
| `waCopy`  | Fires after a successful copy.   |
| `waError` | Fires when copy operation fails. |

### Slots

| Name           | Description                    |
| -------------- | ------------------------------ |
| `copy-icon`    | Icon shown in default state.   |
| `success-icon` | Icon shown on successful copy. |
| `error-icon`   | Icon shown on error.           |

### Angular Usage

Use `[(ngModel)]` only with the `value` input for two-way binding if required. Do not bind to `from`.

```html
<wa-copy-button
  [(ngModel)]="copiedText"
  copyLabel="Click to copy"
  successLabel="Copied!"
  errorLabel="Failed to copy"
  feedbackDuration="2000"
></wa-copy-button>
```

You can also reference another DOM element:

```html
<wa-input id="myInput" [(ngModel)]="form.input"></wa-input>
<wa-copy-button from="myInput.value"></wa-copy-button>
```

### Accessibility

Always provide contextual labels or use `aria-label` where dynamic content is used.

### Styling

Supports customization via parts and CSS variables.

#### Shortcut Styling

For common styles:

* Add `.wa-primary`, `.wa-danger`, or `.wa-muted` for semantic coloring.
* Use `.wa-sm`, `.wa-md`, `.wa-lg` for sizing shortcuts.
* Add `.wa-inline` for inline display.

#### Advanced Customization

```css
::part(button) {
  background-color: #333;
}

::part(copy-icon) {
  color: var(--wa-color-neutral);
}

::part(success-icon) {
  color: var(--wa-color-success);
}

::part(error-icon) {
  color: var(--wa-color-danger);
}
```

### Dependencies

* [wa-icon](./icon.rules.md)
* [wa-tooltip](./tooltip.rules.md)
* [wa-popup](./popup.rules.md)
