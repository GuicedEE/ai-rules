# Dialog Examples

## Basic Usage

```html
<wa-dialog label="Basic Dialog" [(open)]="isOpen">
  <p>This is a basic dialog with default styling.</p>
  <wa-button slot="footer" data-dialog="close">Close</wa-button>
</wa-dialog>

<wa-button (click)="isOpen = true">Open Dialog</wa-button>
```

```typescript
// In your component
export class DialogExampleComponent {
  isOpen = false;
}
```

## Without Header

```html
<wa-dialog label="No Header Dialog" [(open)]="isNoHeaderOpen" withoutHeader>
  <p>This dialog has no header section.</p>
  <wa-button slot="footer" data-dialog="close">Close</wa-button>
</wa-dialog>

<wa-button (click)="isNoHeaderOpen = true">Open No Header Dialog</wa-button>
```

## With Light Dismiss

```html
<wa-dialog 
  label="Light Dismiss Dialog" 
  [(open)]="isLightDismissOpen" 
  lightDismiss>
  <p>Click outside this dialog to close it.</p>
  <wa-button slot="footer" data-dialog="close">Close</wa-button>
</wa-dialog>

<wa-button (click)="isLightDismissOpen = true">Open Light Dismiss Dialog</wa-button>
```

## With Custom Header Actions

```html
<wa-dialog label="Custom Header Dialog" [(open)]="isCustomHeaderOpen">
  <wa-icon-button 
    slot="header-actions" 
    name="info-circle"
    aria-label="More information">
  </wa-icon-button>
  
  <p>This dialog has custom actions in the header.</p>
  <wa-button slot="footer" data-dialog="close">Close</wa-button>
</wa-dialog>

<wa-button (click)="isCustomHeaderOpen = true">Open Custom Header Dialog</wa-button>
```

## Programmatic Control

```html
<wa-dialog #myDialog label="Programmatic Dialog">
  <p>This dialog is controlled programmatically.</p>
  <wa-button slot="footer" data-dialog="close">Close</wa-button>
</wa-dialog>

<wa-button (click)="openDialog()">Open Dialog</wa-button>
<wa-button (click)="closeDialog()">Close Dialog</wa-button>
```

```typescript
// In your component
export class DialogExampleComponent {
  @ViewChild('myDialog') dialogRef: ElementRef;

  openDialog() {
    this.dialogRef.nativeElement.show();
  }

  closeDialog() {
    this.dialogRef.nativeElement.hide();
  }
}
```

## Event Handling

```html
<wa-dialog 
  label="Event Dialog" 
  [(open)]="isEventOpen"
  (waShow)="onDialogShow()"
  (waAfterShow)="onDialogAfterShow()"
  (waHide)="onDialogHide($event)"
  (waAfterHide)="onDialogAfterHide()">
  
  <p>This dialog demonstrates event handling.</p>
  <wa-button slot="footer" data-dialog="close">Close</wa-button>
</wa-dialog>

<wa-button (click)="isEventOpen = true">Open Event Dialog</wa-button>
```

```typescript
// In your component
export class DialogExampleComponent {
  isEventOpen = false;

  onDialogShow() {
    console.log('Dialog is opening');
  }

  onDialogAfterShow() {
    console.log('Dialog has opened');
  }

  onDialogHide(event: { source: HTMLElement | 'overlay' | 'escape' | 'programmatic' }) {
    console.log('Dialog is closing', event.source);
    
    // Optionally prevent closing
    if (event.source === 'escape' && this.hasUnsavedChanges) {
      event.preventDefault();
      // Show confirmation
    }
  }

  onDialogAfterHide() {
    console.log('Dialog has closed');
  }
}
```

## Custom Styling

