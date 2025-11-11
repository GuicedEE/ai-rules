# Menu Examples

## Basic Usage

```html
<wa-menu>
  <wa-menu-item>Item 1</wa-menu-item>
  <wa-menu-item>Item 2</wa-menu-item>
  <wa-menu-item>Item 3</wa-menu-item>
</wa-menu>
```

## Different Sizes

```html
<wa-menu size="small">
  <wa-menu-item>Small Item 1</wa-menu-item>
  <wa-menu-item>Small Item 2</wa-menu-item>
</wa-menu>

<wa-menu size="medium">
  <wa-menu-item>Medium Item 1</wa-menu-item>
  <wa-menu-item>Medium Item 2</wa-menu-item>
</wa-menu>

<wa-menu size="large">
  <wa-menu-item>Large Item 1</wa-menu-item>
  <wa-menu-item>Large Item 2</wa-menu-item>
</wa-menu>
```

## With Labels

```html
<wa-menu>
  <wa-menu-label>Fruits</wa-menu-label>
  <wa-menu-item>Apple</wa-menu-item>
  <wa-menu-item>Banana</wa-menu-item>
  <wa-menu-item>Orange</wa-menu-item>

  <wa-menu-label>Vegetables</wa-menu-label>
  <wa-menu-item>Carrot</wa-menu-item>
  <wa-menu-item>Broccoli</wa-menu-item>
  <wa-menu-item>Spinach</wa-menu-item>
</wa-menu>
```

## With Checkboxes

```html
<wa-menu>
  <wa-menu-label>Select Options</wa-menu-label>
  <wa-menu-item type="checkbox">Option 1</wa-menu-item>
  <wa-menu-item type="checkbox" [checked]="true">Option 2</wa-menu-item>
  <wa-menu-item type="checkbox">Option 3</wa-menu-item>
</wa-menu>
```

## With Values

```html
<wa-menu (select)="onSelect($event)">
  <wa-menu-item value="item1">Item 1</wa-menu-item>
  <wa-menu-item value="item2">Item 2</wa-menu-item>
  <wa-menu-item value="item3">Item 3</wa-menu-item>
</wa-menu>
```

## Disabled Items

```html
<wa-menu>
  <wa-menu-item>Enabled Item</wa-menu-item>
  <wa-menu-item [disabled]="true">Disabled Item</wa-menu-item>
  <wa-menu-item>Enabled Item</wa-menu-item>
</wa-menu>
```

## Loading State

```html
<wa-menu>
  <wa-menu-item>Normal Item</wa-menu-item>
  <wa-menu-item [loading]="true">Loading Item</wa-menu-item>
  <wa-menu-item>Normal Item</wa-menu-item>
</wa-menu>
```

## With Submenus

```html
<wa-menu>
  <wa-menu-item>Item 1</wa-menu-item>
  <wa-menu-item [withSubmenu]="true">
    Item with Submenu
    <wa-menu slot="submenu">
      <wa-menu-item>Submenu Item 1</wa-menu-item>
      <wa-menu-item>Submenu Item 2</wa-menu-item>
      <wa-menu-item>Submenu Item 3</wa-menu-item>
    </wa-menu>
  </wa-menu-item>
  <wa-menu-item>Item 3</wa-menu-item>
</wa-menu>
```

## Nested Submenus

```html
<wa-menu>
  <wa-menu-item>Item 1</wa-menu-item>
  <wa-menu-item [withSubmenu]="true">
    Item with Submenu
    <wa-menu slot="submenu">
      <wa-menu-item>Submenu Item 1</wa-menu-item>
      <wa-menu-item [withSubmenu]="true">
        Nested Submenu
        <wa-menu slot="submenu">
          <wa-menu-item>Nested Item 1</wa-menu-item>
          <wa-menu-item>Nested Item 2</wa-menu-item>
        </wa-menu>
      </wa-menu-item>
      <wa-menu-item>Submenu Item 3</wa-menu-item>
    </wa-menu>
  </wa-menu-item>
  <wa-menu-item>Item 3</wa-menu-item>
</wa-menu>
```

## Custom Styling

