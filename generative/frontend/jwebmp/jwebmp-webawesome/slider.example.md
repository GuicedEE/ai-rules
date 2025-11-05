# Slider Examples

## Basic Usage

```html
<wa-slider label="Basic Slider"></wa-slider>
```

## Min, Max, and Step Values

```html
<wa-slider 
  label="Custom Range" 
  [min]="0" 
  [max]="100" 
  [step]="5">
</wa-slider>

<wa-slider 
  label="Percentage" 
  [min]="0" 
  [max]="100" 
  [step]="1">
</wa-slider>

<wa-slider 
  label="Temperature" 
  [min]="-20" 
  [max]="40" 
  [step]="0.5">
</wa-slider>

<wa-slider 
  label="Fine Control" 
  [min]="0" 
  [max]="1" 
  [step]="0.01">
</wa-slider>
```

## Tooltip Options

```html
<!-- Tooltip on top (default) -->
<wa-slider 
  label="Tooltip on Top" 
  tooltip="top">
</wa-slider>

<!-- Tooltip on bottom -->
<wa-slider 
  label="Tooltip on Bottom" 
  tooltip="bottom">
</wa-slider>

<!-- No tooltip -->
<wa-slider 
  label="No Tooltip" 
  tooltip="none">
</wa-slider>
```

## With Hint

```html
<wa-slider 
  label="Volume" 
  hint="Adjust the volume level"
  [min]="0" 
  [max]="100">
</wa-slider>

<!-- Using HTML in hint -->
<wa-slider label="Brightness">
  <div slot="hint">
    Adjust the <strong>brightness</strong> level
  </div>
</wa-slider>
```

## Disabled State

```html
<wa-slider 
  label="Disabled Slider" 
  [disabled]="true" 
  [min]="0" 
  [max]="100" 
  [value]="50">
</wa-slider>
```

## Custom Styling

```html
<!-- Custom track colors -->
<wa-slider 
  label="Custom Track Colors" 
  [trackColorActive]="'#4caf50'" 
  [trackColorInactive]="'#e0e0e0'">
</wa-slider>

<!-- Custom track height -->
<wa-slider 
  label="Custom Track Height" 
  [trackHeight]="'6px'">
</wa-slider>

<!-- Custom thumb styling -->
<wa-slider 
  label="Custom Thumb" 
  [thumbColor]="'#2196f3'" 
  [thumbSize]="'20px'" 
  [thumbShadow]="'0 0 5px rgba(33, 150, 243, 0.5)'">
</wa-slider>

<!-- Custom thumb gap -->
<wa-slider 
  label="Custom Thumb Gap" 
  [thumbGap]="'2px'">
</wa-slider>

<!-- Custom tooltip offset -->
<wa-slider 
  label="Custom Tooltip Offset" 
  [tooltipOffset]="'10px'">
</wa-slider>

<!-- Combined custom styling -->
<wa-slider 
  label="Fully Customized Slider" 
  [trackColorActive]="'#ff4081'" 
  [trackColorInactive]="'#f8bbd0'" 
  [trackHeight]="'8px'" 
  [thumbColor]="'#c2185b'" 
  [thumbSize]="'24px'" 
  [thumbShadow]="'0 0 8px rgba(194, 24, 91, 0.5)'" 
  [tooltipOffset]="'12px'">
</wa-slider>
```

## Event Handling

```html
<wa-slider 
  label="Interactive Slider" 
  (inputEvent)="onSliderInput($event)" 
  (changeEvent)="onSliderChange($event)" 
  (focusEvent)="onSliderFocus()" 
  (blurEvent)="onSliderBlur()"
  (invalidEvent)="onSliderInvalid($event)">
</wa-slider>
```

```typescript
// In your component
onSliderInput(event: Event): void {
  const value = (event.target as HTMLInputElement).value;
  console.log('Slider input:', value);
}

onSliderChange(event: Event): void {
  const value = (event.target as HTMLInputElement).value;
  console.log('Slider change:', value);
}

onSliderFocus(): void {
  console.log('Slider focused');
}

onSliderBlur(): void {
  console.log('Slider blurred');
}

onSliderInvalid(event: CustomEvent): void {
  console.log('Slider invalid:', event.detail);
}
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-slider-demo',
  template: `
    <wa-slider 
      [label]="sliderLabel" 
      [min]="sliderMin" 
      [max]="sliderMax" 
      [step]="sliderStep" 
      [value]="sliderValue" 
      [disabled]="isDisabled"
      [tooltip]="tooltipPosition"
      [trackColorActive]="trackColor"
      (inputEvent)="onSliderInput($event)">
    </wa-slider>
    
    <div>Current value: {{ sliderValue }}</div>
    
    <div class="controls">
      <button (click)="isDisabled = !isDisabled">
        {{ isDisabled ? 'Enable' : 'Disable' }} Slider
      </button>
      
      <wa-select [(ngModel)]="tooltipPosition" label="Tooltip Position">
        <wa-option value="top">Top</wa-option>
        <wa-option value="bottom">Bottom</wa-option>
        <wa-option value="none">None</wa-option>
      </wa-select>
      
      <wa-input 
        type="color" 
        [(ngModel)]="trackColor" 
        label="Track Color">
      </wa-input>
    </div>
  `
})
export class SliderDemoComponent {
  sliderLabel = 'Customizable Slider';
  sliderMin = 0;
  sliderMax = 100;
  sliderStep = 1;
  sliderValue = 50;
  isDisabled = false;
  tooltipPosition = 'top';
  trackColor = '#2196f3';
  
  onSliderInput(event: Event): void {
    this.sliderValue = parseFloat((event.target as HTMLInputElement).value);
  }
}
```

