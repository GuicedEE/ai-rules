# Radio Examples

## Basic Usage

```html
<wa-radio-group label="Select an option">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>
```

## With Different Orientations

```html
<!-- Vertical orientation (default) -->
<wa-radio-group label="Vertical Radio Group" orientation="vertical">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>

<!-- Horizontal orientation -->
<wa-radio-group label="Horizontal Radio Group" orientation="horizontal">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>
```

## Different Sizes

```html
<wa-radio-group label="Small Radio Group" size="small">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
</wa-radio-group>

<wa-radio-group label="Medium Radio Group" size="medium">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
</wa-radio-group>

<wa-radio-group label="Large Radio Group" size="large">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
</wa-radio-group>
```

## With Initial Value

```html
<wa-radio-group label="Select an option" value="option2">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>
```

## With Hint

```html
<wa-radio-group 
  label="Select an option" 
  hint="Please choose one of the following options">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>

<!-- Using HTML in hint -->
<wa-radio-group label="Select an option">
  <div slot="hint">
    Please choose <strong>one</strong> of the following options
  </div>
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>
```

## Required Radio Group

```html
<wa-radio-group 
  label="Select an option" 
  [required]="true">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>
```

## Disabled States

```html
<!-- Disabled radio group -->
<wa-radio-group 
  label="Disabled Radio Group" 
  [disabled]="true" 
  value="option1">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>

<!-- Individual disabled radio -->
<wa-radio-group label="Partially Disabled Group">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2" [disabled]="true">Option 2 (Disabled)</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>
```

## Custom Styling

```html
<!-- Custom gap between radio buttons -->
<wa-radio-group 
  label="Custom Gap Radio Group" 
  [styleRadiosGap]="'20px'">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>

<!-- Custom radio styling -->
<wa-radio-group label="Custom Styled Radios">
  <wa-radio 
    value="option1" 
    [styleBackgroundColor]="'#f8f9fa'"
    [styleBackgroundColorChecked]="'#4caf50'"
    [styleBorderColor]="'#ced4da'"
    [styleBorderColorChecked]="'#4caf50'"
    [styleCheckedIconColor]="'#ffffff'">
    Custom Styled Option
  </wa-radio>
  <wa-radio value="option2">Regular Option</wa-radio>
</wa-radio-group>
```

## Radio Buttons

```html
<wa-radio-group label="Radio Buttons">
  <wa-radio-button value="option1">Option 1</wa-radio-button>
  <wa-radio-button value="option2">Option 2</wa-radio-button>
  <wa-radio-button value="option3">Option 3</wa-radio-button>
</wa-radio-group>

<!-- With prefix and suffix -->
<wa-radio-group label="Radio Buttons with Icons">
  <wa-radio-button value="home" [withPrefix]="true">
    <wa-icon name="home" slot="prefix"></wa-icon>
    Home
  </wa-radio-button>
  <wa-radio-button value="settings" [withPrefix]="true">
    <wa-icon name="settings" slot="prefix"></wa-icon>
    Settings
  </wa-radio-button>
  <wa-radio-button value="profile" [withPrefix]="true" [withSuffix]="true">
    <wa-icon name="user" slot="prefix"></wa-icon>
    Profile
    <wa-badge slot="suffix">New</wa-badge>
  </wa-radio-button>
</wa-radio-group>

<!-- Custom styled radio buttons -->
<wa-radio-group label="Custom Styled Radio Buttons">
  <wa-radio-button 
    value="option1" 
    [styleIndicatorColor]="'#4caf50'"
    [styleIndicatorWidth]="'3px'">
    Green Option
  </wa-radio-button>
  <wa-radio-button 
    value="option2" 
    [styleIndicatorColor]="'#2196f3'"
    [styleIndicatorWidth]="'3px'">
    Blue Option
  </wa-radio-button>
  <wa-radio-button 
    value="option3" 
    [styleIndicatorColor]="'#f44336'"
    [styleIndicatorWidth]="'3px'">
    Red Option
  </wa-radio-button>
</wa-radio-group>
```

## Event Handling

```html
<wa-radio-group 
  label="Interactive Radio Group" 
  (input)="onRadioInput($event)" 
  (change)="onRadioChange($event)" 
  (focusEvent)="onRadioFocus()" 
  (blurEvent)="onRadioBlur()"
  (waInvalid)="onRadioInvalid($event)">
  <wa-radio value="option1">Option 1</wa-radio>
  <wa-radio value="option2">Option 2</wa-radio>
  <wa-radio value="option3">Option 3</wa-radio>
</wa-radio-group>
```

