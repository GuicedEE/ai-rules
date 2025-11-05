## Tag Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Selector

`wa-tag`

### Description

Tags are compact visual indicators typically used for labeling, categorizing, or indicating selection status.

---

### Inputs

| Input        | Type       | Description                        |           |             |                                         |                                                            |                                          |
| ------------ | ---------- | ---------------------------------- | --------- | ----------- | --------------------------------------- | ---------------------------------------------------------- | ---------------------------------------- |
| `variant`    | \`'brand'  | 'neutral'                          | 'success' | 'warning'   | 'danger'                                | 'inherit'\`                                                | Theme of the tag. Defaults to `inherit`. |
| `appearance` | \`'accent' | 'outlined accent'                  | 'filled'  | 'outlined'  | 'outlined filled'\`                     | Controls the visual style. Default is `'outlined filled'`. |                                          |
| `size`       | \`'small'  | 'medium'                           | 'large'   | 'inherit'\` | Size of the tag. Defaults to `inherit`. |                                                            |                                          |
| `pill`       | `boolean`  | Enables pill (rounded) appearance. |           |             |                                         |                                                            |                                          |
| `removable`  | `boolean`  | Adds a remove button to the tag.   |           |             |                                         |                                                            |                                          |

---

### Outputs

| Output     | Description                                |
| ---------- | ------------------------------------------ |
| `waRemove` | Emitted when the remove button is clicked. |

---

### Slots

| Slot        | Description                  |
| ----------- | ---------------------------- |
| `(default)` | The content/text of the tag. |

---

### CSS Custom Properties

Set these directly on the host element via Angular-style `[style.--property]` bindings.

*(No documented custom properties specific to this component)*

---

### CSS Parts

| Part                  | Description                           |
| --------------------- | ------------------------------------- |
| `base`                | The component's outer wrapper         |
| `content`             | The internal label/content of the tag |
| `remove-button`       | The remove button slot container      |
| `remove-button__base` | Base of the remove icon button        |

---

### Dependencies

This component pulls in:

* `<wa-icon>`
* `<wa-icon-button>`

---

### Notes

* Tags support full keyboard accessibility and are styled consistently with Web Awesome's design tokens.
* Use the `waRemove` event to handle tag removal logic in Angular via `(waRemove)`.
* You may wrap tags in `<ng-container *ngFor>` to dynamically render from arrays.
* Consider using `variant="neutral"` for tags that do not need to convey status.
