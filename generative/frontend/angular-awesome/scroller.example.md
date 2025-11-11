# Scroller Examples

## Basic Usage

```html
<wa-scroller-wrapper>
  <div style="width: 800px; padding: 20px;">
    This content will be scrollable if it exceeds the container width.
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  </div>
</wa-scroller-wrapper>
```

## Vertical Scrolling

```html
<wa-scroller-wrapper orientation="vertical" style="height: 200px;">
  <div style="padding: 20px;">
    <p>This content will scroll vertically when it exceeds the container height.</p>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
    <p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.</p>
    <p>Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.</p>
    <p>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia.</p>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
    <p>Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.</p>
  </div>
</wa-scroller-wrapper>
```

## Horizontal Scrolling

```html
<wa-scroller-wrapper orientation="horizontal">
  <div style="display: flex; gap: 20px; padding: 20px;">
    <div style="min-width: 200px; height: 150px; background-color: #f0f0f0; display: flex; align-items: center; justify-content: center;">
      Card 1
    </div>
    <div style="min-width: 200px; height: 150px; background-color: #f0f0f0; display: flex; align-items: center; justify-content: center;">
      Card 2
    </div>
    <div style="min-width: 200px; height: 150px; background-color: #f0f0f0; display: flex; align-items: center; justify-content: center;">
      Card 3
    </div>
    <div style="min-width: 200px; height: 150px; background-color: #f0f0f0; display: flex; align-items: center; justify-content: center;">
      Card 4
    </div>
    <div style="min-width: 200px; height: 150px; background-color: #f0f0f0; display: flex; align-items: center; justify-content: center;">
      Card 5
    </div>
  </div>
</wa-scroller-wrapper>
```

## Without Scrollbar

```html
<wa-scroller-wrapper [withoutScrollbar]="true">
  <div style="width: 800px; padding: 20px;">
    This content will be scrollable but without a visible scrollbar.
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  </div>
</wa-scroller-wrapper>
```

## Without Shadow

```html
<wa-scroller-wrapper [withoutShadow]="true">
  <div style="width: 800px; padding: 20px;">
    This content will be scrollable but without the shadow indicators at the edges.
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  </div>
</wa-scroller-wrapper>
```

## Custom Shadow Styling

```html
<wa-scroller-wrapper 
  [shadowColor]="'rgba(0, 0, 255, 0.3)'" 
  [shadowSize]="'30px'">
  <div style="width: 800px; padding: 20px;">
    This content has custom shadow color and size.
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
  </div>
</wa-scroller-wrapper>
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-scroller-demo',
  template: `
    <div class="controls">
      <wa-select [(ngModel)]="scrollerOrientation" label="Orientation">
        <wa-option value="horizontal">Horizontal</wa-option>
        <wa-option value="vertical">Vertical</wa-option>
      </wa-select>
      
      <wa-checkbox [(ngModel)]="hideScrollbar" label="Hide Scrollbar"></wa-checkbox>
      <wa-checkbox [(ngModel)]="hideShadow" label="Hide Shadow"></wa-checkbox>
    </div>
    
    <wa-scroller-wrapper 
      [orientation]="scrollerOrientation" 
      [withoutScrollbar]="hideScrollbar" 
      [withoutShadow]="hideShadow"
      [shadowColor]="shadowColor"
      [shadowSize]="shadowSize"
      [style.height]="scrollerOrientation === 'vertical' ? '200px' : 'auto'">
      
      <div [style.width]="scrollerOrientation === 'horizontal' ? '1000px' : 'auto'" 
           [style.padding]="'20px'">
        <ng-container *ngIf="scrollerOrientation === 'horizontal'">
          <div style="display: flex; gap: 20px;">
            <div *ngFor="let item of items" 
                 style="min-width: 200px; height: 150px; background-color: #f0f0f0; 
                        display: flex; align-items: center; justify-content: center;">
              {{ item }}
            </div>
          </div>
        </ng-container>
        
        <ng-container *ngIf="scrollerOrientation === 'vertical'">
          <p *ngFor="let item of items">
            Item {{ item }} - Lorem ipsum dolor sit amet, consectetur adipiscing elit.
          </p>
        </ng-container>
      </div>
      
    </wa-scroller-wrapper>
  `
})
export class ScrollerDemoComponent {
  scrollerOrientation = 'horizontal';
  hideScrollbar = false;
  hideShadow = false;
  shadowColor = 'rgba(0, 0, 0, 0.2)';
  shadowSize = '20px';
  items = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
}
```

