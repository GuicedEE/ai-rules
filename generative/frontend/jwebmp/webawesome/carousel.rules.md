# WaCarousel — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-carousel` with `WaCarouselItem` children. Mirrors ../../webawesome/carousel.rules.md.

Usage
- Create `WaCarousel` and add `WaCarouselItem` slides; configure autoplay, interval, controls, indicators via fluent setters.
- Place carousel within clusters/stacks; grid utilities belong on the parent container.
- Provide alt text on slide content for accessibility.

Patterns
- Keep CRTP chaining; avoid inline HTML for slides—use components inside items instead.
- Ensure focusable controls for keyboard navigation; honor prefers-reduced-motion if disabling autoplay.
