# Checkbox Examples

## Basic Usage

```html
<wa-checkbox>Accept terms and conditions</wa-checkbox>
```

## Different States

```html
<!-- Checked state -->
<wa-checkbox checked>I agree to the terms</wa-checkbox>

<!-- Disabled state -->
<wa-checkbox disabled>Disabled option</wa-checkbox>

<!-- Required state -->
<wa-checkbox required>Required field</wa-checkbox>

<!-- Indeterminate state -->
<wa-checkbox indeterminate>Select all items</wa-checkbox>

<!-- Combinations -->
<wa-checkbox checked disabled>Checked and disabled</wa-checkbox>
<wa-checkbox indeterminate disabled>Indeterminate and disabled</wa-checkbox>
```

## Different Sizes

```html
<wa-checkbox size="small">Small checkbox</wa-checkbox>
<wa-checkbox size="medium">Medium checkbox</wa-checkbox>
<wa-checkbox size="large">Large checkbox</wa-checkbox>
```

## With Hint Text

```html
<wa-checkbox hint="This is additional information">Checkbox with hint</wa-checkbox>

<!-- Using hint slot for more complex content -->
<wa-checkbox>
  Subscribe to newsletter
  <div slot="hint">
    You'll receive weekly updates about our <strong>products</strong> and <strong>services</strong>.
  </div>
</wa-checkbox>
```

## Form Integration

```html
<!-- With name and value -->
<wa-checkbox name="terms" value="accepted">Accept terms</wa-checkbox>

<!-- In a form -->
<form id="myForm">
  <wa-checkbox name="subscribe" required>Subscribe to newsletter</wa-checkbox>
  <button type="submit">Submit</button>
</form>

<!-- Using form attribute to associate with a form -->
<wa-checkbox form="myForm" name="external">I'm outside the form</wa-checkbox>
```

### Template-Driven Forms with ngModel

```html
<form #myForm="ngForm" (ngSubmit)="onSubmit(myForm)">
  <!-- Basic ngModel binding -->
  <wa-checkbox [(ngModel)]="user.acceptTerms" name="acceptTerms" required>
    I accept the terms and conditions
  </wa-checkbox>
  
  <!-- With validation and error message -->
  <div>
    <wa-checkbox [(ngModel)]="user.subscribe" name="subscribe" #subscribe="ngModel" required>
      Subscribe to newsletter
    </wa-checkbox>
    <div [class.visible]="subscribe.invalid && (subscribe.dirty || subscribe.touched)" class="error-message">
      This field is required
    </div>
  </div>
  
  <button type="submit" [disabled]="!myForm.valid">Submit</button>
</form>
```

### Reactive Forms

```html
<form [formGroup]="myForm" (ngSubmit)="onSubmit()">
  <!-- Basic formControlName binding -->
  <wa-checkbox formControlName="acceptTerms">
    I accept the terms and conditions
  </wa-checkbox>
  
  <!-- With validation and error message -->
  <div>
    <wa-checkbox formControlName="subscribe">
      Subscribe to newsletter
    </wa-checkbox>
    <div [class.visible]="myForm.get('subscribe')?.invalid && 
               (myForm.get('subscribe')?.dirty || myForm.get('subscribe')?.touched)" 
         class="error-message">
      This field is required
    </div>
  </div>
  
  <button type="submit" [disabled]="myForm.invalid">Submit</button>
</form>
```

```typescript
// In your component
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-checkbox-form-example',
  templateUrl: './checkbox-form-example.component.html'
})
export class CheckboxFormExampleComponent implements OnInit {
  myForm!: FormGroup;
  
  constructor(private fb: FormBuilder) {}
  
  ngOnInit(): void {
    this.myForm = this.fb.group({
      acceptTerms: [false, Validators.requiredTrue],
      subscribe: [false, Validators.required]
    });
  }
  
  onSubmit(): void {
    if (this.myForm.valid) {
      console.log(this.myForm.value);
    }
  }
}
```

## Using with Angular Bindings

