# Popup Examples

## Basic Usage

```html
<button id="popup-trigger">Click me</button>
<wa-popup anchor="popup-trigger">
  <div class="popup-content">
    This is a basic popup anchored to a button.
  </div>
</wa-popup>
```

## Activating

Popups are inactive and hidden until the `active` attribute is applied. Removing the attribute will tear down all positioning logic and listeners, meaning you can have many idle popups on the page without affecting performance.

```html
<button id="popup-active-trigger" onclick="document.getElementById('active-popup').toggleAttribute('active')">
  Toggle Popup
</button>
<wa-popup id="active-popup" anchor="popup-active-trigger">
  <div class="popup-content">
    This popup is toggled by clicking the button.
  </div>
</wa-popup>
```

## External Anchors

By default, anchors are slotted into the popup using the `anchor` slot. If your anchor needs to live outside of the popup, you can pass the anchor's id to the `anchor` attribute.

```html
<!-- Using anchor attribute -->
<button id="external-anchor">External Anchor</button>
<wa-popup anchor="external-anchor" active>
  <div class="popup-content">
    This popup is anchored to an external element.
  </div>
</wa-popup>

<!-- Using anchor slot -->
<wa-popup active>
  <button slot="anchor">Slotted Anchor</button>
  <div class="popup-content">
    This popup uses a slotted anchor.
  </div>
</wa-popup>
```

## Placement

Use the `placement` attribute to tell the popup the preferred placement of the popup. Note that the actual position will vary to ensure the panel remains in the viewport if you're using positioning features such as flip and shift.

```html
<div class="placement-examples">
  <!-- Top placement (default) -->
  <div class="example">
    <button id="top-anchor">Top</button>
    <wa-popup anchor="top-anchor" placement="top" active>
      <div class="popup-content">Top placement</div>
    </wa-popup>
  </div>

  <!-- Right placement -->
  <div class="example">
    <button id="right-anchor">Right</button>
    <wa-popup anchor="right-anchor" placement="right" active>
      <div class="popup-content">Right placement</div>
    </wa-popup>
  </div>

  <!-- Bottom placement -->
  <div class="example">
    <button id="bottom-anchor">Bottom</button>
    <wa-popup anchor="bottom-anchor" placement="bottom" active>
      <div class="popup-content">Bottom placement</div>
    </wa-popup>
  </div>

  <!-- Left placement -->
  <div class="example">
    <button id="left-anchor">Left</button>
    <wa-popup anchor="left-anchor" placement="left" active>
      <div class="popup-content">Left placement</div>
    </wa-popup>
  </div>

  <!-- Top-start placement -->
  <div class="example">
    <button id="top-start-anchor">Top-Start</button>
    <wa-popup anchor="top-start-anchor" placement="top-start" active>
      <div class="popup-content">Top-start placement</div>
    </wa-popup>
  </div>

  <!-- Bottom-end placement -->
  <div class="example">
    <button id="bottom-end-anchor">Bottom-End</button>
    <wa-popup anchor="bottom-end-anchor" placement="bottom-end" active>
      <div class="popup-content">Bottom-end placement</div>
    </wa-popup>
  </div>
</div>
```

## Distance

Use the `distance` attribute to change the distance between the popup and its anchor. A positive value will move the popup further away and a negative value will move it closer.

```html
<div class="distance-examples">
  <!-- Default distance (0px) -->
  <div class="example">
    <button id="default-distance-anchor">Default</button>
    <wa-popup anchor="default-distance-anchor" active>
      <div class="popup-content">Default distance (0px)</div>
    </wa-popup>
  </div>

  <!-- 10px distance -->
  <div class="example">
    <button id="small-distance-anchor">Small</button>
    <wa-popup anchor="small-distance-anchor" distance="10" active>
      <div class="popup-content">10px distance</div>
    </wa-popup>
  </div>

  <!-- 20px distance -->
  <div class="example">
    <button id="medium-distance-anchor">Medium</button>
    <wa-popup anchor="medium-distance-anchor" distance="20" active>
      <div class="popup-content">20px distance</div>
    </wa-popup>
  </div>

  <!-- Negative distance (-5px) -->
  <div class="example">
    <button id="negative-distance-anchor">Negative</button>
    <wa-popup anchor="negative-distance-anchor" distance="-5" active>
      <div class="popup-content">-5px distance (closer)</div>
    </wa-popup>
  </div>
</div>
```

## Skidding

The `skidding` attribute is similar to distance, but instead allows you to offset the popup along the anchor's axis. Both positive and negative values are allowed.

