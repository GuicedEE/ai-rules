# Color Picker Examples

## Basic Usage

```html
<wa-color-picker label="Choose a color"></wa-color-picker>
```

## With Different Formats

```html
<wa-color-picker label="HEX Color" format="hex"></wa-color-picker>
<wa-color-picker label="RGB Color" format="rgb"></wa-color-picker>
<wa-color-picker label="HSL Color" format="hsl"></wa-color-picker>
<wa-color-picker label="HSV Color" format="hsv"></wa-color-picker>
```

## With Opacity

```html
<wa-color-picker label="Color with Opacity" [opacity]="true"></wa-color-picker>
```

## With Initial Value

```html
<wa-color-picker label="Red Color" value="#ff0000"></wa-color-picker>
<wa-color-picker label="Blue Color with Opacity" value="rgba(0, 0, 255, 0.5)" [opacity]="true"></wa-color-picker>
```

## With Different Sizes

```html
<wa-color-picker label="Small Color Picker" size="small"></wa-color-picker>
<wa-color-picker label="Medium Color Picker" size="medium"></wa-color-picker>
<wa-color-picker label="Large Color Picker" size="large"></wa-color-picker>
```

## With Swatches

```html
<!-- Using a semicolon-separated string -->
<wa-color-picker 
  label="With Swatches" 
  swatches="#ff0000;#00ff00;#0000ff;#ffff00;#ff00ff;#00ffff">
</wa-color-picker>

<!-- Using an array -->
<wa-color-picker 
  label="With Swatches Array" 
  [swatches]="['#ff0000', '#00ff00', '#0000ff', '#ffff00', '#ff00ff', '#00ffff']">
</wa-color-picker>
```

## With Hints

```html
<wa-color-picker 
  label="With Hint Text" 
  hint="Select a color for your profile theme">
</wa-color-picker>

<!-- Using HTML in hint -->
<wa-color-picker label="With HTML Hint">
  <div slot="hint">
    Select a color for your <strong>profile theme</strong>
  </div>
</wa-color-picker>
```

## Disabled and Required States

```html
<wa-color-picker label="Disabled Color Picker" [disabled]="true"></wa-color-picker>
<wa-color-picker label="Required Color Picker" [required]="true"></wa-color-picker>
```

## Format Toggle Control

```html
<!-- Allow format toggle (default) -->
<wa-color-picker label="With Format Toggle"></wa-color-picker>

<!-- Disable format toggle -->
<wa-color-picker label="No Format Toggle" [noFormatToggle]="true"></wa-color-picker>
```

## Uppercase HEX Values

```html
<wa-color-picker label="Uppercase HEX" format="hex" [uppercase]="true"></wa-color-picker>
```

## Custom Styling

```html
<!-- Using direct styling inputs -->
<wa-color-picker 
  label="Styled Color Picker" 
  [color]="'#333333'" 
  [backgroundColor]="'#f8f9fa'" 
  [fontSize]="'16px'">
</wa-color-picker>

<!-- Dynamic direct styling -->
<wa-color-picker 
  label="Dynamic Styled Color Picker" 
  [color]="isDarkMode ? '#ffffff' : '#333333'" 
  [backgroundColor]="isDarkMode ? '#333333' : '#ffffff'" 
  [fontSize]="isLarge ? '18px' : '14px'">
</wa-color-picker>

<!-- Using CSS custom properties -->
<wa-color-picker 
  label="Custom Properties Styling" 
  [swatchSize]="'24px'" 
  [swatchSpacing]="'8px'" 
  [borderRadius]="'8px'" 
  [dropdownWidth]="'300px'" 
  [dropdownHeight]="'250px'">
</wa-color-picker>

<!-- Combining direct styling and CSS custom properties -->
<wa-color-picker 
  label="Combined Styling" 
  [color]="'#333333'" 
  [backgroundColor]="'#f8f9fa'" 
  [fontSize]="'16px'"
  [swatchSize]="'20px'" 
  [borderRadius]="'4px'">
</wa-color-picker>
```

## Using with Angular Bindings

```html
<wa-color-picker 
  [label]="pickerLabel" 
  [hint]="pickerHint" 
  [value]="selectedColor" 
  [format]="colorFormat" 
  [opacity]="showOpacity" 
  [size]="pickerSize" 
  [disabled]="isDisabled" 
  [required]="isRequired"
  (change)="onColorChange($event)" 
  (input)="onColorInput($event)" 
  (focusEvent)="onPickerFocus()" 
  (blurEvent)="onPickerBlur()">
</wa-color-picker>

<!-- Using CSS custom properties with Angular bindings -->
<wa-color-picker 
  [label]="pickerLabel" 
  [value]="selectedColor" 
  [swatchSize]="customSwatchSize" 
  [swatchSpacing]="customSwatchSpacing" 
  [borderRadius]="customBorderRadius" 
  [dropdownWidth]="customDropdownWidth" 
  [dropdownHeight]="customDropdownHeight"
  (change)="onColorChange($event)">
</wa-color-picker>

<!-- Conditional CSS custom properties -->
<wa-color-picker 
  [label]="pickerLabel" 
  [value]="selectedColor" 
  [swatchSize]="isCompactMode ? '16px' : '24px'" 
  [dropdownWidth]="isCompactMode ? '250px' : '350px'"
  [borderRadius]="isRounded ? '12px' : '4px'">
</wa-color-picker>
```

