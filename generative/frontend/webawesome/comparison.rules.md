## Web Awesome Angular Wrapper Rules: Comparison

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Component

```html
<wa-comparison></wa-comparison>
```

### Angular Selector

```ts
waComparison
```

### Inputs

| Input      | Type               | Description                                                                                           |
| ---------- | ------------------ | ----------------------------------------------------------------------------------------------------- |
| `position` | `number \| string` | The initial position of the divider as a percentage (0–100). Accepts bound values or string literals. |

### Outputs

| Output   | Description                                                              |
| -------- | ------------------------------------------------------------------------ |
| `change` | Emits when the position of the divider changes. Use for event listening. |

### Slots

| Slot     | Description                                                        |
| -------- | ------------------------------------------------------------------ |
| `before` | Content to appear on the left or top side. Typically an image.     |
| `after`  | Content to appear on the right or bottom side. Typically an image. |
| `handle` | Optional custom handle icon or markup.                             |

### Styling

This component exposes several CSS custom properties and parts:

#### CSS Custom Properties

| Property          | Description                     |
| ----------------- | ------------------------------- |
| `--divider-color` | Color of the slider divider     |
| `--divider-width` | Width of the slider line        |
| `--handle-color`  | Color of the slider handle icon |
| `--handle-size`   | Size of the handle element      |

#### CSS Parts

| Part      | Description                          |
| --------- | ------------------------------------ |
| `base`    | The wrapper container                |
| `before`  | Wrapper for the "before" content     |
| `after`   | Wrapper for the "after" content      |
| `divider` | The draggable slider divider         |
| `handle`  | The handle shown to drag the divider |

### Custom States

| State      | CSS Selector       |
| ---------- | ------------------ |
| `dragging` | `:state(dragging)` |

### Usage Example

```html
<wa-comparison [position]="position">
  <img slot="before" src="/assets/image-before.jpg" alt="Before" />
  <img slot="after" src="/assets/image-after.jpg" alt="After" />
</wa-comparison>
```

### Notes

* When binding `position`, both `number` and string literals like `'25'` are valid.
* `change` output is only emitted when the user interacts with the slider.
* Always ensure the slot content has equal dimensions for proper visual alignment.

### Dependencies

This component imports and requires:

* [`<wa-icon>`](./icon.rules.md)

---

End of `comparison.rules.md`
