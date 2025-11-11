# Drawer Examples

## Basic Usage

```html
<wa-drawer label="Basic Drawer" [(open)]="isOpen">
  <p>This is a basic drawer with default styling.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="isOpen = true">Open Drawer</wa-button>
```

```typescript
// In your component
export class DrawerExampleComponent {
  isOpen = false;
}
```

## Different Placements

```html
<!-- Right side drawer (default) -->
<wa-drawer label="End Drawer" [(open)]="isEndOpen" placement="end">
  <p>This drawer slides in from the right (end).</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<!-- Left side drawer -->
<wa-drawer label="Start Drawer" [(open)]="isStartOpen" placement="start">
  <p>This drawer slides in from the left (start).</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<!-- Top drawer -->
<wa-drawer label="Top Drawer" [(open)]="isTopOpen" placement="top">
  <p>This drawer slides in from the top.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<!-- Bottom drawer -->
<wa-drawer label="Bottom Drawer" [(open)]="isBottomOpen" placement="bottom">
  <p>This drawer slides in from the bottom.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<div class="button-group">
  <wa-button (click)="isEndOpen = true">Open End Drawer</wa-button>
  <wa-button (click)="isStartOpen = true">Open Start Drawer</wa-button>
  <wa-button (click)="isTopOpen = true">Open Top Drawer</wa-button>
  <wa-button (click)="isBottomOpen = true">Open Bottom Drawer</wa-button>
</div>
```

## Without Header

```html
<wa-drawer label="No Header Drawer" [(open)]="isNoHeaderOpen" withoutHeader>
  <p>This drawer has no header section.</p>
  <wa-button data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="isNoHeaderOpen = true">Open No Header Drawer</wa-button>
```

## With Light Dismiss

```html
<wa-drawer 
  label="Light Dismiss Drawer" 
  [(open)]="isLightDismissOpen" 
  lightDismiss>
  <p>Click outside this drawer to close it.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="isLightDismissOpen = true">Open Light Dismiss Drawer</wa-button>
```

## With Custom Header Actions

```html
<wa-drawer label="Custom Header Drawer" [(open)]="isCustomHeaderOpen">
  <wa-icon-button 
    slot="header-actions" 
    name="info-circle"
    aria-label="More information">
  </wa-icon-button>
  
  <p>This drawer has custom actions in the header.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="isCustomHeaderOpen = true">Open Custom Header Drawer</wa-button>
```

## With Custom Label

```html
<wa-drawer [(open)]="isCustomLabelOpen">
  <div slot="label">
    <wa-icon name="settings"></wa-icon>
    <span>Custom Label with Icon</span>
  </div>
  
  <p>This drawer has a custom label with an icon.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="isCustomLabelOpen = true">Open Custom Label Drawer</wa-button>
```

## Programmatic Control

```html
<wa-drawer #myDrawer label="Programmatic Drawer">
  <p>This drawer is controlled programmatically.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="openDrawer()">Open Drawer</wa-button>
<wa-button (click)="closeDrawer()">Close Drawer</wa-button>
```

```typescript
// In your component
export class DrawerExampleComponent {
  @ViewChild('myDrawer') drawerRef: ElementRef;

  openDrawer() {
    this.drawerRef.nativeElement.show();
  }

  closeDrawer() {
    this.drawerRef.nativeElement.hide();
  }
}
```

## Event Handling

```html
<wa-drawer 
  label="Event Drawer" 
  [(open)]="isEventOpen"
  (showEvent)="onDrawerShow($event)"
  (afterShowEvent)="onDrawerAfterShow($event)"
  (hideEvent)="onDrawerHide($event)"
  (afterHideEvent)="onDrawerAfterHide($event)"
  (focusEvent)="onDrawerFocus($event)"
  (blurEvent)="onDrawerBlur($event)">
  
  <p>This drawer demonstrates event handling.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="isEventOpen = true">Open Event Drawer</wa-button>
```

```typescript
// In your component
export class DrawerExampleComponent {
  isEventOpen = false;

  onDrawerShow(event: CustomEvent) {
    console.log('Drawer is opening', event);
  }

  onDrawerAfterShow(event: CustomEvent) {
    console.log('Drawer has opened', event);
  }

  onDrawerHide(event: CustomEvent) {
    console.log('Drawer is closing', event);
    
    // Optionally prevent closing
    if (this.hasUnsavedChanges) {
      event.preventDefault();
      // Show confirmation
    }
  }

  onDrawerAfterHide(event: CustomEvent) {
    console.log('Drawer has closed', event);
  }

  onDrawerFocus(event: FocusEvent) {
    console.log('Drawer focused', event);
  }

  onDrawerBlur(event: FocusEvent) {
    console.log('Drawer blurred', event);
  }
}
```

