### ✨ `wa-animation.rules.md`

**Angular 19 Directive Rules for `<wa-animation>` Web Component**

---

## ✨ Purpose

This directive allows Angular developers to declaratively use the `<wa-animation>` Web Component, while enabling:

* Native tag usage (`wa-animation`) with Angular's `standalone` directives
* Support for all documented attributes as `@Input()`s
* Optional programmatic control for dynamic animation playback
* Projection of a single child element (container or control)
* Compatibility with Web Awesome JavaScript API for keyframes, names, and easing access
* Interoperation with scroll-based triggers and dynamic update services
* Full support for JavaScript-only properties such as `keyframes`, `currentTime`, and `playbackRate`
* Output event bindings for animation lifecycle

---

## ✅ Supported `@Input()` Bindings

| Input            | Type                      | HTML Attribute    | Notes                                   |
| ---------------- | ------------------------- | ----------------- | --------------------------------------- |
| `name`           | `string`                  | `name`            | Built-in animation name                 |
| `play`           | `boolean`                 | `play`            | Starts animation                        |
| `delay`          | `number`                  | `delay`           | Delay before animation starts (ms)      |
| `duration`       | `number`                  | `duration`        | Animation duration per iteration (ms)   |
| `easing`         | `string`                  | `easing`          | Web Awesome or custom easing            |
| `direction`      | `string`                  | `direction`       | normal, reverse, alternate, etc.        |
| `iterations`     | `number`                  | `iterations`      | Number of loops                         |
| `iterationStart` | `number`                  | `iteration-start` | Offset start (0-1)                      |
| `endDelay`       | `number`                  | `end-delay`       | Delay after end of animation            |
| `fill`           | `string`                  | `fill`            | auto, forwards, backwards, both         |
| `playbackRate`   | `number`                  | `playback-rate`   | Playback speed, negative allowed        |
| `keyframes`      | `Keyframe[] \| undefined` | JS-only           | Overrides `name`, for custom animation  |
| `currentTime`    | `CSSNumberish`            | JS-only           | Manually control current animation time |

---

## 💡 Slot Usage

Slot content is restricted to a **single child**:

```html
<wa-animation name="bounce" play>
  <div class="box"></div>
</wa-animation>
```

* Avoid slotted content other than the primary animated element
* To animate multiple items, wrap in a container

---

## 🔧 Directive Implementation Notes

### Selector

```ts
@Directive({
  selector: 'wa-animation',
  standalone: true
})
```

### Lifecycle Setup

Attributes and styles should be set in `ngOnInit()` via `ElementRef` and `Renderer2`:

```ts
ngOnInit() {
  const nativeEl = this.el.nativeElement as HTMLElement;

  this.setAttr('name', this.name);
  if (this.play) this.renderer.setAttribute(nativeEl, 'play', '');
  this.setAttr('delay', this.delay?.toString());
  this.setAttr('duration', this.duration?.toString());
  this.setAttr('easing', this.easing);
  this.setAttr('direction', this.direction);
  this.setAttr('iterations', this.iterations?.toString());
  this.setAttr('iteration-start', this.iterationStart?.toString());
  this.setAttr('end-delay', this.endDelay?.toString());
  this.setAttr('fill', this.fill);
  this.setAttr('playback-rate', this.playbackRate?.toString());

  this.setStyle('--control-box-size', this.controlBoxSize);
  this.setStyle('--icon-size', this.iconSize);

  if (this.keyframes) {
    (nativeEl as any).keyframes = this.keyframes;
  }
  if (this.currentTime !== undefined) {
    (nativeEl as any).currentTime = this.currentTime;
  }
}
```

### JS Property Support

Expose the native element for direct interaction:

```ts
public get nativeAnimation(): HTMLElement {
  return this.el.nativeElement;
}
```

---

## 🧠 Dynamic Controls (JavaScript Interop)

You can use Angular services or template refs to integrate runtime interaction:

```ts
@ViewChild('myAnim') animRef: ElementRef;

startAnim() {
  this.animRef.nativeElement.play = true;
}
```

Also compatible with:

* `IntersectionObserver`-based play toggling
* DOM queries for `wa-animation` updates
* `getAnimationNames()` and `getEasingNames()` from Web Awesome

---

## 📊 Styling

Support `[style.width]`, `[style.height]`, and parts:

```css
::part(control-box) { ... }
```

Custom CSS variables:

* `--control-box-size`
* `--icon-size`

---

## 🗘️ Examples

```html
<wa-animation name="rubberBand" duration="1000" iterations="1" play>
  <wa-button variant="brand">Click Me</wa-button>
</wa-animation>

<wa-animation [name]="animation" [duration]="2000" [easing]="'ease-in-out'">
  <div class="box"></div>
</wa-animation>

<wa-animation #myAnim name="flip" [playbackRate]="2">
  <div class="icon"></div>
</wa-animation>
<button (click)="startAnim()">Start</button>
```

```ts
keyframes = [
  {
    offset: 0,
    easing: 'ease-in-out',
    fillMode: 'both',
    transform: 'rotate(0deg)'
  },
  {
    offset: 1,
    easing: 'ease-in-out',
    fillMode: 'both',
    transform: 'rotate(90deg)'
  }
];
```

---

## 📊 Events

You can listen to emitted events using Angular's native event binding:

```html
<wa-animation
  (wa-start)="onStart()"
  (wa-finish)="onFinish()"
  (wa-cancel)="onCancel()"
  name="jello"
  play>
  <div class="box"></div>
</wa-animation>
```

| Event       | Description                       |
| ----------- | --------------------------------- |
| `wa-start`  | Fired when animation starts       |
| `wa-finish` | Fired when animation completes    |
| `wa-cancel` | Fired when animation is cancelled |

---

## 🗓️ Dependencies

* `<wa-icon>` is required when projecting slot icons.
* Custom `keyframes` or `IntersectionObserver` usage requires manual JavaScript.
* `wa-select`, `wa-input`, or `wa-option` used for dynamic control patterns.

---

📌 This directive assumes compliance with general [Web Awesome Angular Rules](../../../RULES.md).
