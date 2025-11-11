## Icon Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

The `wa-icon` Web Awesome component is wrapped as a standalone Angular component with full binding and integration support. This component renders icons from various libraries and supports styling, accessibility, and advanced configuration.

### Selector

`wa-icon`

### Description

Use the icon component to render visual symbols. These can be semantic (e.g., action indicators), decorative, or accessible. Icons support families, variants, custom sources, styling, fixed dimensions, and accessibility labeling.

### Inputs

| Input             | Type      | Binding Required | Description                                         |
| ----------------- | --------- | ---------------- | --------------------------------------------------- |
| `name`            | `string`  | Yes              | The name of the icon.                               |
| `family`          | `string`  | No               | Font Awesome family (e.g., `classic`, `brands`).    |
| `variant`         | `string`  | No               | Variant within a family (e.g., `regular`, `solid`). |
| `library`         | `string`  | No               | Name of a registered icon library.                  |
| `src`             | `string`  | No               | URL to an SVG resource for custom icons.            |
| `label`           | `string`  | No               | Accessible label for assistive technologies.        |
| `fixedWidth`      | `boolean` | No               | If true, forces a fixed 1em width.                  |
| `color`           | `string`  | No               | Sets the icon's text color directly.                |
| `backgroundColor` | `string`  | No               | Sets the icon's background color.                   |
| `fontSize`        | `string`  | No               | Adjusts the icon's font size.                       |

### Styling Rules

* Font size determines the rendered size of the icon.
* Text color is inherited unless explicitly overridden.
* Use `fixedWidth` for aligning icons in lists or button groups.
* The directive supports native Angular-style inputs for `color`, `backgroundColor`, and `fontSize`, which apply styles directly to the `<wa-icon>` element.

### Shortcut Styles for Consumers


> ✅ These variables allow external styling of the `wa-icon` through its parent, avoiding the need for inline styles or direct DOM access.


```css 
--primary-color	: Sets a duotone icons primary color. Default currentColor
--primary-opacity	Sets a duotone icons primary opacity. Default 1
--secondary-color	: Sets a duotone icons secondary color. Default currentColor
--secondary-opacity	Sets a duotone iconss secondary opacity. Default 0.4
```

### Accessibility

* If the icon conveys semantic meaning, a `label` should be provided.
* Purely decorative icons should omit the `label` attribute.

### Slot Support

* May be used in named slots, such as `<wa-icon slot="icon">`.

### CSS Custom Properties

These can be used at any ancestor level to define default icon settings:

```css
wa-callout {
  --wa-icon-name: info-circle;
  --wa-icon-variant: regular;
  &[variant="warning"] { --wa-icon-name: triangle-exclamation; }
  &[variant="danger"]  { --wa-icon-name: circle-exclamation; }
  &[variant="success"] { --wa-icon-name: circle-check; }
}
```

### Custom Icon Libraries

To register a custom icon library:

```ts
registerIconLibrary('my-icons', {
  resolver: (name, family, variant) => `/assets/icons/${name}.svg`,
  mutator: svg => svg.setAttribute('fill', 'currentColor')
});
```

Use with:

```html
<wa-icon library="my-icons" name="smile"></wa-icon>
```

### Examples

```html
<wa-icon name="github" family="brands"></wa-icon>
<wa-icon name="star" variant="regular" label="Favorite"></wa-icon>
<wa-icon src="/assets/icons/cat.svg" style="font-size: 3rem;"></wa-icon>
<div style="font-size: 2em; color: #4a90e2;">
  <wa-icon name="bell"></wa-icon>
</div>
<wa-icon fixedWidth name="truck"></wa-icon>
<wa-icon name="heart" [color]="'#ff0000'" [fontSize]="'24px'" [backgroundColor]="'transparent'"></wa-icon>
```

### Notes

* Avoid using icon `name` without `family` or `variant` if the desired icon requires it.
* Dynamic CSS custom property changes can be used for hover effects or theming.
* Icons loaded via `src` must be accessible via CORS or local paths.

---

See related components like [Button](./button.rules.md) or [Callout](./callout.rules.md) for examples of icon integration.
