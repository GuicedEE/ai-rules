# Callout Examples

## Basic Usage

```html
<wa-callout>
  This is a basic callout with default styling.
</wa-callout>
```

## With Variants

```html
<wa-callout variant="brand">
  <strong>Brand Callout</strong><br />
  This callout uses the brand color theme.
</wa-callout>

<wa-callout variant="success">
  <strong>Success Callout</strong><br />
  This callout indicates a successful operation.
</wa-callout>

<wa-callout variant="warning">
  <strong>Warning Callout</strong><br />
  This callout warns about potential issues.
</wa-callout>

<wa-callout variant="danger">
  <strong>Danger Callout</strong><br />
  This callout indicates an error or critical issue.
</wa-callout>

<wa-callout variant="neutral">
  <strong>Neutral Callout</strong><br />
  This callout uses a neutral color theme.
</wa-callout>
```

## Different Appearances

```html
<wa-callout appearance="filled">
  <strong>Filled Appearance</strong><br />
  This callout has a filled background.
</wa-callout>

<wa-callout appearance="outlined">
  <strong>Outlined Appearance</strong><br />
  This callout has an outline but no fill.
</wa-callout>

<wa-callout appearance="accent">
  <strong>Accent Appearance</strong><br />
  This callout has an accent style.
</wa-callout>

<wa-callout appearance="plain">
  <strong>Plain Appearance</strong><br />
  This callout has a plain style without borders.
</wa-callout>

<wa-callout appearance="outlined filled">
  <strong>Outlined Filled Appearance</strong><br />
  This callout has both an outline and a filled background.
</wa-callout>

<wa-callout appearance="outlined accent">
  <strong>Outlined Accent Appearance</strong><br />
  This callout has both an outline and an accent style.
</wa-callout>
```

## Different Sizes

```html
<wa-callout size="small">
  This is a small callout.
</wa-callout>

<wa-callout size="medium">
  This is a medium callout.
</wa-callout>

<wa-callout size="large">
  This is a large callout.
</wa-callout>
```

## With Icon

```html
<wa-callout variant="success" appearance="outlined filled" size="medium">
  <wa-icon slot="icon" name="circle-check" variant="regular"></wa-icon>
  <strong>Success!</strong><br />
  Your changes have been saved.
</wa-callout>

<wa-callout variant="warning" appearance="outlined filled" size="medium">
  <wa-icon slot="icon" name="triangle-exclamation" variant="regular"></wa-icon>
  <strong>Warning!</strong><br />
  This action cannot be undone.
</wa-callout>

<wa-callout variant="danger" appearance="outlined filled" size="medium">
  <wa-icon slot="icon" name="circle-xmark" variant="regular"></wa-icon>
  <strong>Error!</strong><br />
  There was a problem processing your request.
</wa-callout>

<wa-callout variant="neutral" appearance="outlined filled" size="medium">
  <wa-icon slot="icon" name="circle-info" variant="regular"></wa-icon>
  <strong>Information</strong><br />
  Here's some additional information you might find useful.
</wa-callout>
```

## Combining Multiple Attributes

```html
<wa-callout variant="brand" appearance="outlined accent" size="large">
  <wa-icon slot="icon" name="lightbulb" variant="regular"></wa-icon>
  <strong>Pro Tip!</strong><br />
  You can combine different attributes to create custom callout styles.
</wa-callout>
```

## Using with Angular Bindings

```html
<wa-callout [variant]="calloutVariant" [appearance]="calloutAppearance" [size]="calloutSize">
  <wa-icon slot="icon" [name]="iconName" [variant]="iconVariant"></wa-icon>
  <strong>{{title}}</strong><br />
  {{message}}
</wa-callout>
```