```html
<!-- Menu styling -->
<wa-menu 
  [padding]="'12px'" 
  [margin]="'8px'" 
  [borderRadius]="'8px'" 
  [background]="'#f8f9fa'" 
  [boxShadow]="'0 2px 10px rgba(0,0,0,0.1)'" 
  [border]="'1px solid #dee2e6'"
  [fontSize]="'14px'">
  <wa-menu-item>Custom Styled Item 1</wa-menu-item>
  <wa-menu-item>Custom Styled Item 2</wa-menu-item>
</wa-menu>

<!-- Menu item styling -->
<wa-menu>
  <wa-menu-item 
    [backgroundColorHover]="'#e9ecef'" 
    [textColorHover]="'#007bff'" 
    [padding]="'10px 16px'">
    Custom Hover Item
  </wa-menu-item>
  <wa-menu-item>Normal Item</wa-menu-item>
</wa-menu>

<!-- Menu label styling -->
<wa-menu>
  <wa-menu-label 
    [padding]="'8px 16px'" 
    [fontSize]="'12px'" 
    [color]="'#6c757d'" 
    [margin]="'4px 0'">
    Custom Label
  </wa-menu-label>
  <wa-menu-item>Item 1</wa-menu-item>
  <wa-menu-item>Item 2</wa-menu-item>
</wa-menu>
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-menu-demo',
  template: `
    <wa-menu 
      [size]="menuSize" 
      (select)="onMenuSelect($event)">
      <wa-menu-item 
        *ngFor="let item of menuItems" 
        [value]="item.value" 
        [disabled]="item.disabled" 
        [loading]="item.loading">
        {{ item.label }}
      </wa-menu-item>
    </wa-menu>
  `
})
export class MenuDemoComponent {
  menuSize = 'medium';
  menuItems = [
    { label: 'Item 1', value: 'item1', disabled: false, loading: false },
    { label: 'Item 2', value: 'item2', disabled: true, loading: false },
    { label: 'Item 3', value: 'item3', disabled: false, loading: true }
  ];

  onMenuSelect(event: CustomEvent): void {
    console.log('Selected item:', event.detail);
  }
}
```

## Using with ngModel for Checkbox Items

```html
<form #optionsForm="ngForm">
  <wa-menu>
    <wa-menu-label>Select Options</wa-menu-label>
    <wa-menu-item 
      type="checkbox" 
      name="option1" 
      [(ngModel)]="options.option1">
      Option 1
    </wa-menu-item>
    <wa-menu-item 
      type="checkbox" 
      name="option2" 
      [(ngModel)]="options.option2">
      Option 2
    </wa-menu-item>
    <wa-menu-item 
      type="checkbox" 
      name="option3" 
      [(ngModel)]="options.option3">
      Option 3
    </wa-menu-item>
  </wa-menu>

  <div>Selected options: {{ options | json }}</div>
</form>
```

## Accessing Methods Programmatically

```typescript
import { Component, ViewChild } from '@angular/core';
import { WaMenuItemDirective } from './menu.directive';

@Component({
  selector: 'app-menu-demo',
  template: `
    <wa-menu>
      <wa-menu-item>Item 1</wa-menu-item>
      <wa-menu-item #specialItem>Special Item</wa-menu-item>
      <wa-menu-item>Item 3</wa-menu-item>
    </wa-menu>
    <button (click)="focusSpecialItem()">Focus Special Item</button>
  `
})
export class MenuDemoComponent {
  @ViewChild('specialItem') specialItem!: WaMenuItemDirective;

  focusSpecialItem(): void {
    // Access the native element and focus it
    this.specialItem.nativeElement.focus();
  }
}
```

## Real-World Example: Navigation Menu

```html
<wa-menu 
  [borderRadius]="'4px'" 
  [boxShadow]="'0 2px 8px rgba(0,0,0,0.15)'" 
  [background]="'#ffffff'"
  (select)="onNavigate($event)">

  <wa-menu-label [color]="'#6c757d'" [fontSize]="'12px'">
    Main Navigation
  </wa-menu-label>

  <wa-menu-item value="dashboard">
    <wa-icon name="home" slot="prefix"></wa-icon>
    Dashboard
  </wa-menu-item>

  <wa-menu-item value="profile">
    <wa-icon name="user" slot="prefix"></wa-icon>
    Profile
  </wa-menu-item>

  <wa-menu-item [withSubmenu]="true">
    <wa-icon name="settings" slot="prefix"></wa-icon>
    Settings
    <wa-menu slot="submenu">
      <wa-menu-item value="account">Account Settings</wa-menu-item>
      <wa-menu-item value="privacy">Privacy</wa-menu-item>
      <wa-menu-item value="notifications">Notifications</wa-menu-item>
    </wa-menu>
  </wa-menu-item>

  <wa-menu-label [color]="'#6c757d'" [fontSize]="'12px'">
    Content
  </wa-menu-label>

  <wa-menu-item value="posts">
    <wa-icon name="file-text" slot="prefix"></wa-icon>
    Posts
  </wa-menu-item>

  <wa-menu-item value="media">
    <wa-icon name="image" slot="prefix"></wa-icon>
    Media
  </wa-menu-item>

  <wa-menu-item value="comments">
    <wa-icon name="message-circle" slot="prefix"></wa-icon>
    Comments
  </wa-menu-item>

  <wa-menu-label [color]="'#6c757d'" [fontSize]="'12px'">
    Account
  </wa-menu-label>

  <wa-menu-item value="help">
    <wa-icon name="help-circle" slot="prefix"></wa-icon>
    Help
  </wa-menu-item>

  <wa-menu-item value="logout" [textColorHover]="'#dc3545'">
    <wa-icon name="log-out" slot="prefix"></wa-icon>
    Logout
  </wa-menu-item>
</wa-menu>
```
