# Breadcrumbs Examples

## Basic Usage

```html
<wa-breadcrumb label="Site Navigation">
  <wa-breadcrumb-item href="/home">Home</wa-breadcrumb-item>
  <wa-breadcrumb-item href="/home/products">Products</wa-breadcrumb-item>
  <wa-breadcrumb-item>Current Page</wa-breadcrumb-item>
</wa-breadcrumb>
```

## With Icons

```html
<wa-breadcrumb label="Site Navigation">
  <wa-breadcrumb-item href="/home">
    <wa-icon slot="prefix" name="house" variant="solid"></wa-icon>
    Home
  </wa-breadcrumb-item>
  
  <wa-breadcrumb-item href="/home/products">
    Products
  </wa-breadcrumb-item>
  
  <wa-breadcrumb-item href="/home/products/widgets">
    Widgets
    <wa-icon slot="suffix" name="star" variant="solid"></wa-icon>
  </wa-breadcrumb-item>
</wa-breadcrumb>
```

## Custom Separator

```html
<wa-breadcrumb>
  <wa-icon slot="separator" name="angles-right" variant="solid"></wa-icon>
  <wa-breadcrumb-item href="/level1">Level 1</wa-breadcrumb-item>
  <wa-breadcrumb-item href="/level1/level2">Level 2</wa-breadcrumb-item>
  <wa-breadcrumb-item>Current</wa-breadcrumb-item>
</wa-breadcrumb>
```

## With Target and Rel Attributes

```html
<wa-breadcrumb>
  <wa-breadcrumb-item href="https://example.com" target="_blank" rel="noopener">
    External Link
  </wa-breadcrumb-item>
  <wa-breadcrumb-item>Current Page</wa-breadcrumb-item>
</wa-breadcrumb>
```

## Custom Styling

```html
<style>
  .custom-breadcrumbs wa-breadcrumb-item::part(separator) {
    color: pink;
  }
  .custom-breadcrumbs wa-breadcrumb-item::part(prefix),
  .custom-breadcrumbs wa-breadcrumb-item::part(suffix) {
    color: blue;
  }
</style>

<wa-breadcrumb class="custom-breadcrumbs">
  <wa-breadcrumb-item href="/home">
    <wa-icon slot="prefix" name="house"></wa-icon>
    Home
  </wa-breadcrumb-item>
  <wa-breadcrumb-item>Current Page</wa-breadcrumb-item>
</wa-breadcrumb>
```

## With Advanced Components

```html
<wa-breadcrumb>
  <wa-breadcrumb-item href="/home">Home</wa-breadcrumb-item>
  
  <wa-breadcrumb-item>
    <wa-dropdown>
      <wa-button slot="trigger">Products</wa-button>
      <wa-menu>
        <wa-menu-item href="/products/category1">Category 1</wa-menu-item>
        <wa-menu-item href="/products/category2">Category 2</wa-menu-item>
      </wa-menu>
    </wa-dropdown>
  </wa-breadcrumb-item>
  
  <wa-breadcrumb-item>Current Item</wa-breadcrumb-item>
</wa-breadcrumb>
```
