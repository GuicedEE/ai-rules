# Textarea Examples

## Basic Usage

```html
<waTextarea></waTextarea>
```

## With Label and Placeholder

```html
<waTextarea label="Comments" placeholder="Enter your comments here"></waTextarea>
```

## With Hint

```html
<waTextarea 
  label="Feedback" 
  hint="Please provide detailed feedback"
  placeholder="Enter your feedback"
></waTextarea>
```

## Different Sizes

```html
<!-- Small size -->
<waTextarea label="Small" size="small"></waTextarea>

<!-- Medium size (default) -->
<waTextarea label="Medium" size="medium"></waTextarea>

<!-- Large size -->
<waTextarea label="Large" size="large"></waTextarea>
```

## Different Appearances

```html
<!-- Filled appearance -->
<waTextarea label="Filled" appearance="filled"></waTextarea>

<!-- Outlined appearance -->
<waTextarea label="Outlined" appearance="outlined"></waTextarea>
```

## Rows and Resize Options

```html
<!-- Specify number of rows -->
<waTextarea label="Fixed Rows" rows="5"></waTextarea>

<!-- No resize -->
<waTextarea label="No Resize" resize="none"></waTextarea>

<!-- Vertical resize only -->
<waTextarea label="Vertical Resize" resize="vertical"></waTextarea>

<!-- Horizontal resize only -->
<waTextarea label="Horizontal Resize" resize="horizontal"></waTextarea>

<!-- Both directions resize -->
<waTextarea label="Both Directions" resize="both"></waTextarea>

<!-- Auto resize -->
<waTextarea label="Auto Resize" resize="auto"></waTextarea>
```

## Validation

```html
<!-- Required textarea -->
<waTextarea label="Required Field" [required]="true"></waTextarea>

<!-- Min and max length -->
<waTextarea 
  label="Character Count" 
  [minlength]="10" 
  [maxlength]="100"
  hint="Enter between 10 and 100 characters"
></waTextarea>
```

## States

```html
<!-- Disabled state -->
<waTextarea label="Disabled" [disabled]="true"></waTextarea>

<!-- Read-only state -->
<waTextarea 
  label="Read Only" 
  [readonly]="true" 
  value="This content cannot be edited"
></waTextarea>
```

## Custom Styling

```html
<!-- Custom background color -->
<waTextarea 
  label="Custom Background" 
  [backgroundColor]="'#f5f5f5'"
></waTextarea>

<!-- Custom border -->
<waTextarea 
  label="Custom Border" 
  [borderColor]="'#2196F3'" 
  [borderWidth]="'2px'"
></waTextarea>

<!-- Custom box shadow -->
<waTextarea 
  label="Custom Shadow" 
  [boxShadow]="'0 4px 8px rgba(0,0,0,0.1)'"
></waTextarea>

<!-- Combined custom styling -->
<waTextarea 
  label="Custom Styling" 
  [backgroundColor]="'#f0f8ff'" 
  [borderColor]="'#4CAF50'" 
  [borderWidth]="'1px'" 
  [boxShadow]="'0 2px 4px rgba(0,0,0,0.1)'"
></waTextarea>
```

## Input Modes and Attributes

```html
<!-- Email input mode -->
<waTextarea 
  label="Email Message" 
  inputmode="email" 
  autocomplete="email"
></waTextarea>

<!-- URL input mode -->
<waTextarea 
  label="Website Description" 
  inputmode="url"
></waTextarea>

<!-- With autocapitalize -->
<waTextarea 
  label="Capitalize Sentences" 
  autocapitalize="sentences"
></waTextarea>

<!-- With spellcheck -->
<waTextarea 
  label="Spellcheck" 
  [spellcheck]="true"
></waTextarea>
```

## Using with Angular Forms

### Template-driven Forms

