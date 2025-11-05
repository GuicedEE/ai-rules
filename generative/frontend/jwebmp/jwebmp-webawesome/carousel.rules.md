📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).

# Carousel (`wa-carousel`)

This directive wraps the `<wa-carousel>` Web Awesome component to provide Angular integration for slide navigation, event binding, and structural layout.

## Selector

```ts
waCarousel
```

## Projected Content

This component wraps any number of `<wa-carousel-item>` components, which can contain arbitrary content (commonly `<img>`).

## Inputs

| Input              | Type                         | Binding Notes                                                          |
| ------------------ | ---------------------------- | ---------------------------------------------------------------------- |
| `loop`             | `boolean \| string`          | Enables infinite looping. Accepts boolean or string values (`"true"`). |
| `navigation`       | `boolean \| string`          | Displays prev/next buttons.                                            |
| `pagination`       | `boolean \| string`          | Displays slide indicator dots.                                         |
| `autoplay`         | `boolean \| string`          | Enables automatic sliding.                                             |
| `autoplayInterval` | `number \| string`           | Time in ms between auto slides. Defaults to 3000.                      |
| `slidesPerPage`    | `number \| string`           | How many slides to show at once.                                       |
| `slidesPerMove`    | `number \| string`           | How many slides to move on next/prev. Defaults to 1.                   |
| `orientation`      | `'horizontal' \| 'vertical'` | Layout orientation. Defaults to `horizontal`.                          |
| `mouseDragging`    | `boolean \| string`          | Enables click-and-drag mouse scrolling.                                |

## Outputs

| Output          | Description                                                        |
| --------------- | ------------------------------------------------------------------ |
| `waSlideChange` | Emits when the active slide changes. Provides `{ index: number }`. |

## Methods (Access via `@ViewChild`)

| Method         | Description                          |
| -------------- | ------------------------------------ |
| `next()`       | Scrolls forward by `slidesPerMove`.  |
| `previous()`   | Scrolls backward by `slidesPerMove`. |
| `goToSlide(i)` | Jumps to slide at index `i`.         |

## Styles / CSS Custom Properties

Apply styles directly to the component using CSS vars like:

* `--aspect-ratio`
* `--scroll-hint`
* `--pagination-color`, `--pagination-color-active`
* `--slide-gap`

## Slots

| Slot Name       | Purpose                                    |
| --------------- | ------------------------------------------ |
| (default)       | One or more `<wa-carousel-item>` children  |
| `next-icon`     | Optional replacement icon for "next" arrow |
| `previous-icon` | Optional replacement icon for "prev" arrow |

---

# Carousel Item (`wa-carousel-item`)

Represents a single slide. Accepts any HTML or Angular content.

## Selector

```ts
waCarouselItem
```

## Projected Content

Any content can be slotted in. Often `<img>` or textual/HTML blocks.

## Notes

* Inherits `--aspect-ratio` from the parent `<wa-carousel>`.
* Use standard Angular structural directives (`*ngFor`) to generate slides dynamically.

---

## Usage Example

```html
<wa-carousel pagination navigation loop autoplay autoplay-interval="4000">
  <wa-carousel-item *ngFor="let img of images">
    <img [src]="img.src" [alt]="img.alt" />
  </wa-carousel-item>
</wa-carousel>
```

## See Also

* [Button rules](./button.rules.md)
* [Icon rules](./icon.rules.md)
