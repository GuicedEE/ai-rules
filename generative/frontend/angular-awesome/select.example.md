# Select Examples

## Basic Usage

```html
<wa-select-wrapper label="Choose an option">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>
```

## Different Appearances

```html
<!-- Outlined appearance (default) -->
<wa-select-wrapper label="Outlined Select" appearance="outlined">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>

<!-- Filled appearance -->
<wa-select-wrapper label="Filled Select" appearance="filled">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>

<!-- Pill appearance -->
<wa-select-wrapper label="Pill Select" [pill]="true">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>
```

## Different Sizes

```html
<wa-select-wrapper label="Small Select" size="small">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
</wa-select-wrapper>

<wa-select-wrapper label="Medium Select" size="medium">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
</wa-select-wrapper>

<wa-select-wrapper label="Large Select" size="large">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
</wa-select-wrapper>
```

## With Placeholder and Hint

```html
<wa-select-wrapper 
  label="Choose an option" 
  placeholder="Select an option"
  hint="This is a helpful hint">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>

<!-- Using HTML in hint -->
<wa-select-wrapper label="Choose an option">
  <div slot="hint">
    Select an option from the <strong>dropdown</strong>
  </div>
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>
```

## Clearable Select

```html
<wa-select-wrapper 
  label="Clearable Select" 
  [clearable]="true"
  placeholder="Select an option">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>
```

## Multiple Selection

```html
<wa-select-wrapper 
  label="Multiple Select" 
  [multiple]="true"
  placeholder="Select multiple options">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
  <wa-option value="option4">Option 4</wa-option>
</wa-select-wrapper>

<!-- With max visible options -->
<wa-select-wrapper 
  label="Multiple Select with Max Visible" 
  [multiple]="true"
  [maxOptionsVisible]="2"
  placeholder="Select multiple options">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
  <wa-option value="option4">Option 4</wa-option>
</wa-select-wrapper>
```

## Dropdown Placement

```html
<wa-select-wrapper 
  label="Dropdown on Top" 
  placement="top"
  placeholder="Select an option">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>

<wa-select-wrapper 
  label="Dropdown on Bottom" 
  placement="bottom"
  placeholder="Select an option">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>
```

## Disabled States

```html
<!-- Disabled select -->
<wa-select-wrapper 
  label="Disabled Select" 
  [disabled]="true" 
  value="option1">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>

<!-- Individual disabled options -->
<wa-select-wrapper label="Select with Disabled Options">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2" [disabled]="true">Option 2 (Disabled)</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>
```

## Required Select

```html
<wa-select-wrapper 
  label="Required Select" 
  [required]="true"
  placeholder="Select an option">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>
```

## Custom Styling

```html
<!-- Select styling -->
<wa-select-wrapper 
  label="Custom Styled Select" 
  [backgroundColor]="'#f8f9fa'"
  [borderColor]="'#6c757d'"
  [borderWidth]="'2px'"
  [boxShadow]="'0 2px 4px rgba(0,0,0,0.1)'">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>

<!-- Option styling -->
<wa-select-wrapper label="Custom Styled Options">
  <wa-option 
    value="option1" 
    [backgroundColorHover]="'#e9ecef'" 
    [textColorHover]="'#007bff'">
    Option with Custom Hover
  </wa-option>
  <wa-option 
    value="option2" 
    [backgroundColorCurrent]="'#cfe2ff'" 
    [textColorCurrent]="'#0d6efd'">
    Option with Custom Selection
  </wa-option>
  <wa-option value="option3">Regular Option</wa-option>
</wa-select-wrapper>
```

## Event Handling

```html
<wa-select-wrapper 
  label="Interactive Select" 
  (inputEvent)="onSelectInput($event)" 
  (changeEvent)="onSelectChange($event)" 
  (focusEvent)="onSelectFocus()" 
  (blurEvent)="onSelectBlur()"
  (clearEvent)="onSelectClear()"
  (showEvent)="onDropdownShow()"
  (afterShowEvent)="onAfterDropdownShow()"
  (hideEvent)="onDropdownHide()"
  (afterHideEvent)="onAfterDropdownHide()"
  (invalidEvent)="onSelectInvalid($event)">
  <wa-option value="option1">Option 1</wa-option>
  <wa-option value="option2">Option 2</wa-option>
  <wa-option value="option3">Option 3</wa-option>
</wa-select-wrapper>
```

```typescript
// In your component
onSelectInput(event: Event): void {
  console.log('Select input:', (event.target as HTMLSelectElement).value);
}

onSelectChange(event: Event): void {
  console.log('Select change:', (event.target as HTMLSelectElement).value);
}

onSelectFocus(): void {
  console.log('Select focused');
}

onSelectBlur(): void {
  console.log('Select blurred');
}

onSelectClear(): void {
  console.log('Select cleared');
}

onDropdownShow(): void {
  console.log('Dropdown showing');
}

onAfterDropdownShow(): void {
  console.log('Dropdown shown');
}

onDropdownHide(): void {
  console.log('Dropdown hiding');
}

onAfterDropdownHide(): void {
  console.log('Dropdown hidden');
}

onSelectInvalid(event: CustomEvent): void {
  console.log('Select invalid:', event.detail);
}
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-select-demo',
  template: `
    <wa-select-wrapper 
      [label]="selectLabel" 
      [value]="selectedValue" 
      [placeholder]="selectPlaceholder" 
      [appearance]="selectAppearance" 
      [size]="selectSize" 
      [required]="isRequired" 
      [disabled]="isDisabled"
      [multiple]="isMultiple"
      [clearable]="isClearable"
      (changeEvent)="onSelectionChange($event)">
      <wa-option *ngFor="let option of options" [value]="option.value" [disabled]="option.disabled">
        {{ option.label }}
      </wa-option>
    </wa-select-wrapper>
    
    <div>Selected value: {{ selectedValue }}</div>
  `
})
export class SelectDemoComponent {
  selectLabel = 'Select an option';
  selectedValue = 'option1';
  selectPlaceholder = 'Choose an option';
  selectAppearance = 'outlined';
  selectSize = 'medium';
  isRequired = true;
  isDisabled = false;
  isMultiple = false;
  isClearable = true;
  
  options = [
    { value: 'option1', label: 'Option 1', disabled: false },
    { value: 'option2', label: 'Option 2', disabled: false },
    { value: 'option3', label: 'Option 3', disabled: true }
  ];
  
  onSelectionChange(event: Event): void {
    this.selectedValue = (event.target as HTMLSelectElement).value;
    console.log('Selection changed:', this.selectedValue);
  }
}
```