```html
<wa-dialog 
  label="Styled Dialog" 
  [(open)]="isStyledOpen"
  backgroundColor="#f8f9fa"
  borderRadius="16px"
  boxShadow="0 8px 16px rgba(0,0,0,0.15)"
  spacing="24px"
  width="600px"
  showDuration="500ms"
  hideDuration="300ms">
  
  <p>This dialog has custom styling applied.</p>
  <wa-button slot="footer" data-dialog="close">Close</wa-button>
</wa-dialog>

<wa-button (click)="isStyledOpen = true">Open Styled Dialog</wa-button>
```

## Complex Dialog with Form

```html
<wa-dialog 
  label="Edit Profile" 
  [(open)]="isFormOpen"
  (waHide)="onFormDialogHide($event)">
  
  <form #profileForm="ngForm">
    <div class="form-group">
      <label for="name">Name</label>
      <wa-input id="name" [(ngModel)]="profile.name" name="name" required></wa-input>
    </div>
    
    <div class="form-group">
      <label for="email">Email</label>
      <wa-input id="email" [(ngModel)]="profile.email" name="email" required type="email"></wa-input>
    </div>
  </form>
  
  <div slot="footer">
    <wa-button variant="secondary" data-dialog="close">Cancel</wa-button>
    <wa-button 
      variant="primary" 
      [disabled]="profileForm.invalid"
      (click)="saveProfile(); isFormOpen = false;">
      Save
    </wa-button>
  </div>
</wa-dialog>

<wa-button (click)="isFormOpen = true">Edit Profile</wa-button>
```

```typescript
// In your component
export class DialogExampleComponent {
  isFormOpen = false;
  profile = {
    name: 'John Doe',
    email: 'john@example.com'
  };
  hasUnsavedChanges = false;

  onFormDialogHide(event: { source: HTMLElement | 'overlay' | 'escape' | 'programmatic' }) {
    if (this.hasUnsavedChanges && (event.source === 'escape' || event.source === 'overlay')) {
      // Prevent dialog from closing
      event.preventDefault();
      
      // Show confirmation
      if (confirm('You have unsaved changes. Are you sure you want to close?')) {
        this.hasUnsavedChanges = false;
        this.isFormOpen = false;
      }
    }
  }

  saveProfile() {
    // Save profile logic
    console.log('Profile saved:', this.profile);
    this.hasUnsavedChanges = false;
  }
}
```

## Confirmation Dialog

```html
<wa-dialog 
  label="Confirm Action" 
  [(open)]="isConfirmOpen">
  
  <p>Are you sure you want to delete this item? This action cannot be undone.</p>
  
  <div slot="footer">
    <wa-button variant="secondary" data-dialog="close">Cancel</wa-button>
    <wa-button 
      variant="danger" 
      (click)="deleteItem(); isConfirmOpen = false;">
      Delete
    </wa-button>
  </div>
</wa-dialog>

<wa-button variant="danger" (click)="isConfirmOpen = true">Delete Item</wa-button>
```

## Accessibility Example

```html
<wa-dialog 
  label="Accessible Dialog"
  [(open)]="isAccessibleOpen">
  
  <p>This dialog follows accessibility best practices:</p>
  <ul>
    <li>Proper labeling with the label attribute</li>
    <li>Focus is trapped inside the dialog when open</li>
    <li>ESC key closes the dialog</li>
    <li>First focusable element receives focus when opened</li>
  </ul>
  
  <div slot="footer">
    <wa-button autofocus data-dialog="close">Close</wa-button>
  </div>
</wa-dialog>

<wa-button (click)="isAccessibleOpen = true">Open Accessible Dialog</wa-button>
```

## Dialog with Autofocus

```html
<wa-dialog 
  label="Autofocus Dialog" 
  [(open)]="isAutofocusOpen">
  
  <p>The input field below will receive focus when the dialog opens:</p>
  <wa-input autofocus placeholder="This will be focused"></wa-input>
  
  <div slot="footer">
    <wa-button data-dialog="close">Close</wa-button>
  </div>
</wa-dialog>

<wa-button (click)="isAutofocusOpen = true">Open Autofocus Dialog</wa-button>
```
