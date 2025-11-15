# Input Examples

## Basic Usage

```html
<wa-input label="Username"></wa-input>
```

## Different Types

```html
<wa-input label="Text Input" type="text"></wa-input>
<wa-input label="Password" type="password"></wa-input>
<wa-input label="Email" type="email"></wa-input>
<wa-input label="Number" type="number"></wa-input>
<wa-input label="Date" type="date"></wa-input>
<wa-input label="Time" type="time"></wa-input>
<wa-input label="URL" type="url"></wa-input>
<wa-input label="Search" type="search"></wa-input>
<wa-input label="Tel" type="tel"></wa-input>
```

## With Different Sizes

```html
<wa-input label="Small Input" size="small"></wa-input>
<wa-input label="Medium Input" size="medium"></wa-input>
<wa-input label="Large Input" size="large"></wa-input>
```

## Appearances

```html
<wa-input label="Filled Input" appearance="filled"></wa-input>
<wa-input label="Outlined Input" appearance="outlined"></wa-input>
<wa-input label="Pill Input" [pill]="true"></wa-input>
```

## With Placeholder and Hint

```html
<wa-input 
  label="Username" 
  placeholder="Enter your username"
  hint="Username must be at least 3 characters">
</wa-input>

<!-- Using HTML in hint -->
<wa-input label="Password">
  <div slot="hint">
    Password must contain at least <strong>8 characters</strong>
  </div>
</wa-input>
```

## Clearable Input

```html
<wa-input 
  label="Clearable Input" 
  [clearable]="true"
  placeholder="Type something and clear it">
</wa-input>
```

## Password Toggle

```html
<wa-input 
  label="Password" 
  type="password"
  [passwordToggle]="true">
</wa-input>

<!-- With initial visibility -->
<wa-input 
  label="Password" 
  type="password"
  [passwordToggle]="true"
  [passwordVisible]="true">
</wa-input>
```

## Number Input Features

```html
<wa-input 
  label="Number with Min/Max" 
  type="number"
  min="0"
  max="100">
</wa-input>

<wa-input 
  label="Number with Step" 
  type="number"
  min="0"
  max="100"
  step="5">
</wa-input>

<wa-input 
  label="Number without Spin Buttons" 
  type="number"
  [noSpinButtons]="true">
</wa-input>
```

## Validation

```html
<wa-input 
  label="Required Input" 
  [required]="true">
</wa-input>

<wa-input 
  label="Email Validation" 
  type="email"
  [required]="true">
</wa-input>

<wa-input 
  label="Pattern Validation" 
  pattern="[A-Za-z]{3,}"
  hint="Enter at least 3 letters">
</wa-input>

<wa-input 
  label="Length Validation" 
  minlength="3"
  maxlength="10"
  hint="Between 3 and 10 characters">
</wa-input>
```

## Disabled and Readonly States

```html
<wa-input 
  label="Disabled Input" 
  value="Cannot be edited"
  [disabled]="true">
</wa-input>

<wa-input 
  label="Readonly Input" 
  value="Cannot be edited but can be focused"
  [readonly]="true">
</wa-input>
```

## Custom Styling

```html
<!-- Using style inputs -->
<wa-input 
  label="Custom Styled Input" 
  [backgroundColor]="'#f8f9fa'"
  [borderColor]="'#6c757d'"
  [borderWidth]="'2px'"
  [boxShadow]="'0 2px 4px rgba(0,0,0,0.1)'">
</wa-input>

<!-- Dynamic styling -->
<wa-input 
  label="Dynamic Styled Input" 
  [backgroundColor]="isDarkMode ? '#333333' : '#ffffff'"
  [borderColor]="isDarkMode ? '#6c757d' : '#ced4da'">
</wa-input>
```

## Using with Angular Bindings

```html
<wa-input 
  [label]="inputLabel" 
  [type]="inputType" 
  [value]="inputValue" 
  [placeholder]="inputPlaceholder" 
  [required]="isRequired"
  [disabled]="isDisabled"
  (input)="onInput($event)" 
  (change)="onChange($event)" 
  (focusEvent)="onFocus()" 
  (blurEvent)="onBlur()"
  (waClear)="onClear()">
</wa-input>
```

## Using with ngModel

```html
<form #userForm="ngForm">
  <wa-input 
    label="Username" 
    name="username" 
    [(ngModel)]="user.username" 
    required>
  </wa-input>

  <wa-input 
    label="Email" 
    type="email" 
    name="email" 
    [(ngModel)]="user.email" 
    required>
  </wa-input>

  <button type="submit" [disabled]="userForm.invalid">Submit</button>
</form>
```

## Accessing Methods Programmatically

```typescript
import { Component, ViewChild } from '@angular/core';
import { WaInputDirective } from './input.directive';

@Component({
  selector: 'app-input-demo',
  template: `
    <wa-input #usernameInput label="Username"></wa-input>
    <button (click)="focusInput()">Focus</button>
    <button (click)="selectInput()">Select All</button>
  `
})
export class InputDemoComponent {
  @ViewChild('usernameInput') usernameInput!: WaInputDirective;

  focusInput(): void {
    this.usernameInput.focus();
  }

  selectInput(): void {
    this.usernameInput.select();
  }
}
```

## Using Custom HTML Labels

```html
<wa-input>
  <div slot="label">
    Username <wa-icon name="user"></wa-icon>
  </div>
</wa-input>
```

## Form Integration

```html
<form #loginForm="ngForm" (ngSubmit)="login()">
  <div class="form-group">
    <wa-input 
      label="Username" 
      name="username" 
      [(ngModel)]="loginData.username" 
      required>
    </wa-input>
  </div>

  <div class="form-group">
    <wa-input 
      label="Password" 
      type="password" 
      name="password" 
      [(ngModel)]="loginData.password" 
      [passwordToggle]="true"
      required>
    </wa-input>
  </div>

  <button type="submit" [disabled]="loginForm.invalid">Login</button>
</form>
```

## Real-World Example: Registration Form

```html
<form #registrationForm="ngForm" (ngSubmit)="register()">
  <h2>Create Account</h2>

  <div class="form-row">
    <wa-input 
      label="First Name" 
      name="firstName" 
      [(ngModel)]="user.firstName" 
      required>
    </wa-input>

    <wa-input 
      label="Last Name" 
      name="lastName" 
      [(ngModel)]="user.lastName" 
      required>
    </wa-input>
  </div>

  <wa-input 
    label="Email" 
    type="email" 
    name="email" 
    [(ngModel)]="user.email" 
    required
    autocomplete="email">
  </wa-input>

  <wa-input 
    label="Username" 
    name="username" 
    [(ngModel)]="user.username" 
    required
    minlength="3"
    maxlength="20"
    pattern="[A-Za-z0-9_]+"
    hint="3-20 characters, letters, numbers, and underscores only">
  </wa-input>

  <wa-input 
    label="Password" 
    type="password" 
    name="password" 
    [(ngModel)]="user.password" 
    [passwordToggle]="true"
    required
    minlength="8"
    hint="At least 8 characters">
  </wa-input>

  <wa-input 
    label="Confirm Password" 
    type="password" 
    name="confirmPassword" 
    [(ngModel)]="user.confirmPassword" 
    [passwordToggle]="true"
    required>
  </wa-input>

  <wa-input 
    label="Phone Number" 
    type="tel" 
    name="phone" 
    [(ngModel)]="user.phone"
    pattern="[0-9]{10}"
    hint="10-digit phone number">
  </wa-input>

  <button type="submit" [disabled]="registrationForm.invalid">Create Account</button>
</form>
```
