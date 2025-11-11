# Details Examples

## Basic Usage

```html
<wa-details summary="View Details">
  This is the content that will be shown when the details are expanded.
</wa-details>
```

## With Different Appearances

```html
<wa-details summary="Filled Appearance" appearance="filled">
  This details component has a filled appearance.
</wa-details>

<wa-details summary="Outlined Appearance" appearance="outlined">
  This details component has an outlined appearance.
</wa-details>

<wa-details summary="Plain Appearance" appearance="plain">
  This details component has a plain appearance.
</wa-details>

<!-- Multiple appearances can be combined -->
<wa-details summary="Combined Appearance" appearance="filled outlined">
  This details component has both filled and outlined appearances.
</wa-details>
```

## With Initial State

```html
<!-- Initially open -->
<wa-details summary="Initially Open" open>
  This details component is initially open.
</wa-details>

<!-- Initially closed (default) -->
<wa-details summary="Initially Closed">
  This details component is initially closed.
</wa-details>
```

## Disabled State

```html
<wa-details summary="Disabled Details" disabled>
  This details component cannot be toggled by the user.
</wa-details>
```

## Using HTML in Summary

```html
<wa-details>
  <span slot="summary">
    Custom HTML Summary with <a href="#">link</a>
  </span>
  This details component has a custom HTML summary.
</wa-details>
```

## Custom Icons

```html
<wa-details summary="Custom Icons">
  <wa-icon slot="expand-icon" name="plus-circle"></wa-icon>
  <wa-icon slot="collapse-icon" name="minus-circle"></wa-icon>
  This details component has custom expand and collapse icons.
</wa-details>
```

## Custom Styling

```html
<style>
  .custom-details {
    --icon-color: #4a90e2;
    --spacing: 1rem;
    --show-duration: 300ms;
    --hide-duration: 300ms;
    --display: block;
  }
</style>

<wa-details summary="Custom Styled Details" class="custom-details">
  This details component has custom styling applied using CSS variables.
</wa-details>

<!-- Using direct styling inputs -->
<wa-details 
  summary="Directly Styled Details" 
  [color]="'#333333'" 
  [backgroundColor]="'#f8f9fa'" 
  [fontSize]="'1rem'"
  [iconColor]="'#4a90e2'"
  [spacing]="'1rem'"
  [showDuration]="'300ms'"
  [hideDuration]="'300ms'"
  [display]="'block'">
  This details component has styling applied using direct styling inputs.
</wa-details>

<!-- Dynamic direct styling -->
<wa-details 
  summary="Dynamic Styled Details" 
  [color]="isDarkMode ? '#ffffff' : '#333333'" 
  [backgroundColor]="isDarkMode ? '#333333' : '#ffffff'" 
  [iconColor]="isHighlighted ? '#ff4081' : '#4a90e2'">
  This details component has dynamic styling based on component state.
</wa-details>
```

## Event Handling

```html
<wa-details 
  summary="Event Handling" 
  (waShow)="onShow()" 
  (waAfterShow)="onAfterShow()" 
  (waHide)="onHide()" 
  (waAfterHide)="onAfterHide()">
  This details component emits events when toggled.
</wa-details>
```

```typescript
// In your component
onShow(): void {
  console.log('Details are being shown');
}

onAfterShow(): void {
  console.log('Details have been shown');
}

onHide(): void {
  console.log('Details are being hidden');
}

onAfterHide(): void {
  console.log('Details have been hidden');
}
```

## Using with Angular Bindings

```html
<wa-details 
  [summary]="detailsSummary" 
  [appearance]="detailsAppearance" 
  [open]="isOpen" 
  [disabled]="isDisabled"
  (waShow)="onShow()" 
  (waAfterShow)="onAfterShow()" 
  (waHide)="onHide()" 
  (waAfterHide)="onAfterHide()">
  {{detailsContent}}
</wa-details>

<!-- Two-way binding for open state -->
<wa-details 
  summary="Two-way Binding" 
  [(open)]="isOpen">
  This details component has two-way binding for the open state.
</wa-details>

<!-- Using direct styling with Angular bindings -->
<wa-details 
  [summary]="detailsSummary" 
  [open]="isOpen" 
  [color]="detailsColor" 
  [backgroundColor]="detailsBackgroundColor" 
  [fontSize]="detailsFontSize"
  [iconColor]="detailsIconColor"
  [spacing]="detailsSpacing"
  [showDuration]="detailsShowDuration"
  [hideDuration]="detailsHideDuration"
  [display]="detailsDisplay">
  {{detailsContent}}
</wa-details>

<!-- Conditional styling based on component state -->
<wa-details 
  [summary]="detailsSummary" 
  [color]="isDarkMode ? '#ffffff' : '#333333'" 
  [backgroundColor]="isDarkMode ? '#333333' : '#ffffff'"
  [iconColor]="isHighlighted ? accentColor : defaultIconColor">
  {{detailsContent}}
</wa-details>
```

## Programmatic Control

```typescript
import { Component, ViewChild } from '@angular/core';
import { WaDetailsDirective } from './details.directive';

@Component({
  selector: 'app-details-demo',
  template: `
    <wa-details #detailsRef summary="Programmatic Control">
      This details component can be controlled programmatically.
    </wa-details>
    <button (click)="showDetails()">Show</button>
    <button (click)="hideDetails()">Hide</button>
  `
})
export class DetailsDemoComponent {
  @ViewChild('detailsRef') detailsRef!: WaDetailsDirective;

  showDetails(): void {
    this.detailsRef.show();
  }

  hideDetails(): void {
    this.detailsRef.hide();
  }
}
```

## Using with ngModel

```html
<wa-details summary="Using ngModel" [(ngModel)]="isDetailsOpen">
  This details component uses ngModel for two-way binding of the open state.
</wa-details>

<button (click)="isDetailsOpen = !isDetailsOpen">
  {{ isDetailsOpen ? 'Close' : 'Open' }} Details
</button>
```

## Common Use Cases

```html
<!-- In a FAQ section -->
<div class="faq-section">
  <wa-details summary="What is Web Awesome?">
    Web Awesome is a library of web components for building modern web applications.
  </wa-details>

  <wa-details summary="How do I install Web Awesome?">
    You can install Web Awesome using npm: <code>npm install web-awesome</code>
  </wa-details>

  <wa-details summary="Is Web Awesome free to use?">
    Yes, Web Awesome is open source and free to use in your projects.
  </wa-details>
</div>

<!-- In a form with sections -->
<form>
  <wa-details summary="Personal Information" open>
    <div class="form-group">
      <label for="name">Name</label>
      <input id="name" type="text">
    </div>
    <div class="form-group">
      <label for="email">Email</label>
      <input id="email" type="email">
    </div>
  </wa-details>

  <wa-details summary="Shipping Address">
    <div class="form-group">
      <label for="address">Address</label>
      <input id="address" type="text">
    </div>
    <div class="form-group">
      <label for="city">City</label>
      <input id="city" type="text">
    </div>
  </wa-details>

  <wa-details summary="Payment Information">
    <div class="form-group">
      <label for="card">Card Number</label>
      <input id="card" type="text">
    </div>
    <div class="form-group">
      <label for="expiry">Expiry Date</label>
      <input id="expiry" type="text">
    </div>
  </wa-details>

  <button type="submit">Submit</button>
</form>
```
