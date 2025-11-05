## Details Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component Selector

`wa-details`

### Angular Selector

`waDetails`

### Description

Provides an expandable details section with summary text and additional content. Compatible with both simple attribute and slotted HTML summary.

### Inputs

| Input        | Type       | Binding    | Description                                                    |                                                                     |           |                                                                          |
| ------------ | ---------- | ---------- | -------------------------------------------------------------- | ------------------------------------------------------------------- | --------- | ------------------------------------------------------------------------ |
| `summary`    | `string`   | Attribute  | Text for the header. Prefer using the `summary` slot for HTML. |                                                                     |           |                                                                          |
| `disabled`   | \`boolean  | string\`   | Attribute                                                      | Disables toggle behavior.                                           |           |                                                                          |
| `appearance` | \`'filled' | 'outlined' | 'plain'                                                        | string\`                                                            | Attribute | Visual style for the component. Multiple values allowed space-separated. |
| `open`       | \`boolean  | string\`   | Two-way                                                        | Controls open state of the details section. Supports `[(ngModel)]`. |           |                                                                          |

### Outputs

| Event         | Description                                     |
| ------------- | ----------------------------------------------- |
| `waShow`      | Emitted when the details expands.               |
| `waAfterShow` | Emitted after the expand animation completes.   |
| `waHide`      | Emitted when the details collapses.             |
| `waAfterHide` | Emitted after the collapse animation completes. |

### Methods (Optional Callbacks)

| Method   | Description                          |
| -------- | ------------------------------------ |
| `show()` | Opens the details programmatically.  |
| `hide()` | Closes the details programmatically. |

### Styling Inputs

Supports the following CSS custom properties as Angular-style inputs, applied inline to the host:

| Property          | Description                                   |
| ----------------- | --------------------------------------------- |
| `--icon-color`    | Color of the expand/collapse icon.            |
| `--spacing`       | Spacing between summary and content.          |
| `--show-duration` | Expand animation duration. Default `200ms`.   |
| `--hide-duration` | Collapse animation duration. Default `200ms`. |
| `--display`       | Sets the display behavior.                    |

These should be passed using standard Angular `[style.--property-name]` syntax or via mapped inputs where supported.

### Slots

| Slot Name       | Description                                     |
| --------------- | ----------------------------------------------- |
| `(default)`     | Content shown when expanded.                    |
| `summary`       | Optional slot for HTML summary instead of text. |
| `expand-icon`   | Custom icon when closed.                        |
| `collapse-icon` | Custom icon when open.                          |

### CSS Parts

| Part      | Description                      |
| --------- | -------------------------------- |
| `base`    | The `<details>` container.       |
| `header`  | Wraps the summary and icon.      |
| `summary` | The summary container.           |
| `icon`    | Wraps the expand/collapse icons. |
| `content` | The collapsible section.         |

### Example Usage

```html
<wa-details summary="View Details" appearance="filled outlined" [(ngModel)]="expanded">
  Detailed content here.
</wa-details>
```

With slot for HTML summary:

```html
<wa-details [(ngModel)]="isOpen">
  <span slot="summary">
    More info <a href="#">click here</a>
  </span>
  <p>This is detailed information shown when open.</p>
</wa-details>
```

### Related Components

* [`wa-icon`](./icon.rules.md)

---

Auto-generated rules for the Angular Web Awesome wrapper.