```typescript
// In your component
onRadioInput(event: Event): void {
  console.log('Radio input:', (event.target as HTMLInputElement).value);
}

onRadioChange(event: Event): void {
  console.log('Radio change:', (event.target as HTMLInputElement).value);
}

onRadioFocus(): void {
  console.log('Radio group focused');
}

onRadioBlur(): void {
  console.log('Radio group blurred');
}

onRadioInvalid(event: CustomEvent): void {
  console.log('Radio group invalid:', event.detail);
}
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-radio-demo',
  template: `
    <wa-radio-group 
      [label]="groupLabel" 
      [value]="selectedValue" 
      [orientation]="groupOrientation" 
      [size]="groupSize" 
      [required]="isRequired" 
      [disabled]="isDisabled"
      (change)="onSelectionChange($event)">
      <wa-radio *ngFor="let option of options" [value]="option.value" [disabled]="option.disabled">
        {{ option.label }}
      </wa-radio>
    </wa-radio-group>
    
    <div>Selected value: {{ selectedValue }}</div>
  `
})
export class RadioDemoComponent {
  groupLabel = 'Select an option';
  selectedValue = 'option1';
  groupOrientation = 'vertical';
  groupSize = 'medium';
  isRequired = true;
  isDisabled = false;
  
  options = [
    { value: 'option1', label: 'Option 1', disabled: false },
    { value: 'option2', label: 'Option 2', disabled: false },
    { value: 'option3', label: 'Option 3', disabled: true }
  ];
  
  onSelectionChange(event: Event): void {
    this.selectedValue = (event.target as HTMLInputElement).value;
    console.log('Selection changed:', this.selectedValue);
  }
}
```

## Using with ngModel

```html
<form #radioForm="ngForm">
  <wa-radio-group 
    label="Select your favorite color" 
    name="favoriteColor" 
    [(ngModel)]="favoriteColor" 
    required>
    <wa-radio value="red">Red</wa-radio>
    <wa-radio value="green">Green</wa-radio>
    <wa-radio value="blue">Blue</wa-radio>
  </wa-radio-group>
  
  <div>Your favorite color is: {{ favoriteColor }}</div>
  
  <button type="submit" [disabled]="radioForm.invalid">Submit</button>
</form>
```

## Real-World Example: Survey Form

```html
<form #surveyForm="ngForm" (ngSubmit)="submitSurvey()">
  <h2>Customer Satisfaction Survey</h2>
  
  <wa-radio-group 
    label="How would you rate our service?" 
    name="serviceRating" 
    [(ngModel)]="survey.serviceRating" 
    required>
    <wa-radio value="excellent">Excellent</wa-radio>
    <wa-radio value="good">Good</wa-radio>
    <wa-radio value="average">Average</wa-radio>
    <wa-radio value="poor">Poor</wa-radio>
  </wa-radio-group>
  
  <wa-radio-group 
    label="How likely are you to recommend us to a friend?" 
    name="recommendation" 
    [(ngModel)]="survey.recommendation" 
    required>
    <wa-radio value="veryLikely">Very Likely</wa-radio>
    <wa-radio value="likely">Likely</wa-radio>
    <wa-radio value="neutral">Neutral</wa-radio>
    <wa-radio value="unlikely">Unlikely</wa-radio>
    <wa-radio value="veryUnlikely">Very Unlikely</wa-radio>
  </wa-radio-group>
  
  <wa-radio-group 
    label="Which feature do you use most often?" 
    name="mostUsedFeature" 
    [(ngModel)]="survey.mostUsedFeature" 
    required>
    <wa-radio value="feature1">Feature 1</wa-radio>
    <wa-radio value="feature2">Feature 2</wa-radio>
    <wa-radio value="feature3">Feature 3</wa-radio>
    <wa-radio value="other">Other</wa-radio>
  </wa-radio-group>
  
  <wa-textarea 
    label="Additional Comments" 
    name="comments" 
    [(ngModel)]="survey.comments">
  </wa-textarea>
  
  <button type="submit" [disabled]="surveyForm.invalid">Submit Survey</button>
</form>
```
