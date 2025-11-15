### Scroller Wrapper Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

The `wa-scroller-wrapper` component wraps the `<wa-scroller>` Web Awesome element and provides Angular-style bindings for all relevant attributes and styles.

#### ✅ Inputs

| Input              | Type                               | Description                                                       |
|-------------------|------------------------------------|-------------------------------------------------------------------|
| `orientation`      | `'horizontal' \| 'vertical'`        | Sets the scroll direction. Defaults to `'horizontal'`.            |
| `withoutScrollbar` | `boolean`                          | Hides the visible scrollbar while retaining scroll functionality. |
| `withoutShadow`    | `boolean`                          | Disables the scroll shadow visual indicator.                      |

#### 🎨 Style Inputs (mapped to CSS custom properties)

These inputs are applied directly to the host element and reflect the component's design system.

| Input         | Maps to CSS Var        | Description                                              |
|---------------|------------------------|----------------------------------------------------------|
| `shadowColor` | `--shadow-color`       | The base color of the scroll shadows.                    |
| `shadowSize`  | `--shadow-size`        | The size (blur/spread) of the scroll shadows.            |

#### 💡 Slots

This component projects content into the default slot of `<wa-scroller>`. Any content inside the Angular component will be wrapped and made scrollable accordingly.
