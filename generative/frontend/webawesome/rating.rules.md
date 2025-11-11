📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

# Rating Component Rules (`<wa-rating>`) for Angular Wrapper

The `wa-rating` component allows users to provide or view ratings using configurable visual representations. This Angular directive wraps the native Web Awesome component and integrates form bindings, layout control, and interaction hooks.

---

## ✅ Selector

```ts
selector: 'wa-rating[waRating]'
```

---

## 🧩 Inputs

| Input             | Type      | Binding Required | Accepts Strings | Notes                                         |    |   |                                      |
| ----------------- | --------- | ---------------- | --------------- | --------------------------------------------- | -- | - | ------------------------------------ |
| `label`           | `string`  | No               | ✅               | Describes the component for accessibility.    |    |   |                                      |
| `value`           | `number`  | Yes              | ✅               | Current selected value (supports fractional). |    |   |                                      |
| `max`             | `number`  | No               | ✅               | Defaults to 5. Maximum rating value.          |    |   |                                      |
| `precision`       | `number`  | No               | ✅               | Supports decimal steps like 0.5, etc.         |    |   |                                      |
| `readonly`        | `boolean` | No               | ✅               | Makes component non-editable.                 |    |   |                                      |
| `disabled`        | `boolean` | No               | ✅               | Fully disables the control.                   |    |   |                                      |
| `size`            | \`'small' | 'medium'         | 'large'         | 'inherit'\`                                   | No | ✅ | Font-size can also override visuals. |
| `color`           | `string`  | No               | ✅               | Applies to base or symbols.                   |    |   |                                      |
| `backgroundColor` | `string`  | No               | ✅               | Applies to host background.                   |    |   |                                      |
| `fontSize`        | `string`  | No               | ✅               | Overrides symbol sizing.                      |    |   |                                      |

> All boolean and numeric inputs must accept both native values (`[value]`) and string representations (`value="..."`).

---

## 🧪 Outputs

| Output     | Payload                                         | Description                               |
| ---------- | ----------------------------------------------- | ----------------------------------------- |
| `waChange` | `CustomEvent<number>`                           | Emitted when value changes.               |
| `waHover`  | `CustomEvent<{ phase: string, value: number }>` | Emitted when hovering (start, move, end). |

These events are mapped using Angular `@Output()` bindings with native `addEventListener` support in the wrapper.

---

## 🧠 Content Projection

Content is not projected. The component's display is driven via JS attributes or `getSymbol()` logic.

---

## 🧰 Custom Behavior

Use `getSymbol()` for custom icons. Angular must call this manually using `ElementRef.nativeElement.getSymbol = fn` after render lifecycle:

```ts
this.ratingRef.nativeElement.getSymbol = (value: number) => {
  return `<wa-icon name="star" variant="solid"></wa-icon>`;
};
```

> Must run after `customElements.whenDefined('wa-rating')` and optionally `updateComplete`.

---

## 🎨 Styling Support

Supports Angular-style [Visual Styling Inputs](../../../RULES.md);

These apply to the host or symbol wrapper directly.

### CSS Custom Properties (Styling Inputs)

| Property                | Description                |
| ----------------------- | -------------------------- |
| `--symbol-color`        | Inactive color for symbols |
| `--symbol-color-active` | Active rating color        |
| `--symbol-spacing`      | Space between symbols      |

### CSS Parts

| Part   | Description    |
| ------ | -------------- |
| `base` | Base container |

Use global or component-level theming by applying these properties via `::ng-deep` or encapsulated styles where needed.

---

## 📏 Methods

Accessible via `@ViewChild` or `ElementRef`:

* `focus(options?: FocusOptions)` — Programmatically focuses the rating component. |
* `blur()` — Removes focus from the component. |

> These methods follow the standard Angular platform interaction and should be used for keyboard accessibility, programmatic navigation, or visual effects.

---

## 🧪 Testing Tips

* Bind `value`, `readonly`, and `disabled` and verify rendering vs state.
* Simulate `waChange` and `waHover` using `dispatchEvent()` with detail payloads.
* Validate focus/blur behaviors when part of form groups or accessibility features.

---

## ⚠️ Implementation Notes

* Always supply a `label` attribute.
* `precision` does not impact visuals unless fractional values are provided.
* Use `readonly` with visual indicators (e.g., cursor: not-allowed).
* To ensure a11y compliance, ensure focus/blur support is testable.
* Consider `tooltip`, `aria-label`, or external visual prompts when using `waHover`.

---

## 🔗 Related Rules

* Depends on: [`<wa-icon>`](./icon.rules.md)
* Often used inside: [`<wa-card>`](./card.rules.md)
