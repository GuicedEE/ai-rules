## Dialog Rules for Angular Wrapper

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

### Selector

`wa-dialog`

### Description

Wraps the `<wa-dialog>` Web Awesome component, providing Angular integration including bindings, events, and CSS custom property support. This component supports light-dismissable modals, accessibility labels, autofocus management, and lifecycle events.

### Inputs

| Input           | Type    | Description                                        |
| --------------- | ------- | -------------------------------------------------- |
| `open`          | boolean | Controls the visibility of the dialog.             |
| `label`         | string  | ARIA-accessible label. Required for accessibility. |
| `withoutHeader` | boolean | If true, hides the header section.                 |
| `lightDismiss`  | boolean | If true, clicking the overlay closes the dialog.   |

Each input should accept string form bindings as well (`[lightDismiss]="true"` or `lightDismiss="true"`).

### Outputs

| Output        | Payload                             | Description                                |          |                     |                                                                            |
| ------------- | ----------------------------------- | ------------------------------------------ | -------- | ------------------- | -------------------------------------------------------------------------- |
| `waShow`      | `CustomEvent<void>`                 | Emitted when dialog begins to open.        |          |                     |                                                                            |
| `waAfterShow` | `CustomEvent<void>`                 | Emitted after opening animations complete. |          |                     |                                                                            |
| `waHide`      | \`CustomEvent<{ source: HTMLElement | 'overlay'                                  | 'escape' | 'programmatic' }>\` | Emitted before dialog closes. Can call `event.preventDefault()` to cancel. |
| `waAfterHide` | `CustomEvent<void>`                 | Emitted after closing animations complete. |          |                     |                                                                            |

### React wrapper event props

For React 3.0.0 wrappers, subscribe to dialog lifecycle events using these prop names:

- onWaShow
- onWaAfterShow
- onWaHide
- onWaAfterHide

### Methods

| Method   | Returns | Description                         |
| -------- | ------- | ----------------------------------- |
| `show()` | `void`  | Opens the dialog programmatically.  |
| `hide()` | `void`  | Closes the dialog programmatically. |

### Slots

| Name             | Description                                     |
| ---------------- | ----------------------------------------------- |
| (default)        | The main content area.                          |
| `footer`         | Footer actions like buttons.                    |
| `header-actions` | Optional extra buttons beside the close button. |

### CSS Custom Properties (Style Inputs)

Supports these Angular-style inputs for styling, applied to the host:

* `backgroundColor`
* `borderRadius`
* `boxShadow`
* `spacing`
* `width`
* `showDuration`
* `hideDuration`

These map directly to the following CSS custom properties:

```css
--background-color
--border-radius
--box-shadow
--spacing
--width
--show-duration
--hide-duration
```

### Accessibility Notes

Always provide a `label` either through the `label` attribute or slot. This ensures screen readers correctly describe the dialog.

### Focus Management

Elements inside the dialog may use the `autofocus` attribute to receive focus when the dialog opens.

### Close Behaviors

You may close the dialog by:

* Clicking a button with `data-dialog="close"`
* Programmatically setting `open = false` or calling `hide()`
* User pressing Escape (unless intercepted)
* Clicking outside (if `lightDismiss` is true)

To prevent close behavior (e.g. for validation or confirmation), listen to `waHide` and call `event.preventDefault()`.

### Dependencies

This component depends on:

* [`<wa-icon>`](./icon.rules.md)
* [`<wa-icon-button>`](./icon-button.rules.md)

### Examples

```html
<wa-dialog label="Edit Item" lightDismiss [(open)]="isOpen">
  <p>Edit your item here.</p>
  <wa-button slot="footer" variant="brand" data-dialog="close">Close</wa-button>
</wa-dialog>

<wa-button (click)="isOpen = true">Open Dialog</wa-button>
```

```
@ViewChild('myDialog') dialogRef: ElementRef;

openDialog() {
  this.dialogRef.nativeElement.show();
}
```
