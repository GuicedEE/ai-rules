# Button Component Examples

📌 This document provides examples of using the `<wa-button>` component in Angular applications.

## Basic Usage

```html
<wa-button>Click Me</wa-button>
```

## Variants

```html
<wa-button variant="neutral">Neutral</wa-button>
<wa-button variant="brand">Brand</wa-button>
<wa-button variant="success">Success</wa-button>
<wa-button variant="warning">Warning</wa-button>
<wa-button variant="danger">Danger</wa-button>
```

## Appearances

```html
<wa-button appearance="accent">Accent</wa-button>
<wa-button appearance="filled">Filled</wa-button>
<wa-button appearance="outlined">Outlined</wa-button>
<wa-button appearance="plain">Plain</wa-button>
```

## Sizes

```html
<wa-button size="small">Small</wa-button>
<wa-button size="medium">Medium</wa-button>
<wa-button size="large">Large</wa-button>
```

## Boolean Attributes

```html
<wa-button pill>Pill Button</wa-button>
<wa-button caret>Dropdown</wa-button>
<wa-button disabled>Disabled</wa-button>
<wa-button loading>Loading</wa-button>
```

## With Angular Bindings

```html
<wa-button [variant]="buttonVariant" [disabled]="isDisabled" (click)="handleClick()">
  Dynamic Button
</wa-button>

<!-- Using direct styling with Angular bindings -->
<wa-button 
  [variant]="buttonVariant" 
  [color]="buttonColor" 
  [backgroundColor]="buttonBackgroundColor" 
  [fontSize]="buttonFontSize"
  (click)="handleClick()">
  Styled Dynamic Button
</wa-button>

<!-- Conditional styling based on component state -->
<wa-button 
  [variant]="buttonVariant" 
  [color]="isDarkMode ? '#ffffff' : '#333333'" 
  [backgroundColor]="isHighlighted ? accentColor : defaultColor">
  Context-Aware Button
</wa-button>
```

## Link Buttons

```html
<wa-button href="https://example.com" target="_blank">
  External Link
</wa-button>
```

## With Slots

```html
<wa-button>
  <wa-icon slot="prefix" name="star"></wa-icon>
  With Icon Prefix
</wa-button>

<wa-button>
  With Icon Suffix
  <wa-icon slot="suffix" name="arrow-right"></wa-icon>
</wa-button>
```

## Form Buttons

```html
<form #myForm="ngForm">
  <!-- Form fields here -->
  <wa-button type="submit">Submit Form</wa-button>
  <wa-button type="reset">Reset Form</wa-button>
</form>
```

## Combined Examples

```html
<wa-button 
  variant="success" 
  appearance="outlined" 
  size="large" 
  [loading]="isSubmitting"
  (click)="saveData()">
  <wa-icon slot="prefix" name="save"></wa-icon>
  Save Changes
</wa-button>

<wa-button 
  variant="danger" 
  appearance="plain" 
  [disabled]="!canDelete"
  (focus)="handleFocus()"
  (blur)="handleBlur()">
  Delete Item
</wa-button>
```

## Custom Styling

```html
<wa-button class="custom-button">
  Custom Styled Button
</wa-button>
```

```css
wa-button.custom-button::part(base) {
  background: linear-gradient(45deg, #ff6b6b, #ff8e53);
  color: white;
  border: none;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

wa-button.custom-button:hover::part(base) {
  transform: translateY(-2px);
  box-shadow: 0 6px 8px rgba(0, 0, 0, 0.15);
}
```

### Direct Styling

```html
<!-- Using direct styling inputs -->
<wa-button 
  [color]="'#ffffff'" 
  [backgroundColor]="'#4a90e2'" 
  [fontSize]="'16px'">
  Directly Styled Button
</wa-button>

<!-- Dynamic direct styling -->
<wa-button 
  [color]="isActive ? '#ffffff' : '#333333'" 
  [backgroundColor]="isActive ? '#4a90e2' : '#f0f0f0'" 
  [fontSize]="isLarge ? '18px' : '14px'">
  Dynamic Styled Button
</wa-button>
```

---

📌 For more details on available properties and usage guidelines, refer to the [Button Component Rules](./button.rules.md).