## Custom Styling

```html
<wa-drawer 
  label="Styled Drawer" 
  [(open)]="isStyledOpen"
  backgroundColor="#f8f9fa"
  boxShadow="0 0 20px rgba(0,0,0,0.15)"
  spacing="24px"
  size="400px"
  showDuration="500ms"
  hideDuration="300ms">
  
  <p>This drawer has custom styling applied.</p>
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="isStyledOpen = true">Open Styled Drawer</wa-button>
```

## Complex Drawer with Form

```html
<wa-drawer 
  label="Edit Profile" 
  [(open)]="isFormOpen"
  (hideEvent)="onFormDrawerHide($event)">
  
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
    <wa-button variant="secondary" data-drawer="close">Cancel</wa-button>
    <wa-button 
      variant="primary" 
      [disabled]="profileForm.invalid"
      (click)="saveProfile(); isFormOpen = false;">
      Save
    </wa-button>
  </div>
</wa-drawer>

<wa-button (click)="isFormOpen = true">Edit Profile</wa-button>
```

```typescript
// In your component
export class DrawerExampleComponent {
  isFormOpen = false;
  profile = {
    name: 'John Doe',
    email: 'john@example.com'
  };
  hasUnsavedChanges = false;

  onFormDrawerHide(event: CustomEvent) {
    if (this.hasUnsavedChanges) {
      // Prevent drawer from closing
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

## Navigation Drawer

```html
<wa-drawer 
  label="Navigation" 
  [(open)]="isNavOpen"
  placement="start"
  size="250px">
  
  <wa-menu>
    <wa-menu-item (click)="navigate('home'); isNavOpen = false;">
      <wa-icon name="home" slot="prefix"></wa-icon>
      Home
    </wa-menu-item>
    <wa-menu-item (click)="navigate('profile'); isNavOpen = false;">
      <wa-icon name="user" slot="prefix"></wa-icon>
      Profile
    </wa-menu-item>
    <wa-menu-item (click)="navigate('settings'); isNavOpen = false;">
      <wa-icon name="cog" slot="prefix"></wa-icon>
      Settings
    </wa-menu-item>
    <wa-divider></wa-divider>
    <wa-menu-item (click)="logout(); isNavOpen = false;">
      <wa-icon name="sign-out-alt" slot="prefix"></wa-icon>
      Logout
    </wa-menu-item>
  </wa-menu>
</wa-drawer>

<wa-button (click)="isNavOpen = true">Open Navigation</wa-button>
```

```typescript
// In your component
export class DrawerExampleComponent {
  isNavOpen = false;

  navigate(route: string) {
    console.log(`Navigating to ${route}`);
    // Implement navigation logic
  }

  logout() {
    console.log('Logging out');
    // Implement logout logic
  }
}
```

## Drawer with Autofocus

```html
<wa-drawer 
  label="Autofocus Drawer" 
  [(open)]="isAutofocusOpen">
  
  <p>The input field below will receive focus when the drawer opens:</p>
  <wa-input autofocus placeholder="This will be focused"></wa-input>
  
  <div slot="footer">
    <wa-button data-drawer="close">Close</wa-button>
  </div>
</wa-drawer>

<wa-button (click)="isAutofocusOpen = true">Open Autofocus Drawer</wa-button>
```

## Responsive Drawer

```html
<wa-drawer 
  label="Responsive Drawer" 
  [(open)]="isResponsiveOpen"
  [placement]="isMobile ? 'bottom' : 'end'"
  [size]="isMobile ? '80%' : '400px'">
  
  <p>This drawer adapts to screen size.</p>
  <p>Current mode: {{ isMobile ? 'Mobile (bottom)' : 'Desktop (end)' }}</p>
  
  <wa-button slot="footer" data-drawer="close">Close</wa-button>
</wa-drawer>

<wa-button (click)="isResponsiveOpen = true">Open Responsive Drawer</wa-button>
```

```typescript
// In your component
export class DrawerExampleComponent {
  isResponsiveOpen = false;
  isMobile = window.innerWidth < 768;
  
  @HostListener('window:resize')
  onResize() {
    this.isMobile = window.innerWidth < 768;
  }
}
```