## Using with ngModel

```html
<form #selectForm="ngForm">
  <wa-select-wrapper 
    label="Select your favorite color" 
    name="favoriteColor" 
    [(ngModel)]="favoriteColor" 
    required>
    <wa-option value="red">Red</wa-option>
    <wa-option value="green">Green</wa-option>
    <wa-option value="blue">Blue</wa-option>
  </wa-select-wrapper>
  
  <div>Your favorite color is: {{ favoriteColor }}</div>
  
  <button type="submit" [disabled]="selectForm.invalid">Submit</button>
</form>
```

## Real-World Example: Country Selector

```typescript
import { Component, OnInit } from '@angular/core';

interface Country {
  code: string;
  name: string;
  continent: string;
}

@Component({
  selector: 'app-country-selector',
  template: `
    <div class="country-form">
      <h2>Select Your Country</h2>
      
      <wa-select-wrapper 
        label="Country" 
        [clearable]="true"
        placeholder="Select your country"
        [(ngModel)]="selectedCountry"
        (changeEvent)="onCountryChange($event)"
        [required]="true">
        
        <wa-option *ngFor="let country of countries" [value]="country.code">
          {{ country.name }} ({{ country.code }})
        </wa-option>
      </wa-select-wrapper>
      
      <div *ngIf="selectedCountry" class="selected-country">
        <h3>Selected Country</h3>
        <p>Code: {{ getCountryByCode(selectedCountry)?.code }}</p>
        <p>Name: {{ getCountryByCode(selectedCountry)?.name }}</p>
        <p>Continent: {{ getCountryByCode(selectedCountry)?.continent }}</p>
      </div>
    </div>
  `,
  styles: [`
    .country-form {
      max-width: 500px;
      margin: 0 auto;
    }
    
    .selected-country {
      margin-top: 20px;
      padding: 15px;
      border: 1px solid #e0e0e0;
      border-radius: 4px;
      background-color: #f9f9f9;
    }
  `]
})
export class CountrySelectorComponent implements OnInit {
  countries: Country[] = [];
  selectedCountry: string = '';
  
  ngOnInit(): void {
    // In a real app, this would come from an API
    this.countries = [
      { code: 'US', name: 'United States', continent: 'North America' },
      { code: 'CA', name: 'Canada', continent: 'North America' },
      { code: 'MX', name: 'Mexico', continent: 'North America' },
      { code: 'BR', name: 'Brazil', continent: 'South America' },
      { code: 'AR', name: 'Argentina', continent: 'South America' },
      { code: 'GB', name: 'United Kingdom', continent: 'Europe' },
      { code: 'DE', name: 'Germany', continent: 'Europe' },
      { code: 'FR', name: 'France', continent: 'Europe' },
      { code: 'CN', name: 'China', continent: 'Asia' },
      { code: 'JP', name: 'Japan', continent: 'Asia' },
      { code: 'IN', name: 'India', continent: 'Asia' },
      { code: 'AU', name: 'Australia', continent: 'Oceania' },
      { code: 'NZ', name: 'New Zealand', continent: 'Oceania' },
      { code: 'ZA', name: 'South Africa', continent: 'Africa' },
      { code: 'EG', name: 'Egypt', continent: 'Africa' }
    ];
  }
  
  onCountryChange(event: Event): void {
    console.log('Country changed:', this.selectedCountry);
  }
  
  getCountryByCode(code: string): Country | undefined {
    return this.countries.find(country => country.code === code);
  }
}
```

## Grouped Options with Custom Styling

```html
<wa-select-wrapper 
  label="Select a Destination" 
  [clearable]="true"
  placeholder="Choose a destination"
  [backgroundColor]="'#f8f9fa'"
  [borderColor]="'#007bff'"
  [boxShadow]="'0 0 0 0.2rem rgba(0,123,255,.25)'">
  
  <!-- Europe -->
  <div style="padding: 8px 12px; font-weight: bold; color: #6c757d; background-color: #e9ecef;">Europe</div>
  <wa-option value="paris">Paris, France</wa-option>
  <wa-option value="rome">Rome, Italy</wa-option>
  <wa-option value="barcelona">Barcelona, Spain</wa-option>
  
  <!-- Asia -->
  <div style="padding: 8px 12px; font-weight: bold; color: #6c757d; background-color: #e9ecef;">Asia</div>
  <wa-option value="tokyo">Tokyo, Japan</wa-option>
  <wa-option value="bangkok">Bangkok, Thailand</wa-option>
  <wa-option value="singapore">Singapore</wa-option>
  
  <!-- Americas -->
  <div style="padding: 8px 12px; font-weight: bold; color: #6c757d; background-color: #e9ecef;">Americas</div>
  <wa-option value="newyork">New York, USA</wa-option>
  <wa-option value="rio">Rio de Janeiro, Brazil</wa-option>
  <wa-option value="cancun">Cancun, Mexico</wa-option>
</wa-select-wrapper>
```
