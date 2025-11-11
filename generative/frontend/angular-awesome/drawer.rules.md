📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

# Drawer Rules (`<wa-drawer>`) 🔒

The `wa-drawer` component is an overlay panel that slides in from the top, bottom, start, or end of a container.
This Angular wrapper ensures binding compatibility, accessibility preservation, and CSS custom property styling.

---

## Selector

```ts
waDrawer
```

## Inputs

| Name            | Type                                              | Description                                           |
| --------------- | ------------------------------------------------- | ----------------------------------------------------- |
| `open`          | `boolean \| string`                               | Whether the drawer is open. Supports two-way binding. |
| `label`         | `string`                                          | Accessible label shown in the header.                 |
| `placement`     | `'top' \| 'end' \| 'bottom' \| 'start' \| string` | Slide direction. Default is `end`.                    |
| `withoutHeader` | `boolean \| string`                               | Hides the header and close button.                    |
| `lightDismiss`  | `boolean \| string`                               | Allows clicking the overlay to close.                 |

## Outputs

| Event            | Payload       | Description                           |
| ---------------- | ------------- | ------------------------------------- |
| `showEvent`      | `CustomEvent` | Fires when the drawer opens.          |
| `afterShowEvent` | `CustomEvent` | Fires after show animations complete. |
| `hideEvent`      | `CustomEvent` | Fires before closing. Cancelable.     |
| `afterHideEvent` | `CustomEvent` | Fires after drawer is fully closed.   |
| `focusEvent`     | `FocusEvent`  | Native focus event (re-emitted).      |
| `blurEvent`      | `FocusEvent`  | Native blur event (re-emitted).       |

---

### React wrapper event props

For React 3.0.0 wrappers, subscribe to drawer lifecycle events using these prop names:

- onWaShow
- onWaAfterShow
- onWaHide
- onWaAfterHide

## Methods

| Method   | Returns | Description                         |
| -------- | ------- | ----------------------------------- |
| `show()` | `void`  | Programmatically opens the drawer.  |
| `hide()` | `void`  | Programmatically closes the drawer. |

---

## Styling Inputs

Supports these Angular-style inputs for styling, applied to the host via CSS custom properties:

| Name              | CSS Variable         | Description                          |
| ----------------- | -------------------- | ------------------------------------ |
| `backgroundColor` | `--background-color` | Drawer background color.             |
| `boxShadow`       | `--box-shadow`       | Shadow styling around drawer.        |
| `spacing`         | `--spacing`          | Space around/within drawer content.  |
| `size`            | `--size`             | Width/height depending on placement. |
| `showDuration`    | `--show-duration`    | Opening animation duration.          |
| `hideDuration`    | `--hide-duration`    | Closing animation duration.          |

---

## Slots

| Slot Name        | Description                             |
| ---------------- | --------------------------------------- |
| (default)        | Main content.                           |
| `label`          | Custom label content.                   |
| `header-actions` | Additional icons (e.g. close/minimize). |
| `footer`         | Buttons or footer info.                 |

---

## CSS Parts

Exposed shadow DOM parts for theming:

* `header`
* `header-actions`
* `title`
* `close-button`
* `close-button__base`
* `body`
* `footer`

---

## Accessibility

* `label` is required for accessibility.
* Uses focus trapping.
* `autofocus` supported within projected content.

---

## Dependencies

* [`<wa-icon>`](./icon.rules.md)
* [`<wa-icon-button>`](./icon-button.rules.md)

---

## Notes

* Prevent closing with `wa-hide` event cancellation.
* Avoid relying on JavaScript for dismissal—use `data-drawer="close"`.
* Bind all booleans and numbers in templates for compatibility.