```html
<div class="skidding-examples">
  <!-- Default skidding (0px) -->
  <div class="example">
    <button id="default-skidding-anchor">Default</button>
    <wa-popup anchor="default-skidding-anchor" placement="top" active>
      <div class="popup-content">Default skidding (0px)</div>
    </wa-popup>
  </div>

  <!-- 20px skidding -->
  <div class="example">
    <button id="positive-skidding-anchor">Positive</button>
    <wa-popup anchor="positive-skidding-anchor" placement="top" skidding="20" active>
      <div class="popup-content">20px skidding</div>
    </wa-popup>
  </div>

  <!-- -20px skidding -->
  <div class="example">
    <button id="negative-skidding-anchor">Negative</button>
    <wa-popup anchor="negative-skidding-anchor" placement="top" skidding="-20" active>
      <div class="popup-content">-20px skidding</div>
    </wa-popup>
  </div>
</div>
```

## Arrows

Add an arrow to your popup with the `arrow` attribute. It's usually a good idea to set a distance to make room for the arrow. To adjust the arrow's color and size, use the `--arrow-color` and `--arrow-size` custom properties, respectively. You can also target the arrow part to add additional styles such as shadows and borders.

```html
<div class="arrow-examples">
  <!-- Basic arrow -->
  <div class="example">
    <button id="basic-arrow-anchor">Basic Arrow</button>
    <wa-popup anchor="basic-arrow-anchor" arrow distance="8" active>
      <div class="popup-content">Popup with an arrow</div>
    </wa-popup>
  </div>

  <!-- Arrow with custom placement -->
  <div class="example">
    <button id="arrow-placement-anchor">Custom Placement</button>
    <wa-popup anchor="arrow-placement-anchor" arrow arrow-placement="start" distance="8" active>
      <div class="popup-content">Arrow aligned to start</div>
    </wa-popup>
  </div>

  <!-- Arrow with custom styling -->
  <div class="example">
    <button id="styled-arrow-anchor">Styled Arrow</button>
    <wa-popup 
      anchor="styled-arrow-anchor" 
      arrow 
      distance="8" 
      active
      style="--arrow-color: #ff5722; --arrow-size: 12px;"
    >
      <div class="popup-content">Custom arrow color and size</div>
    </wa-popup>
  </div>
</div>
```

## Flip

When the popup doesn't have enough room in its preferred placement, it can automatically flip to keep it in view and visually connected to its anchor. To enable this, use the `flip` attribute. By default, the popup will flip to the opposite placement, but you can configure preferred fallback placements using `flip-fallback-placement` and `flip-fallback-strategy`.

```html
<div class="flip-examples" style="overflow: auto; height: 300px; padding: 100px 20px;">
  <p>Scroll the container to see how the popup flips to prevent clipping.</p>
  
  <div class="example" style="margin-bottom: 200px;">
    <button id="flip-anchor">Flip Enabled</button>
    <wa-popup anchor="flip-anchor" placement="bottom" flip active>
      <div class="popup-content">
        This popup will flip to the top when there's not enough room at the bottom.
      </div>
    </wa-popup>
  </div>
  
  <div class="example">
    <button id="no-flip-anchor">No Flip</button>
    <wa-popup anchor="no-flip-anchor" placement="bottom" active>
      <div class="popup-content">
        This popup won't flip and might get clipped.
      </div>
    </wa-popup>
  </div>
</div>
```

## Flip Fallbacks

While using the `flip` attribute, you can customize the placement of the popup when the preferred placement doesn't have room. For this, use `flip-fallback-placements` and `flip-fallback-strategy`.

```html
<div class="flip-fallback-examples" style="overflow: auto; height: 300px; padding: 100px 20px;">
  <p>Scroll the container to see how the popup changes its fallback placement to prevent clipping.</p>
  
  <div class="example" style="margin-bottom: 200px;">
    <button id="fallback-anchor">With Fallbacks</button>
    <wa-popup 
      anchor="fallback-anchor" 
      placement="bottom" 
      flip 
      flip-fallback-placements="right left top-start" 
      flip-fallback-strategy="best-fit"
      active
    >
      <div class="popup-content">
        This popup will try different placements in this order: bottom, right, left, top-start.
      </div>
    </wa-popup>
  </div>
</div>
```

## Shift

When a popup is longer than its anchor, it risks overflowing. In this case, use the `shift` attribute to shift the popup along its axis and back into view. You can customize the shift behavior using `shift-boundary` and `shift-padding`.

```html
<div class="shift-examples" style="overflow: auto; width: 300px;">
  <p>Toggle the switch to see the difference.</p>
  
  <div class="example">
    <button id="shift-anchor" style="margin-left: 5px;">Shift Enabled</button>
    <wa-popup anchor="shift-anchor" placement="bottom" shift active>
      <div class="popup-content" style="width: 200px;">
        This popup will shift to stay in view even though it's wider than its anchor.
      </div>
    </wa-popup>
  </div>
  
  <div class="example">
    <button id="no-shift-anchor" style="margin-left: 5px;">No Shift</button>
    <wa-popup anchor="no-shift-anchor" placement="bottom" active>
      <div class="popup-content" style="width: 200px;">
        This popup might overflow the container because shift is disabled.
      </div>
    </wa-popup>
  </div>
</div>
```

## Auto-size

