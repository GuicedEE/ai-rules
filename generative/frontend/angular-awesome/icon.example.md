# Icon Examples

## Basic Usage

```html
<wa-icon name="star"></wa-icon>
```

## With Different Families and Variants

```html
<!-- Brand icons -->
<wa-icon name="github" family="brands"></wa-icon>
<wa-icon name="twitter" family="brands"></wa-icon>
<wa-icon name="facebook" family="brands"></wa-icon>

<!-- Regular variant -->
<wa-icon name="star" variant="regular"></wa-icon>
<wa-icon name="heart" variant="regular"></wa-icon>
<wa-icon name="bell" variant="regular"></wa-icon>

<!-- Solid variant -->
<wa-icon name="star" variant="solid"></wa-icon>
<wa-icon name="heart" variant="solid"></wa-icon>
<wa-icon name="bell" variant="solid"></wa-icon>
```

## With Accessibility Labels

```html
<!-- Semantic icon with label for screen readers -->
<wa-icon name="star" variant="solid" label="Favorite"></wa-icon>

<!-- Decorative icon without label (will be ignored by screen readers) -->
<wa-icon name="star" variant="solid"></wa-icon>
```

## Using Custom SVG Source

```html
<wa-icon src="/assets/icons/custom-icon.svg"></wa-icon>
```

## With Fixed Width

```html
<ul>
  <li>
    <wa-icon name="home" fixedWidth></wa-icon>
    Home
  </li>
  <li>
    <wa-icon name="user" fixedWidth></wa-icon>
    Profile
  </li>
  <li>
    <wa-icon name="cog" fixedWidth></wa-icon>
    Settings
  </li>
</ul>
```

## Using Custom Icon Libraries

```html
<!-- After registering a custom icon library -->
<wa-icon library="my-icons" name="smile"></wa-icon>
```

## Styling Icons

```html
<!-- Using inline styles -->
<wa-icon name="bell" style="font-size: 2rem; color: #4a90e2;"></wa-icon>

<!-- Using CSS classes -->
<style>
  .large-icon {
    font-size: 3rem;
  }
  .warning-icon {
    color: #f39c12;
  }
</style>

<wa-icon name="exclamation-triangle" class="large-icon warning-icon"></wa-icon>

<!-- Inheriting styles from parent -->
<div style="font-size: 2em; color: #4a90e2;">
  <wa-icon name="bell"></wa-icon>
</div>

<!-- Using direct styling inputs -->
<wa-icon 
  name="heart" 
  [color]="'#ff0000'" 
  [fontSize]="'24px'" 
  [backgroundColor]="'transparent'">
</wa-icon>

<!-- Dynamic direct styling -->
<wa-icon 
  name="star" 
  [color]="isActive ? '#f39c12' : '#cccccc'" 
  [fontSize]="isLarge ? '2rem' : '1rem'">
</wa-icon>
```

## Using CSS Custom Properties

```html
<!-- Using CSS custom property inputs -->
<wa-icon 
  [iconName]="'info-circle'"
  [iconVariant]="'solid'"
  [iconSize]="'2rem'"
  [iconColor]="'#4a90e2'"
  [iconBackgroundColor]="'#f0f0f0'">
</wa-icon>

<!-- Using style bindings for CSS custom properties -->
<wa-icon 
  [style.--wa-icon-name]="'info-circle'"
  [style.--wa-icon-variant]="'solid'"
  [style.--wa-icon-size]="'2rem'"
  [style.--wa-icon-color]="'#4a90e2'"
  [style.--wa-icon-background-color]="'#f0f0f0'">
</wa-icon>

<!-- Dynamic CSS custom properties -->
<wa-icon 
  [iconName]="dynamicIconName"
  [iconColor]="isActive ? '#4a90e2' : '#cccccc'">
</wa-icon>
```

## Using with Angular Bindings

```html
<wa-icon 
  [name]="iconName" 
  [family]="iconFamily" 
  [variant]="iconVariant"
  [label]="iconLabel"
  [fixedWidth]="isFixedWidth">
</wa-icon>

<!-- Conditionally showing different icons -->
<wa-icon 
  [name]="isActive ? 'toggle-on' : 'toggle-off'" 
  [variant]="isActive ? 'solid' : 'regular'">
</wa-icon>

<!-- Using direct styling with Angular bindings -->
<wa-icon 
  [name]="iconName" 
  [color]="iconColor" 
  [backgroundColor]="iconBackgroundColor" 
  [fontSize]="iconFontSize">
</wa-icon>
```

## Using in Other Components

```html
<!-- In a button -->
<wa-button>
  <wa-icon name="save" slot="prefix"></wa-icon>
  Save
</wa-button>

<!-- In a callout -->
<wa-callout variant="warning">
  <wa-icon slot="icon" name="exclamation-triangle" variant="solid"></wa-icon>
  This is a warning message.
</wa-callout>

<!-- In a card header -->
<wa-card [withHeader]="true">
  <div slot="header">
    <wa-icon name="info-circle"></wa-icon>
    Information
  </div>
  Card content goes here.
</wa-card>
```
