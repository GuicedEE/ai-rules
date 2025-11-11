# Tooltip Examples

## Basic Usage

```html
<button id="tooltip-target">Hover me</button>
<wa-tooltip for="tooltip-target">This is a tooltip</wa-tooltip>
```

## Different Placements

```html
<!-- Top placement (default) -->
<button id="tooltip-top">Top</button>
<wa-tooltip for="tooltip-top" placement="top">Tooltip on top</wa-tooltip>

<!-- Right placement -->
<button id="tooltip-right">Right</button>
<wa-tooltip for="tooltip-right" placement="right">Tooltip on right</wa-tooltip>

<!-- Bottom placement -->
<button id="tooltip-bottom">Bottom</button>
<wa-tooltip for="tooltip-bottom" placement="bottom">Tooltip on bottom</wa-tooltip>

<!-- Left placement -->
<button id="tooltip-left">Left</button>
<wa-tooltip for="tooltip-left" placement="left">Tooltip on left</wa-tooltip>
```

## Custom Distance and Skidding

```html
<!-- Custom distance from target -->
<button id="tooltip-distance">Distance</button>
<wa-tooltip for="tooltip-distance" [distance]="16">16px away from target</wa-tooltip>

<!-- Custom skidding (offset along the target) -->
<button id="tooltip-skidding">Skidding</button>
<wa-tooltip for="tooltip-skidding" [skidding]="10">Offset 10px along the target</wa-tooltip>

<!-- Combined distance and skidding -->
<button id="tooltip-combined">Combined</button>
<wa-tooltip for="tooltip-combined" [distance]="20" [skidding]="-15">Custom positioning</wa-tooltip>
```

## Disabled Tooltip

```html
<button id="tooltip-disabled">No tooltip</button>
<wa-tooltip for="tooltip-disabled" [disabled]="true">This tooltip won't show</wa-tooltip>
```

## Open State Control

```html
<!-- Programmatically controlled tooltip -->
<button id="tooltip-open">Always visible</button>
<wa-tooltip for="tooltip-open" [open]="true">This tooltip is always visible</wa-tooltip>
```

## Custom Delays

```html
<!-- Custom show delay -->
<button id="tooltip-show-delay">Slow to appear</button>
<wa-tooltip for="tooltip-show-delay" [showDelay]="500">Appears after 500ms</wa-tooltip>

<!-- Custom hide delay -->
<button id="tooltip-hide-delay">Slow to disappear</button>
<wa-tooltip for="tooltip-hide-delay" [hideDelay]="1000">Disappears after 1000ms</wa-tooltip>
```

## Custom Triggers

```html
<!-- Hover trigger only -->
<button id="tooltip-hover">Hover only</button>
<wa-tooltip for="tooltip-hover" trigger="hover">Shows on hover only</wa-tooltip>

<!-- Focus trigger only -->
<button id="tooltip-focus" tabindex="0">Focus only</button>
<wa-tooltip for="tooltip-focus" trigger="focus">Shows on focus only</wa-tooltip>

<!-- Click trigger -->
<button id="tooltip-click">Click me</button>
<wa-tooltip for="tooltip-click" trigger="click">Shows on click</wa-tooltip>

<!-- Manual trigger -->
<button id="tooltip-manual">Manual</button>
<wa-tooltip for="tooltip-manual" trigger="manual" [open]="isTooltipOpen">Manually controlled</wa-tooltip>
```

## Custom Styling

```html
<!-- Custom background color -->
<button id="tooltip-bg">Custom background</button>
<wa-tooltip for="tooltip-bg" [backgroundColor]="'#3f51b5'">Blue background</wa-tooltip>

<!-- Custom border radius -->
<button id="tooltip-radius">Custom radius</button>
<wa-tooltip for="tooltip-radius" [borderRadius]="'0'">Square tooltip</wa-tooltip>

<!-- Custom max width -->
<button id="tooltip-width">Custom width</button>
<wa-tooltip for="tooltip-width" [maxWidth]="'300px'">This tooltip can be up to 300px wide, which is useful for longer content that would otherwise be truncated.</wa-tooltip>

<!-- Custom padding -->
<button id="tooltip-padding">Custom padding</button>
<wa-tooltip for="tooltip-padding" [padding]="'16px'">More spacious tooltip</wa-tooltip>

<!-- Custom arrow size -->
<button id="tooltip-arrow">Custom arrow</button>
<wa-tooltip for="tooltip-arrow" [arrowSize]="'12px'">Tooltip with larger arrow</wa-tooltip>

<!-- Combined custom styling -->
<button id="tooltip-custom">Fully customized</button>
<wa-tooltip 
  for="tooltip-custom" 
  [backgroundColor]="'#212121'" 
  [borderRadius]="'8px'" 
  [maxWidth]="'250px'" 
  [padding]="'12px'" 
  [arrowSize]="'8px'"
>
  A fully customized tooltip with dark background, rounded corners, custom width, padding, and arrow size.
</wa-tooltip>
```

## Event Handling

```typescript
import { Component } from '@angular/core';
import { WaTooltipDirective } from '@angular-awesome/directives/tooltip';

@Component({
  selector: 'app-tooltip-events-demo',
  template: `
    <button id="tooltip-events">Hover for events</button>
    <wa-tooltip 
      for="tooltip-events"
      (waShow)="onShow($event)"
      (waAfterShow)="onAfterShow($event)"
      (waHide)="onHide($event)"
      (waAfterHide)="onAfterHide($event)"
    >
      This tooltip triggers events
    </wa-tooltip>
    
    <div class="event-log">
      <p>Last event: {{ lastEvent }}</p>
    </div>
  `,
  standalone: true,
  imports: [WaTooltipDirective]
})
export class TooltipEventsDemoComponent {
  lastEvent = 'None';
  
  onShow(event: CustomEvent) {
    this.lastEvent = 'Show started';
    console.log('Tooltip show started');
  }
  
  onAfterShow(event: CustomEvent) {
    this.lastEvent = 'Show completed';
    console.log('Tooltip show completed');
  }
  
  onHide(event: CustomEvent) {
    this.lastEvent = 'Hide started';
    console.log('Tooltip hide started');
  }
  
  onAfterHide(event: CustomEvent) {
    this.lastEvent = 'Hide completed';
    console.log('Tooltip hide completed');
  }
}
```

## Dynamic Content

```typescript
import { Component } from '@angular/core';
import { WaTooltipDirective } from '@angular-awesome/directives/tooltip';

@Component({
  selector: 'app-dynamic-tooltip-demo',
  template: `
    <div class="user-list">
      <div 
        *ngFor="let user of users; let i = index" 
        class="user-item"
        [id]="'user-' + i"
      >
        {{ user.name }}
      </div>
      
      <wa-tooltip 
        *ngFor="let user of users; let i = index"
        [for]="'user-' + i"
      >
        <div class="user-tooltip">
          <h3>{{ user.name }}</h3>
          <p>Email: {{ user.email }}</p>
          <p>Role: {{ user.role }}</p>
        </div>
      </wa-tooltip>
    </div>
  `,
  standalone: true,
  imports: [WaTooltipDirective]
})
export class DynamicTooltipDemoComponent {
  users = [
    { name: 'John Doe', email: 'john@example.com', role: 'Admin' },
    { name: 'Jane Smith', email: 'jane@example.com', role: 'Editor' },
    { name: 'Bob Johnson', email: 'bob@example.com', role: 'Viewer' }
  ];
}
```