## Using with ngModel

```html
<form #sliderForm="ngForm">
  <wa-slider 
    label="Volume" 
    name="volume" 
    [(ngModel)]="volumeLevel" 
    [min]="0" 
    [max]="100" 
    [step]="1">
  </wa-slider>
  
  <div>Current volume: {{ volumeLevel }}%</div>
</form>
```

## Real-World Example: Image Editor Controls

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-image-editor',
  template: `
    <div class="image-editor">
      <h2>Image Editor</h2>
      
      <div class="editor-container">
        <div class="controls-panel">
          <wa-slider 
            label="Brightness" 
            [min]="-100" 
            [max]="100" 
            [step]="1" 
            [(ngModel)]="brightness"
            (inputEvent)="updateImage()">
          </wa-slider>
          
          <wa-slider 
            label="Contrast" 
            [min]="-100" 
            [max]="100" 
            [step]="1" 
            [(ngModel)]="contrast"
            (inputEvent)="updateImage()">
          </wa-slider>
          
          <wa-slider 
            label="Saturation" 
            [min]="-100" 
            [max]="100" 
            [step]="1" 
            [(ngModel)]="saturation"
            (inputEvent)="updateImage()">
          </wa-slider>
          
          <wa-slider 
            label="Blur" 
            [min]="0" 
            [max]="20" 
            [step]="0.1" 
            [(ngModel)]="blur"
            (inputEvent)="updateImage()">
          </wa-slider>
          
          <wa-slider 
            label="Hue Rotate" 
            [min]="0" 
            [max]="360" 
            [step]="1" 
            [(ngModel)]="hueRotate"
            (inputEvent)="updateImage()">
          </wa-slider>
          
          <button (click)="resetFilters()">Reset All</button>
        </div>
        
        <div class="image-preview">
          <img 
            [src]="imageUrl" 
            [style.filter]="getFilterString()" 
            alt="Edited image">
        </div>
      </div>
    </div>
  `,
  styles: [`
    .image-editor {
      padding: 20px;
    }
    
    .editor-container {
      display: flex;
      gap: 20px;
      margin-top: 20px;
    }
    
    .controls-panel {
      width: 300px;
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    
    .image-preview {
      flex: 1;
      display: flex;
      justify-content: center;
      align-items: center;
      background-color: #f0f0f0;
      border-radius: 8px;
      overflow: hidden;
    }
    
    .image-preview img {
      max-width: 100%;
      max-height: 500px;
    }
  `]
})
export class ImageEditorComponent {
  imageUrl = 'assets/sample-image.jpg';
  brightness = 0;
  contrast = 0;
  saturation = 0;
  blur = 0;
  hueRotate = 0;
  
  updateImage(): void {
    // The image updates automatically via the style binding
    console.log('Image filters updated');
  }
  
  resetFilters(): void {
    this.brightness = 0;
    this.contrast = 0;
    this.saturation = 0;
    this.blur = 0;
    this.hueRotate = 0;
    this.updateImage();
  }
  
  getFilterString(): string {
    return `
      brightness(${100 + this.brightness}%) 
      contrast(${100 + this.contrast}%) 
      saturate(${100 + this.saturation}%) 
      blur(${this.blur}px) 
      hue-rotate(${this.hueRotate}deg)
    `;
  }
}
```

## Multiple Sliders for Range Selection

```html
<div class="price-range">
  <h3>Price Range</h3>
  
  <div class="slider-container">
    <wa-slider 
      label="Minimum Price" 
      [min]="0" 
      [max]="1000" 
      [step]="10" 
      [(ngModel)]="minPrice"
      (changeEvent)="updatePriceRange()">
    </wa-slider>
    
    <wa-slider 
      label="Maximum Price" 
      [min]="0" 
      [max]="1000" 
      [step]="10" 
      [(ngModel)]="maxPrice"
      (changeEvent)="updatePriceRange()">
    </wa-slider>
  </div>
  
  <div class="selected-range">
    Selected range: ${{ minPrice }} - ${{ maxPrice }}
  </div>
</div>
```

```typescript
// In your component
minPrice = 200;
maxPrice = 800;

updatePriceRange(): void {
  // Ensure min doesn't exceed max
  if (this.minPrice > this.maxPrice) {
    this.minPrice = this.maxPrice;
  }
  
  // Filter products or perform other actions based on the price range
  console.log(`Price range updated: $${this.minPrice} - $${this.maxPrice}`);
}
```

## Slider with Custom Labels

```html
<wa-slider 
  [min]="0" 
  [max]="3" 
  [step]="1" 
  [(ngModel)]="qualityLevel">
  <div slot="label">
    Quality: 
    <strong>
      {{ ['Low', 'Medium', 'High', 'Ultra'][qualityLevel] }}
    </strong>
  </div>
</wa-slider>
```

```typescript
// In your component
qualityLevel = 1; // Default to Medium
```