## Using with ngModel

```html
<form #colorForm="ngForm">
  <wa-color-picker 
    label="Choose Theme Color" 
    name="themeColor" 
    [(ngModel)]="themeColor" 
    required>
  </wa-color-picker>

  <button type="submit" [disabled]="colorForm.invalid">Save</button>
</form>
```

## Accessing Methods Programmatically

```typescript
import { Component, ViewChild } from '@angular/core';
import { WaColorPickerDirective } from './color-picker.directive';

@Component({
  selector: 'app-color-picker-demo',
  template: `
    <wa-color-picker #colorPicker label="Programmatic Control"></wa-color-picker>
    <button (click)="focusPicker()">Focus</button>
    <button (click)="getHexValue()">Get HEX</button>
    <button (click)="getRgbValue()">Get RGB</button>
  `
})
export class ColorPickerDemoComponent {
  @ViewChild('colorPicker') colorPicker!: WaColorPickerDirective;

  focusPicker(): void {
    this.colorPicker.focus();
  }

  getHexValue(): void {
    const hexValue = this.colorPicker.getFormattedValue('hex');
    console.log('HEX value:', hexValue);
  }

  getRgbValue(): void {
    const rgbValue = this.colorPicker.getFormattedValue('rgb');
    console.log('RGB value:', rgbValue);
  }
}
```

## Using Custom HTML Labels

```html
<wa-color-picker>
  <div slot="label">
    Choose <strong>Brand Color</strong> <wa-icon name="palette"></wa-icon>
  </div>
</wa-color-picker>
```

## Form Integration

```html
<!-- In a larger form -->
<form #productForm="ngForm" (ngSubmit)="saveProduct()">
  <div class="form-group">
    <wa-input 
      label="Product Name" 
      name="productName" 
      [(ngModel)]="product.name" 
      required>
    </wa-input>
  </div>

  <div class="form-group">
    <wa-color-picker 
      label="Product Color" 
      name="productColor" 
      [(ngModel)]="product.color" 
      [opacity]="true" 
      required>
    </wa-color-picker>
  </div>

  <div class="form-group">
    <wa-color-picker 
      label="Secondary Color" 
      name="secondaryColor" 
      [(ngModel)]="product.secondaryColor">
    </wa-color-picker>
  </div>

  <button type="submit" [disabled]="productForm.invalid">Save Product</button>
</form>
```

## Real-World Example: Theme Customizer

```html
<div class="theme-customizer">
  <h2>Theme Customizer</h2>

  <wa-color-picker 
    label="Primary Color" 
    name="primaryColor" 
    [(ngModel)]="theme.primaryColor" 
    [swatches]="brandColors"
    [swatchSize]="'24px'"
    [swatchSpacing]="'8px'"
    [borderRadius]="'8px'"
    (change)="updateTheme()">
  </wa-color-picker>

  <wa-color-picker 
    label="Secondary Color" 
    name="secondaryColor" 
    [(ngModel)]="theme.secondaryColor" 
    [swatches]="brandColors"
    [swatchSize]="'24px'"
    [swatchSpacing]="'8px'"
    [borderRadius]="'8px'"
    (change)="updateTheme()">
  </wa-color-picker>

  <wa-color-picker 
    label="Background Color" 
    name="backgroundColor" 
    [(ngModel)]="theme.backgroundColor" 
    [opacity]="true"
    [dropdownWidth]="'300px'"
    [dropdownHeight]="'250px'"
    [borderRadius]="'8px'"
    (change)="updateTheme()">
  </wa-color-picker>

  <wa-color-picker 
    label="Text Color" 
    name="textColor" 
    [(ngModel)]="theme.textColor"
    [borderRadius]="'8px'" 
    (change)="updateTheme()">
  </wa-color-picker>

  <div class="preview" [style.backgroundColor]="theme.backgroundColor">
    <h3 [style.color]="theme.textColor">Theme Preview</h3>
    <wa-button [style.--background-color]="theme.primaryColor">Primary Button</wa-button>
    <wa-button [style.--background-color]="theme.secondaryColor">Secondary Button</wa-button>
  </div>
</div>
```
