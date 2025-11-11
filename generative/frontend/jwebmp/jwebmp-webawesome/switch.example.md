# Switch Examples

## Basic Usage

```html
<wa-switch waSwitch></wa-switch>
```

## Disabled State

```html
<wa-switch waSwitch disabled></wa-switch>
```

## With Hint Text

```html
<wa-switch waSwitch hint="Enable feature"></wa-switch>
```

## Different Sizes

```html
<!-- Small size -->
<wa-switch waSwitch size="small"></wa-switch>

<!-- Medium size (default) -->
<wa-switch waSwitch size="medium"></wa-switch>

<!-- Large size -->
<wa-switch waSwitch size="large"></wa-switch>
```

## Custom Styling

```html
<!-- Custom background color -->
<wa-switch waSwitch [backgroundColor]="'#e0e0e0'" [backgroundColorChecked]="'#4CAF50'"></wa-switch>

<!-- Custom border -->
<wa-switch waSwitch [borderColor]="'#999'" [borderColorChecked]="'#2196F3'" [borderWidth]="'2px'" [borderStyle]="'solid'"></wa-switch>

<!-- Custom thumb -->
<wa-switch waSwitch [thumbColor]="'#fff'" [thumbColorChecked]="'#fff'" [thumbSize]="'16px'" [thumbShadow]="'0 0 4px rgba(0,0,0,0.3)'"></wa-switch>

<!-- Custom dimensions -->
<wa-switch waSwitch [width]="'60px'" [height]="'30px'"></wa-switch>

<!-- Combined custom styling -->
<wa-switch 
  waSwitch 
  [backgroundColor]="'#f0f0f0'" 
  [backgroundColorChecked]="'#673AB7'" 
  [borderColor]="'#ccc'" 
  [borderColorChecked]="'#512DA8'" 
  [borderWidth]="'1px'" 
  [borderStyle]="'solid'" 
  [thumbColor]="'#fff'" 
  [thumbColorChecked]="'#fff'" 
  [thumbSize]="'18px'" 
  [thumbShadow]="'0 0 3px rgba(0,0,0,0.2)'" 
  [width]="'50px'" 
  [height]="'26px'"
></wa-switch>
```

## Using with Angular Forms

```typescript
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { WaSwitchDirective } from '@angular-awesome/directives/switch';

@Component({
  selector: 'app-switch-demo',
  template: `
    <div class="form-group">
      <wa-switch waSwitch [(ngModel)]="isEnabled" hint="Enable feature"></wa-switch>
      <p>Feature is {{ isEnabled ? 'enabled' : 'disabled' }}</p>
    </div>
    
    <div class="form-group">
      <wa-switch waSwitch [(ngModel)]="darkMode" hint="Dark mode"></wa-switch>
      <p>Dark mode is {{ darkMode ? 'on' : 'off' }}</p>
    </div>
  `,
  standalone: true,
  imports: [WaSwitchDirective, FormsModule]
})
export class SwitchDemoComponent {
  isEnabled = false;
  darkMode = true;
}
```

## Event Handling

```typescript
import { Component } from '@angular/core';
import { WaSwitchDirective } from '@angular-awesome/directives/switch';

@Component({
  selector: 'app-switch-events-demo',
  template: `
    <wa-switch 
      waSwitch 
      [hint]="'Notifications'"
      (changeEvent)="onSwitchChange($event)"
      (inputEvent)="onSwitchInput($event)"
      (focusEvent)="onSwitchFocus($event)"
      (blurEvent)="onSwitchBlur($event)"
    ></wa-switch>
    
    <div class="event-log">
      <p>Last event: {{ lastEvent }}</p>
    </div>
  `,
  standalone: true,
  imports: [WaSwitchDirective]
})
export class SwitchEventsDemoComponent {
  lastEvent = 'None';
  
  onSwitchChange(event: Event) {
    const target = event.target as HTMLInputElement;
    this.lastEvent = `Change: ${target.checked ? 'checked' : 'unchecked'}`;
    console.log('Switch changed:', target.checked);
  }
  
  onSwitchInput(event: Event) {
    const target = event.target as HTMLInputElement;
    this.lastEvent = `Input: ${target.checked ? 'checked' : 'unchecked'}`;
    console.log('Switch input:', target.checked);
  }
  
  onSwitchFocus(event: FocusEvent) {
    this.lastEvent = 'Focus';
    console.log('Switch focused');
  }
  
  onSwitchBlur(event: FocusEvent) {
    this.lastEvent = 'Blur';
    console.log('Switch blurred');
  }
}
```

## Reactive Forms

```typescript
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { WaSwitchDirective } from '@angular-awesome/directives/switch';

@Component({
  selector: 'app-switch-reactive-form-demo',
  template: `
    <form [formGroup]="settingsForm" (ngSubmit)="onSubmit()">
      <div class="form-group">
        <wa-switch waSwitch formControlName="notifications" hint="Enable notifications"></wa-switch>
      </div>
      
      <div class="form-group">
        <wa-switch waSwitch formControlName="darkMode" hint="Dark mode"></wa-switch>
      </div>
      
      <div class="form-group">
        <wa-switch waSwitch formControlName="autoSave" hint="Auto-save" [disabled]="!settingsForm.get('notifications')?.value"></wa-switch>
        <p class="hint">Auto-save requires notifications to be enabled</p>
      </div>
      
      <button type="submit">Save Settings</button>
    </form>
    
    <div *ngIf="submitted">
      <h3>Saved Settings:</h3>
      <pre>{{ settingsForm.value | json }}</pre>
    </div>
  `,
  standalone: true,
  imports: [WaSwitchDirective, ReactiveFormsModule]
})
export class SwitchReactiveFormDemoComponent implements OnInit {
  settingsForm!: FormGroup;
  submitted = false;
  
  constructor(private fb: FormBuilder) {}
  
  ngOnInit() {
    this.settingsForm = this.fb.group({
      notifications: [true],
      darkMode: [false],
      autoSave: [false]
    });
    
    // Disable autoSave when notifications are off
    this.settingsForm.get('notifications')?.valueChanges.subscribe(value => {
      const autoSaveControl = this.settingsForm.get('autoSave');
      if (!value) {
        autoSaveControl?.setValue(false);
        autoSaveControl?.disable();
      } else {
        autoSaveControl?.enable();
      }
    });
  }
  
  onSubmit() {
    this.submitted = true;
    console.log('Form submitted:', this.settingsForm.value);
  }
}
```