## Real-World Example: Image Gallery

```html
<div class="image-gallery">
  <h2>Photo Gallery</h2>
  
  <wa-scroller-wrapper 
    orientation="horizontal" 
    [shadowColor]="'rgba(0, 0, 0, 0.3)'" 
    [shadowSize]="'40px'">
    <div class="gallery-container">
      <div class="gallery-item" *ngFor="let image of galleryImages">
        <img [src]="image.url" [alt]="image.caption">
        <div class="caption">{{ image.caption }}</div>
      </div>
    </div>
  </wa-scroller-wrapper>
</div>

<style>
  .image-gallery {
    max-width: 100%;
    margin: 0 auto;
  }
  
  .gallery-container {
    display: flex;
    gap: 16px;
    padding: 20px;
  }
  
  .gallery-item {
    min-width: 280px;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  }
  
  .gallery-item img {
    width: 100%;
    height: 200px;
    object-fit: cover;
  }
  
  .caption {
    padding: 12px;
    background-color: #f8f9fa;
    font-size: 14px;
  }
</style>
```

## Real-World Example: Content Tabs with Horizontal Scrolling

```html
<div class="scrollable-tabs">
  <wa-scroller-wrapper 
    orientation="horizontal" 
    [withoutScrollbar]="true">
    <div class="tabs-container">
      <button 
        class="tab-button" 
        *ngFor="let tab of tabs" 
        [class.active]="activeTab === tab.id"
        (click)="activeTab = tab.id">
        {{ tab.label }}
      </button>
    </div>
  </wa-scroller-wrapper>
  
  <div class="tab-content">
    <ng-container *ngFor="let tab of tabs">
      <div *ngIf="activeTab === tab.id">
        <h3>{{ tab.label }}</h3>
        <p>{{ tab.content }}</p>
      </div>
    </ng-container>
  </div>
</div>

<style>
  .scrollable-tabs {
    width: 100%;
    margin-bottom: 20px;
  }
  
  .tabs-container {
    display: flex;
    gap: 8px;
    padding: 8px;
    min-width: max-content;
  }
  
  .tab-button {
    padding: 8px 16px;
    border: none;
    background-color: #f0f0f0;
    border-radius: 4px;
    cursor: pointer;
    white-space: nowrap;
  }
  
  .tab-button.active {
    background-color: #007bff;
    color: white;
  }
  
  .tab-content {
    padding: 16px;
    border: 1px solid #e0e0e0;
    border-radius: 4px;
    margin-top: 8px;
  }
</style>
```

## Real-World Example: Timeline

```html
<div class="timeline-container">
  <h2>Project Timeline</h2>
  
  <wa-scroller-wrapper 
    orientation="horizontal" 
    [shadowSize]="'50px'">
    <div class="timeline">
      <div class="timeline-item" *ngFor="let event of timelineEvents">
        <div class="timeline-date">{{ event.date }}</div>
        <div class="timeline-connector"></div>
        <div class="timeline-content">
          <h3>{{ event.title }}</h3>
          <p>{{ event.description }}</p>
        </div>
      </div>
    </div>
  </wa-scroller-wrapper>
</div>

<style>
  .timeline-container {
    margin: 40px 0;
  }
  
  .timeline {
    display: flex;
    padding: 40px 20px;
    min-width: max-content;
  }
  
  .timeline-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    min-width: 200px;
    position: relative;
  }
  
  .timeline-date {
    font-weight: bold;
    margin-bottom: 10px;
  }
  
  .timeline-connector {
    width: 100%;
    height: 4px;
    background-color: #e0e0e0;
    position: relative;
    margin-bottom: 20px;
  }
  
  .timeline-connector::before {
    content: '';
    position: absolute;
    width: 12px;
    height: 12px;
    background-color: #007bff;
    border-radius: 50%;
    top: -4px;
    left: 50%;
    transform: translateX(-50%);
  }
  
  .timeline-content {
    text-align: center;
    padding: 15px;
    background-color: #f8f9fa;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    width: 180px;
  }
  
  .timeline-content h3 {
    margin-top: 0;
    font-size: 16px;
  }
  
  .timeline-content p {
    margin-bottom: 0;
    font-size: 14px;
  }
</style>
```