Use the `auto-size` attribute to tell the popup to resize when necessary to prevent it from overflowing. Possible values are `horizontal`, `vertical`, and `both`. You can use `auto-size-boundary` and `auto-size-padding` to customize the behavior of this option.

```html
<div class="auto-size-examples" style="overflow: auto; width: 300px; height: 300px;">
  <p>Scroll the container to see the popup resize as its available space changes.</p>
  
  <div class="example">
    <button id="auto-size-anchor" style="margin: 50px;">Auto-size</button>
    <wa-popup anchor="auto-size-anchor" placement="bottom" auto-size="both" active>
      <div class="popup-content" style="max-width: var(--auto-size-available-width); max-height: var(--auto-size-available-height);">
        This popup will automatically resize to fit within the available space. It contains a lot of content that would normally cause overflow, but the auto-size attribute prevents that from happening.
      </div>
    </wa-popup>
  </div>
</div>
```

## Hover Bridge

When a gap exists between the anchor and the popup element, this option will add a "hover bridge" that fills the gap using an invisible element. This makes listening for events such as mouseover and mouseout more sane because the pointer never technically leaves the element.

```html
<div class="hover-bridge-examples">
  <div class="example">
    <button id="hover-bridge-anchor">With Hover Bridge</button>
    <wa-popup 
      anchor="hover-bridge-anchor" 
      placement="bottom" 
      distance="15" 
      hover-bridge 
      active
    >
      <div class="popup-content">
        This popup has a hover bridge, making it easier to move the mouse between the anchor and the popup without the popup disappearing.
      </div>
    </wa-popup>
  </div>
  
  <div class="example">
    <button id="no-hover-bridge-anchor">Without Hover Bridge</button>
    <wa-popup 
      anchor="no-hover-bridge-anchor" 
      placement="bottom" 
      distance="15" 
      active
    >
      <div class="popup-content">
        This popup doesn't have a hover bridge, so moving the mouse between the anchor and popup might cause the popup to hide.
      </div>
    </wa-popup>
  </div>
</div>
```

## Virtual Elements

In most cases, popups are anchored to an actual element. Sometimes, it can be useful to anchor them to a non-element. To do this, you can pass a VirtualElement to the anchor property. A virtual element must contain a function called getBoundingClientRect() that returns a DOMRect object.

```javascript
// Example of creating a virtual element that follows the mouse cursor
const virtualElement = {
  getBoundingClientRect() {
    return {
      width: 0,
      height: 0,
      x: mouseX,
      y: mouseY,
      top: mouseY,
      left: mouseX,
      right: mouseX,
      bottom: mouseY
    };
  }
};

// Then use it with the popup
const popup = document.querySelector('wa-popup');
popup.anchor = virtualElement;
```

## Event Handling

```typescript
import { Component, ViewChild, ElementRef, AfterViewInit } from '@angular/core';
import { WaPopupDirective } from '@angular-awesome/directives/popup';

@Component({
  selector: 'app-popup-events-demo',
  template: `
    <button #eventAnchor>Click for Events</button>
    <wa-popup 
      #eventPopup
      [anchor]="eventAnchor"
      (waReposition)="onReposition($event)"
    >
      <div class="popup-content">
        This popup triggers events when repositioned.
      </div>
    </wa-popup>
    
    <div class="event-log">
      <p>Repositioned: {{ repositionCount }} times</p>
      <button (click)="togglePopup()">Toggle Popup</button>
    </div>
  `,
  standalone: true,
  imports: [WaPopupDirective]
})
export class PopupEventsDemoComponent implements AfterViewInit {
  @ViewChild('eventPopup') popup!: ElementRef;
  @ViewChild('eventAnchor') anchor!: ElementRef;
  
  repositionCount = 0;
  
  ngAfterViewInit() {
    // Initial setup
  }
  
  togglePopup() {
    const popupEl = this.popup.nativeElement;
    popupEl.active = !popupEl.active;
  }
  
  onReposition(event: CustomEvent) {
    this.repositionCount++;
    console.log('Popup repositioned');
  }
}
```

## Combining Features

```html
<div class="combined-examples">
  <button id="combined-anchor">Advanced Popup</button>
  <wa-popup 
    anchor="combined-anchor"
    placement="bottom"
    arrow
    arrow-placement="center"
    distance="10"
    flip
    shift
    auto-size="both"
    hover-bridge
    active
    style="--arrow-color: #3f51b5;"
  >
    <div class="popup-content">
      <h3>Fully Featured Popup</h3>
      <p>This popup combines multiple features:</p>
      <ul>
        <li>Custom placement</li>
        <li>Arrow with custom color</li>
        <li>Distance from anchor</li>
        <li>Flip to stay in view</li>
        <li>Shift to prevent overflow</li>
        <li>Auto-size to fit available space</li>
        <li>Hover bridge for better mouse interaction</li>
      </ul>
    </div>
  </wa-popup>
</div>
```