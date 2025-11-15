# Intersection Observer Rules

Defines usage rules for WebAwesome Intersection Observer.

## Overview
- Tag: `<wa-intersection-observer>`
- Purpose: Tracks immediate child elements and fires events as they move in and out of view using the IntersectionObserver API.
- React wrapper: WaIntersectionObserver (onWaIntersect)
- Status: stable
- Since: 2.0

## Slots
- default — Elements to track. Only immediate children of the host are monitored.

## Events
- `wa-intersect` — Detail: `{ entry: IntersectionObserverEntry }` when a tracked child begins or ceases intersecting.

### React wrapper event props
- Use `onWaIntersect` to subscribe in React (WebAwesome React 3.0.0).

## Usage Example
```html
<wa-intersection-observer>
  <img src="image-a.jpg" alt="A"/>
  <img src="image-b.jpg" alt="B"/>
</wa-intersection-observer>
<script>
  const io = document.querySelector('wa-intersection-observer');
  io.addEventListener('wa-intersect', (ev) => {
    const { entry } = ev.detail;
    console.log('Intersecting:', entry.target, entry.isIntersecting);
  });
</script>
```

## Integration Notes
- For granular control (root, rootMargin, threshold), configure via the component’s API if available in documentation, or fall back to direct JS with native IntersectionObserver for custom logic.
- Only immediate children are observed; wrap deeper elements if necessary.
