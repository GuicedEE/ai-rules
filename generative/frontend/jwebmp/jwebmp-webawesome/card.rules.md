# Card Component Rules

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

## Summary

The `<wa-card>` component represents a flexible container to group related content such as text, images, headers, and footers. The Angular wrapper must provide support for size, appearance, styling inputs, CSS properties, and optional slots, including header, footer, and image.

## Selector

```ts
selector: wa-card
```

## Inputs

| Input              | Type                                            | Binding Notes                      |
| ------------------ | ----------------------------------------------- | ---------------------------------- |
| `appearance`       | `'accent' \| 'filled' \| 'outlined' \| 'plain'` | Accept string or binding           |
| `size`             | `'small' \| 'medium' \| 'large' \| 'inherit'`   | Accept string or binding           |
| `withHeader`       | `boolean`                                       | Must be bound (`[withHeader]`)     |
| `withImage`        | `boolean`                                       | Must be bound (`[withImage]`)      |
| `withFooter`       | `boolean`                                       | Must be bound (`[withFooter]`)     |
| `color`            | `string`                                        | Applied to host or wrapper element |
| `backgroundColor`  | `string`                                        | Applied to host or wrapper element |
| `fontSize`         | `string`                                        | Applied to host or wrapper element |
| `borderRadius`     | `string`                                        | Maps to `--border-radius`          |
| `borderColor`      | `string`                                        | Maps to `--border-color`           |
| `innerBorderColor` | `string`                                        | Maps to `--inner-border-color`     |
| `borderWidth`      | `string`                                        | Maps to `--border-width`           |
| `spacing`          | `string`                                        | Maps to `--spacing`                |

⚠️ All boolean and numeric inputs **must** be bound. Most string inputs (including enums) should **also accept static strings** for template ease.

## Slots

| Slot        | Description                          |
| ----------- | ------------------------------------ |
| *(default)* | The main content of the card         |
| `header`    | Optional content for the header area |
| `footer`    | Optional content for the footer area |
| `image`     | Optional image for the card top      |

## Angular Content Projection

Use `ng-content select` to enable slot support:

```html
<wa-card [size]="size"
         [appearance]="appearance"
         [withHeader]="withHeader"
         [withImage]="withImage"
         [withFooter]="withFooter"
         [color]="color"
         [backgroundColor]="backgroundColor"
         [fontSize]="fontSize"
         [borderRadius]="borderRadius"
         [borderColor]="borderColor"
         [innerBorderColor]="innerBorderColor"
         [borderWidth]="borderWidth"
         [spacing]="spacing">
  <ng-content select="[slot='image']"></ng-content>
  <ng-content select="[slot='header']"></ng-content>
  <ng-content></ng-content>
  <ng-content select="[slot='footer']"></ng-content>
</wa-card>
```

## Events

📭 No custom events emitted.

## Styling Inputs

These native Angular-style styling inputs are supported:

* `color`
* `backgroundColor`
* `fontSize`
* `borderRadius`
* `borderColor`
* `innerBorderColor`
* `borderWidth`
* `spacing`

All values are mapped to corresponding CSS custom properties if applicable.

## CSS Support

### CSS Custom Properties

| Property               | Purpose                 |
| ---------------------- | ----------------------- |
| `--border-radius`      | Card corner radius      |
| `--border-color`       | Border color            |
| `--inner-border-color` | Divider line color      |
| `--border-width`       | Border thickness        |
| `--spacing`            | Internal layout spacing |

### CSS Parts

| Part     | Description                |
| -------- | -------------------------- |
| `image`  | Wrapper for image slot     |
| `header` | Wrapper for header content |
| `body`   | Wrapper for main content   |
| `footer` | Wrapper for footer content |

## Related Components

* [Button](./button.rules.md)
* [Rating](./rating.rules.md)
* [Icon Button](./icon-button.rules.md)

## SSR Tips

Use `withHeader`, `withFooter`, or `withImage` bindings when content is injected server-side to ensure proper slot rendering.

## Example

```html
<wa-card [size]="'medium'"
         appearance="outlined"
         [withHeader]="true"
         [withFooter]="true"
         color="inherit"
         backgroundColor="var(--wa-color-surface)"
         fontSize="1rem"
         borderRadius="12px"
         borderColor="var(--wa-color-border)"
         innerBorderColor="lightgray"
         borderWidth="1px"
         spacing="var(--wa-space)">
  <img
    slot="image"
    src="https://example.com/cat.jpg"
    alt="Cat image"
  />

  <div slot="header">Cute Cat</div>

  This is a very adorable kitten that likes being inside cards.

  <div slot="footer" class="wa-split">
    <wa-button variant="brand">Adopt</wa-button>
    <wa-rating label="Rating"></wa-rating>
  </div>
</wa-card>
```