```html
<!-- Property binding -->
<wa-checkbox [checked]="isChecked" [disabled]="isDisabled">
  Toggle me
</wa-checkbox>

<!-- Event binding -->
<wa-checkbox (checkedChange)="onCheckboxChange($event)">
  Notify on change
</wa-checkbox>

<!-- Two-way binding with ngModel (recommended) -->
<wa-checkbox [(ngModel)]="formValue.subscribe" name="subscribe">
  Subscribe to newsletter
</wa-checkbox>

<!-- Multiple bindings -->
<wa-checkbox
  [checked]="user.preferences.notifications"
  [disabled]="!user.isActive"
  (checkedChange)="updatePreferences($event)">
  Enable notifications
</wa-checkbox>
```

## Event Handling

```typescript
// In your component
export class CheckboxExampleComponent {
  onCheckboxChange(isChecked: boolean): void {
    console.log(`Checkbox is now ${isChecked ? 'checked' : 'unchecked'}`);
  }
  
  onInvalid(event: Event): void {
    console.log('Checkbox validation failed');
  }
}
```

```html
<!-- In your template -->
<wa-checkbox 
  required
  (checkedChange)="onCheckboxChange($event)"
  (waInvalid)="onInvalid($event)">
  This field is required
</wa-checkbox>
```

## Programmatic Control

```typescript
import { Component, ViewChild } from '@angular/core';
import { WaCheckboxDirective } from './checkbox.directive';

@Component({
  selector: 'app-checkbox-demo',
  template: `
    <wa-checkbox #myCheckbox>Programmatically controlled</wa-checkbox>
    <button (click)="focusCheckbox()">Focus</button>
    <button (click)="clickCheckbox()">Click</button>
    <button (click)="setInvalid()">Set Invalid</button>
  `
})
export class CheckboxDemoComponent {
  @ViewChild('myCheckbox') checkbox!: WaCheckboxDirective;
  
  focusCheckbox(): void {
    this.checkbox.focus();
  }
  
  clickCheckbox(): void {
    this.checkbox.click();
  }
  
  setInvalid(): void {
    this.checkbox.setCustomValidity('This checkbox is invalid');
  }
}
```

## Custom Styling with CSS Properties

```html
<!-- Basic custom styling -->
<wa-checkbox 
  [backgroundColor]="'#f0f0f0'" 
  [backgroundColorChecked]="'#4a90e2'">
  Custom background colors
</wa-checkbox>

<!-- Border customization -->
<wa-checkbox 
  [borderColor]="'#cccccc'" 
  [borderColorChecked]="'#2a70c2'" 
  [borderRadius]="'4px'" 
  [borderStyle]="'solid'" 
  [borderWidth]="'2px'">
  Custom borders
</wa-checkbox>

<!-- Icon and size customization -->
<wa-checkbox 
  [checkedIconColor]="'white'" 
  [toggleSize]="'24px'">
  Custom icon and size
</wa-checkbox>

<!-- Shadow effects -->
<wa-checkbox 
  [boxShadow]="'0 0 5px rgba(0,0,0,0.2)'">
  With shadow effect
</wa-checkbox>

<!-- Comprehensive styling example -->
<wa-checkbox 
  [backgroundColor]="'#f8f9fa'" 
  [backgroundColorChecked]="'#28a745'" 
  [borderColor]="'#dee2e6'" 
  [borderColorChecked]="'#28a745'" 
  [borderRadius]="'50%'" 
  [borderWidth]="'1px'" 
  [checkedIconColor]="'white'" 
  [toggleSize]="'20px'">
  Fully customized checkbox
</wa-checkbox>
```

## Common Use Cases

```html
<!-- In a settings form -->
<div class="settings-form">
  <wa-checkbox checked>Enable notifications</wa-checkbox>
  <wa-checkbox>Subscribe to newsletter</wa-checkbox>
  <wa-checkbox disabled>Premium feature (upgrade to enable)</wa-checkbox>
</div>

<!-- In a terms acceptance form -->
<div class="terms-form">
  <wa-checkbox required>I accept the terms and conditions</wa-checkbox>
  <wa-checkbox>I want to receive promotional emails</wa-checkbox>
  <button type="submit">Continue</button>
</div>

<!-- In a task list -->
<div class="task-list">
  <div class="task-item">
    <wa-checkbox checked>Complete project setup</wa-checkbox>
  </div>
  <div class="task-item">
    <wa-checkbox>Write documentation</wa-checkbox>
  </div>
  <div class="task-item">
    <wa-checkbox>Deploy to production</wa-checkbox>
  </div>
</div>
```