```typescript
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { WaTextareaComponent } from '@angular-awesome/directives/text-area';

@Component({
  selector: 'app-textarea-demo',
  template: `
    <form #form="ngForm" (ngSubmit)="onSubmit(form.value)">
      <waTextarea
        label="Comments"
        hint="Please provide your feedback"
        [(ngModel)]="feedback.comments"
        name="comments"
        [required]="true"
        [minlength]="10"
      ></waTextarea>
      
      <div class="form-actions">
        <button type="submit" [disabled]="form.invalid">Submit</button>
      </div>
      
      <div *ngIf="submitted">
        <h3>Submitted Feedback:</h3>
        <p>{{ feedback.comments }}</p>
      </div>
    </form>
  `,
  standalone: true,
  imports: [FormsModule, WaTextareaComponent]
})
export class TextareaDemoComponent {
  feedback = {
    comments: ''
  };
  submitted = false;
  
  onSubmit(formValue: any) {
    this.submitted = true;
    console.log('Form submitted:', formValue);
  }
}
```

### Reactive Forms

```typescript
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { WaTextareaComponent } from '@angular-awesome/directives/text-area';

@Component({
  selector: 'app-textarea-reactive-demo',
  template: `
    <form [formGroup]="feedbackForm" (ngSubmit)="onSubmit()">
      <waTextarea
        label="Comments"
        hint="Please provide your feedback"
        formControlName="comments"
        [minlength]="10"
        [maxlength]="500"
      ></waTextarea>
      
      <waTextarea
        label="Suggestions"
        hint="Optional suggestions for improvement"
        formControlName="suggestions"
      ></waTextarea>
      
      <div class="form-actions">
        <button type="submit" [disabled]="feedbackForm.invalid">Submit</button>
      </div>
      
      <div *ngIf="submitted">
        <h3>Submitted Feedback:</h3>
        <pre>{{ feedbackForm.value | json }}</pre>
      </div>
    </form>
  `,
  standalone: true,
  imports: [ReactiveFormsModule, WaTextareaComponent]
})
export class TextareaReactiveDemoComponent implements OnInit {
  feedbackForm!: FormGroup;
  submitted = false;
  
  constructor(private fb: FormBuilder) {}
  
  ngOnInit() {
    this.feedbackForm = this.fb.group({
      comments: ['', [Validators.required, Validators.minLength(10), Validators.maxLength(500)]],
      suggestions: ['']
    });
  }
  
  onSubmit() {
    if (this.feedbackForm.valid) {
      this.submitted = true;
      console.log('Form submitted:', this.feedbackForm.value);
    }
  }
}
```

## Event Handling

```typescript
import { Component } from '@angular/core';
import { WaTextareaComponent } from '@angular-awesome/directives/text-area';

@Component({
  selector: 'app-textarea-events-demo',
  template: `
    <waTextarea
      label="Event Demo"
      placeholder="Type something..."
      (focusEvent)="onFocus($event)"
      (blurEvent)="onBlur($event)"
      (inputEvent)="onInput($event)"
      (changeEvent)="onChange($event)"
      (invalid)="onInvalid($event)"
    ></waTextarea>
    
    <div class="event-log">
      <h3>Event Log:</h3>
      <ul>
        <li *ngFor="let event of eventLog">{{ event }}</li>
      </ul>
    </div>
  `,
  standalone: true,
  imports: [WaTextareaComponent]
})
export class TextareaEventsDemoComponent {
  eventLog: string[] = [];
  
  onFocus(event: FocusEvent) {
    this.logEvent('Focus event');
  }
  
  onBlur(event: FocusEvent) {
    this.logEvent('Blur event');
  }
  
  onInput(event: Event) {
    const target = event.target as HTMLTextAreaElement;
    this.logEvent(`Input event: "${target.value}"`);
  }
  
  onChange(event: Event) {
    const target = event.target as HTMLTextAreaElement;
    this.logEvent(`Change event: "${target.value}"`);
  }
  
  onInvalid(event: CustomEvent) {
    this.logEvent(`Invalid event: ${event.detail}`);
  }
  
  private logEvent(message: string) {
    this.eventLog.unshift(`${new Date().toLocaleTimeString()}: ${message}`);
    // Keep only the last 10 events
    if (this.eventLog.length > 10) {
      this.eventLog.pop();
    }
  }
}
```
