# Rating Examples

## Basic Usage

```html
<wa-rating label="Rate this item"></wa-rating>
```

## With Different Values

```html
<wa-rating label="Default Rating" value="3"></wa-rating>
<wa-rating label="Half Star Rating" value="3.5" precision="0.5"></wa-rating>
<wa-rating label="Low Rating" value="1"></wa-rating>
<wa-rating label="High Rating" value="5"></wa-rating>
```

## Different Sizes

```html
<wa-rating label="Small Rating" size="small"></wa-rating>
<wa-rating label="Medium Rating" size="medium"></wa-rating>
<wa-rating label="Large Rating" size="large"></wa-rating>
```

## Readonly and Disabled States

```html
<!-- Readonly rating - can't be changed but looks active -->
<wa-rating label="Readonly Rating" value="4" readonly></wa-rating>

<!-- Disabled rating - visually shows as disabled -->
<wa-rating label="Disabled Rating" value="3" disabled></wa-rating>
```

## Custom Maximum Value

```html
<wa-rating label="Rate out of 10" max="10" value="7"></wa-rating>
```

## Custom Precision

```html
<!-- Quarter-star precision -->
<wa-rating label="Quarter-star Rating" precision="0.25" value="3.75"></wa-rating>

<!-- Half-star precision -->
<wa-rating label="Half-star Rating" precision="0.5" value="3.5"></wa-rating>

<!-- Whole-star precision (default) -->
<wa-rating label="Whole-star Rating" precision="1" value="3"></wa-rating>
```

## Event Handling

```html
<wa-rating 
  label="Interactive Rating" 
  (waChange)="onRatingChange($event)" 
  (waHover)="onRatingHover($event)">
</wa-rating>
```

```typescript
// In your component
onRatingChange(value: number): void {
  console.log(`Rating changed to: ${value}`);
}

onRatingHover(event: { phase: string, value: number }): void {
  if (event.phase === 'start') {
    console.log(`Hovering over: ${event.value}`);
  } else if (event.phase === 'end') {
    console.log('Hover ended');
  }
}
```

## Custom Styling

```html
<style>
  .custom-rating {
    --symbol-color: #d1d1d1;
    --symbol-color-active: #ffb400;
    --symbol-spacing: 0.5rem;
  }

  .heart-rating {
    --symbol-color: #e0e0e0;
    --symbol-color-active: #ff4081;
  }
</style>

<wa-rating label="Custom Styled Rating" class="custom-rating"></wa-rating>
<wa-rating label="Heart Rating" class="heart-rating"></wa-rating>

<!-- Using direct styling inputs -->
<wa-rating 
  label="Directly Styled Rating" 
  [color]="'#ff6b6b'" 
  [fontSize]="'24px'" 
  [backgroundColor]="'#f8f9fa'">
</wa-rating>

<!-- Dynamic direct styling -->
<wa-rating 
  label="Dynamic Styled Rating" 
  [color]="isActive ? '#4a90e2' : '#cccccc'" 
  [fontSize]="isLarge ? '2rem' : '1rem'">
</wa-rating>
```

## Custom Symbols

```html
<wa-rating id="heart-rating" label="Heart Rating"></wa-rating>

<script>
  // Set custom heart symbols
  const heartRating = document.getElementById('heart-rating');
  heartRating.getSymbol = (value) => {
    return `<wa-icon name="heart" variant="solid"></wa-icon>`;
  };
</script>
```

## Using with Angular Bindings

```html
<wa-rating 
  [label]="ratingLabel" 
  [value]="ratingValue" 
  [max]="maxRating"
  [precision]="ratingPrecision"
  [readonly]="isReadonly"
  [disabled]="isDisabled"
  [size]="ratingSize"
  (waChange)="onRatingChange($event)"
  (waHover)="onRatingHover($event)">
</wa-rating>

<!-- Using direct styling with Angular bindings -->
<wa-rating 
  [label]="ratingLabel" 
  [value]="ratingValue" 
  [color]="ratingColor" 
  [backgroundColor]="ratingBackgroundColor" 
  [fontSize]="ratingFontSize">
</wa-rating>
```

## Setting Custom Symbols in Angular

```typescript
import { Component, ViewChild, AfterViewInit } from '@angular/core';
import { WaRatingDirective } from './rating.directive';

@Component({
  selector: 'app-custom-rating',
  template: `
    <wa-rating #customRating label="Custom Rating"></wa-rating>
  `
})
export class CustomRatingComponent implements AfterViewInit {
  @ViewChild('customRating') ratingDirective!: WaRatingDirective;

  ngAfterViewInit() {
    // Set custom symbol function
    this.ratingDirective.getSymbol = (value: number) => {
      return `<wa-icon name="thumbs-up" variant="solid"></wa-icon>`;
    };
  }
}
```

## Using in Forms

```html
<form #ratingForm="ngForm" (ngSubmit)="submitRating(ratingForm)">
  <wa-rating 
    label="Rate our service" 
    name="serviceRating" 
    [(ngModel)]="serviceRating" 
    required>
  </wa-rating>

  <button type="submit" [disabled]="ratingForm.invalid">Submit</button>
</form>
```
