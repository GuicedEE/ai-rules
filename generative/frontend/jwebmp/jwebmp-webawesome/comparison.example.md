# Comparison Examples

## Basic Usage

```html
<wa-comparison>
  <img slot="before" src="/assets/image-before.jpg" alt="Before" />
  <img slot="after" src="/assets/image-after.jpg" alt="After" />
</wa-comparison>
```

## With Initial Position

```html
<wa-comparison position="25">
  <img slot="before" src="/assets/image-before.jpg" alt="Before" />
  <img slot="after" src="/assets/image-after.jpg" alt="After" />
</wa-comparison>

<wa-comparison position="75">
  <img slot="before" src="/assets/image-before.jpg" alt="Before" />
  <img slot="after" src="/assets/image-after.jpg" alt="After" />
</wa-comparison>
```

## With Custom Handle

```html
<wa-comparison position="50">
  <img slot="before" src="/assets/image-before.jpg" alt="Before" />
  <img slot="after" src="/assets/image-after.jpg" alt="After" />
  <wa-icon slot="handle" name="arrows-left-right" variant="solid"></wa-icon>
</wa-comparison>
```

## Event Handling

```html
<wa-comparison (change)="onPositionChange($event)">
  <img slot="before" src="/assets/image-before.jpg" alt="Before" />
  <img slot="after" src="/assets/image-after.jpg" alt="After" />
</wa-comparison>
```

```typescript
// In your component
onPositionChange(position: number): void {
  console.log(`Divider position: ${position}%`);
}
```

## Custom Styling

```html
<style>
  .custom-comparison {
    --divider-color: #ff5722;
    --divider-width: 3px;
    --handle-color: #ff5722;
    --handle-size: 32px;
  }
</style>

<wa-comparison class="custom-comparison">
  <img slot="before" src="/assets/image-before.jpg" alt="Before" />
  <img slot="after" src="/assets/image-after.jpg" alt="After" />
</wa-comparison>
```

## With Labels

```html
<wa-comparison>
  <div slot="before">
    <img src="/assets/image-before.jpg" alt="Before" />
    <div class="label">Before</div>
  </div>
  <div slot="after">
    <img src="/assets/image-after.jpg" alt="After" />
    <div class="label">After</div>
  </div>
</wa-comparison>
```

## Using with Angular Bindings

```html
<wa-comparison 
  [position]="sliderPosition" 
  (change)="updatePosition($event)">
  <img slot="before" [src]="beforeImage" alt="Before" />
  <img slot="after" [src]="afterImage" alt="After" />
  <ng-container *ngIf="showCustomHandle">
    <wa-icon slot="handle" [name]="handleIcon"></wa-icon>
  </ng-container>
</wa-comparison>
```

```typescript
// In your component
export class ComparisonDemoComponent {
  sliderPosition = 50;
  beforeImage = '/assets/image-before.jpg';
  afterImage = '/assets/image-after.jpg';
  showCustomHandle = true;
  handleIcon = 'arrows-left-right';

  updatePosition(position: number): void {
    this.sliderPosition = position;
  }
}
```

## Responsive Example

```html
<div class="responsive-container">
  <wa-comparison>
    <img slot="before" src="/assets/image-before.jpg" alt="Before" />
    <img slot="after" src="/assets/image-after.jpg" alt="After" />
  </wa-comparison>
</div>

<style>
  .responsive-container {
    width: 100%;
    max-width: 800px;
    margin: 0 auto;
  }
  
  .responsive-container img {
    width: 100%;
    height: auto;
    display: block;
  }
</style>
```

## Common Use Cases

```html
<!-- Before/After Photo Editing -->
<wa-comparison>
  <img slot="before" src="/assets/photo-original.jpg" alt="Original Photo" />
  <img slot="after" src="/assets/photo-edited.jpg" alt="Edited Photo" />
</wa-comparison>

<!-- Product Comparison -->
<wa-comparison>
  <div slot="before">
    <img src="/assets/product-a.jpg" alt="Product A" />
    <div class="product-info">
      <h3>Product A</h3>
      <p>$99.99</p>
      <ul>
        <li>Feature 1</li>
        <li>Feature 2</li>
      </ul>
    </div>
  </div>
  <div slot="after">
    <img src="/assets/product-b.jpg" alt="Product B" />
    <div class="product-info">
      <h3>Product B</h3>
      <p>$149.99</p>
      <ul>
        <li>Feature 1</li>
        <li>Feature 2</li>
        <li>Feature 3</li>
      </ul>
    </div>
  </div>
</wa-comparison>

<!-- Map Comparison -->
<wa-comparison>
  <img slot="before" src="/assets/map-1990.jpg" alt="Map 1990" />
  <img slot="after" src="/assets/map-2020.jpg" alt="Map 2020" />
  <div slot="handle" class="year-handle">
    <span class="year">1990</span>
    <wa-icon name="arrows-left-right"></wa-icon>
    <span class="year">2020</span>
  </div>
</wa-comparison>
```
