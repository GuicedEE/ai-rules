# Card Examples

## Basic Usage

```html
<wa-card>
  This is a basic card with default styling.
</wa-card>
```

## With Different Appearances

```html
<wa-card appearance="accent">
  This card has an accent appearance.
</wa-card>

<wa-card appearance="filled">
  This card has a filled appearance.
</wa-card>

<wa-card appearance="outlined">
  This card has an outlined appearance.
</wa-card>

<wa-card appearance="plain">
  This card has a plain appearance.
</wa-card>
```

## With Different Sizes

```html
<wa-card size="small">
  This is a small card.
</wa-card>

<wa-card size="medium">
  This is a medium card.
</wa-card>

<wa-card size="large">
  This is a large card.
</wa-card>
```

## With Header

```html
<wa-card [withHeader]="true">
  <div slot="header">Card Header</div>
  This is the main content of the card.
</wa-card>
```

## With Footer

```html
<wa-card [withFooter]="true">
  This is the main content of the card.
  <div slot="footer">Card Footer</div>
</wa-card>
```

## With Image

```html
<wa-card [withImage]="true">
  <img slot="image" src="https://example.com/image.jpg" alt="Example Image">
  This is the main content of the card.
</wa-card>
```

## Complete Example with All Slots

```html
<wa-card 
  appearance="outlined" 
  size="medium" 
  [withHeader]="true" 
  [withImage]="true" 
  [withFooter]="true">

  <img 
    slot="image" 
    src="https://example.com/cat.jpg" 
    alt="Cat image">

  <div slot="header">Cute Cat</div>

  This is a very adorable kitten that likes being inside cards.

  <div slot="footer" class="wa-split">
    <wa-button variant="brand">Adopt</wa-button>
    <wa-rating label="Rating"></wa-rating>
  </div>
</wa-card>
```

## With Custom Styling

```html
<style>
  .custom-card {
    --border-radius: 16px;
    --border-color: #6200ee;
    --inner-border-color: #e0e0e0;
    --border-width: 2px;
    --spacing: 16px;
  }
</style>

<wa-card 
  class="custom-card" 
  appearance="outlined" 
  [withHeader]="true" 
  [withFooter]="true">

  <div slot="header">Custom Styled Card</div>

  This card has custom styling applied using CSS variables.

  <div slot="footer">Footer with custom styling</div>
</wa-card>

<!-- Using direct styling inputs -->
<wa-card 
  appearance="outlined" 
  [withHeader]="true" 
  [withFooter]="true"
  [color]="'#333333'" 
  [backgroundColor]="'#f8f9fa'" 
  [fontSize]="'1rem'"
  [borderRadius]="'12px'"
  [borderColor]="'#6200ee'"
  [innerBorderColor]="'#e0e0e0'"
  [borderWidth]="'2px'"
  [spacing]="'16px'">

  <div slot="header">Directly Styled Card</div>

  This card has styling applied using direct styling inputs.

  <div slot="footer">Footer with direct styling</div>
</wa-card>

<!-- Dynamic direct styling -->
<wa-card 
  appearance="outlined" 
  [withHeader]="true" 
  [color]="isDarkMode ? '#ffffff' : '#333333'" 
  [backgroundColor]="isDarkMode ? '#333333' : '#ffffff'" 
  [borderColor]="isHighlighted ? '#ff4081' : '#6200ee'">

  <div slot="header">Dynamic Styled Card</div>

  This card has dynamic styling based on component state.
</wa-card>
```

## Using with Angular Bindings

```html
<wa-card 
  [appearance]="cardAppearance" 
  [size]="cardSize" 
  [withHeader]="hasHeader" 
  [withImage]="hasImage" 
  [withFooter]="hasFooter">

  <!-- Image will be shown when hasImage is true -->
  <img 
    slot="image" 
    [src]="imageUrl" 
    [alt]="imageAlt">

  <!-- Header will be shown when hasHeader is true -->
  <div slot="header">{{headerText}}</div>

  {{cardContent}}

  <!-- Footer will be shown when hasFooter is true -->
  <div slot="footer">
    <wa-button [variant]="buttonVariant">{{buttonText}}</wa-button>
  </div>
</wa-card>

<!-- Using direct styling with Angular bindings -->
<wa-card 
  [appearance]="cardAppearance" 
  [size]="cardSize" 
  [withHeader]="hasHeader" 
  [withFooter]="hasFooter"
  [color]="cardColor" 
  [backgroundColor]="cardBackgroundColor" 
  [fontSize]="cardFontSize"
  [borderRadius]="cardBorderRadius"
  [borderColor]="cardBorderColor"
  [innerBorderColor]="cardInnerBorderColor"
  [borderWidth]="cardBorderWidth"
  [spacing]="cardSpacing">

  <div slot="header">{{headerText}}</div>

  {{cardContent}}

  <div slot="footer">
    <wa-button [variant]="buttonVariant">{{buttonText}}</wa-button>
  </div>
</wa-card>

<!-- Conditional styling based on component state -->
<wa-card 
  [appearance]="cardAppearance" 
  [withHeader]="true"
  [color]="isDarkMode ? '#ffffff' : '#333333'" 
  [backgroundColor]="isDarkMode ? '#333333' : '#ffffff'"
  [borderColor]="isSelected ? accentColor : defaultBorderColor">

  <div slot="header">{{headerText}}</div>

  {{cardContent}}
</wa-card>
```
