# Button Group Component Examples

📌 This document provides examples of using the `<wa-button-group>` component in Angular applications.

## Basic Usage

```html
<wa-button-group label="Alignment">
  <wa-button>Left</wa-button>
  <wa-button>Center</wa-button>
  <wa-button>Right</wa-button>
</wa-button-group>
```

## Using Attribute Selector

```html
<div waButtonGroup label="Alignment">
  <button waButton>Left</button>
  <button waButton>Center</button>
  <button waButton>Right</button>
</div>
```

## Orientation

### Horizontal (Default)

```html
<wa-button-group label="Horizontal Group" orientation="horizontal">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
  <wa-button>Three</wa-button>
</wa-button-group>
```

### Vertical

```html
<wa-button-group label="Vertical Group" orientation="vertical">
  <wa-button>Top</wa-button>
  <wa-button>Middle</wa-button>
  <wa-button>Bottom</wa-button>
</wa-button-group>
```

## Size Inheritance

```html
<wa-button-group label="Small Buttons" size="small">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>

<wa-button-group label="Medium Buttons" size="medium">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>

<wa-button-group label="Large Buttons" size="large">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>
```

## Variant Inheritance

```html
<wa-button-group label="Neutral Buttons" variant="neutral">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>

<wa-button-group label="Brand Buttons" variant="brand">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>

<wa-button-group label="Success Buttons" variant="success">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>

<wa-button-group label="Warning Buttons" variant="warning">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>

<wa-button-group label="Danger Buttons" variant="danger">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
</wa-button-group>
```

## With Angular Bindings

```html
<wa-button-group 
  [label]="groupLabel" 
  [variant]="groupVariant" 
  [size]="groupSize" 
  [orientation]="groupOrientation">
  <wa-button *ngFor="let option of options">{{ option }}</wa-button>
</wa-button-group>
```

```typescript
@Component({
  // ...
})
export class MyComponent {
  groupLabel = 'Dynamic Group';
  groupVariant = 'brand';
  groupSize = 'medium';
  groupOrientation = 'horizontal';
  options = ['Option 1', 'Option 2', 'Option 3'];
}
```

## Mixed Button Styles

```html
<wa-button-group label="Mixed Styles" variant="neutral">
  <wa-button>Default</wa-button>
  <wa-button variant="brand">Override</wa-button>
  <wa-button pill>Pill Button</wa-button>
</wa-button-group>
```

## With Tooltips

```html
<wa-button-group label="Actions">
  <wa-tooltip content="Create new item">
    <wa-button>New</wa-button>
  </wa-tooltip>
  <wa-tooltip content="Edit selected item">
    <wa-button>Edit</wa-button>
  </wa-tooltip>
  <wa-tooltip content="Delete selected item">
    <wa-button>Delete</wa-button>
  </wa-tooltip>
</wa-button-group>
```

## Custom Styling

```html
<wa-button-group class="custom-group" label="Custom Styled Group">
  <wa-button>One</wa-button>
  <wa-button>Two</wa-button>
  <wa-button>Three</wa-button>
</wa-button-group>
```

```css
wa-button-group.custom-group::part(base) {
  background-color: var(--wa-color-neutral-50);
  padding: var(--wa-space-xs);
  border-radius: var(--wa-border-radius-m);
  box-shadow: var(--wa-shadow-s);
}

/* Add spacing between button groups */
wa-button-group:not(:last-child) {
  margin-right: var(--wa-space-m);
}
```

---

📌 For more details on available properties and usage guidelines, refer to the [Button Group Component Rules](./buttongroup.rules.md).
