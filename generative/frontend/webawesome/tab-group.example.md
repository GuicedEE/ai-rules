# Tab Group Examples

## Basic Usage

```html
<wa-tab-group>
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  <wa-tab panel="tab3">Tab 3</wa-tab>
  
  <wa-tab-panel name="tab1">
    <p>Content for Tab 1</p>
  </wa-tab-panel>
  <wa-tab-panel name="tab2">
    <p>Content for Tab 2</p>
  </wa-tab-panel>
  <wa-tab-panel name="tab3">
    <p>Content for Tab 3</p>
  </wa-tab-panel>
</wa-tab-group>
```

## Different Placements

```html
<!-- Tabs on top (default) -->
<wa-tab-group placement="top">
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
</wa-tab-group>

<!-- Tabs on bottom -->
<wa-tab-group placement="bottom">
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
</wa-tab-group>

<!-- Tabs on start (left) -->
<wa-tab-group placement="start">
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
</wa-tab-group>

<!-- Tabs on end (right) -->
<wa-tab-group placement="end">
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
</wa-tab-group>
```

## Activation Modes

```html
<!-- Auto activation (default) - tabs activate on click -->
<wa-tab-group activation="auto">
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
</wa-tab-group>

<!-- Manual activation - tabs need to be programmatically activated -->
<wa-tab-group activation="manual">
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
</wa-tab-group>
```

## Disabled Tabs

```html
<wa-tab-group>
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2" disabled>Tab 2 (Disabled)</wa-tab>
  <wa-tab panel="tab3">Tab 3</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
  <wa-tab-panel name="tab3">Content for Tab 3</wa-tab-panel>
</wa-tab-group>
```

## Custom Styling

```html
<!-- Custom indicator and track colors -->
<wa-tab-group [indicatorColor]="'#2196F3'" [trackColor]="'#e0e0e0'" [trackWidth]="'2px'">
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
</wa-tab-group>

<!-- Custom active tab color -->
<wa-tab-group>
  <wa-tab panel="tab1" [activeTabColor]="'#4CAF50'">Tab 1</wa-tab>
  <wa-tab panel="tab2" [activeTabColor]="'#FF5722'">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
</wa-tab-group>

<!-- Custom panel padding -->
<wa-tab-group>
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  
  <wa-tab-panel name="tab1" [padding]="'24px'">Content with more padding</wa-tab-panel>
  <wa-tab-panel name="tab2" [padding]="'8px'">Content with less padding</wa-tab-panel>
</wa-tab-group>
```

## No Scroll Controls

```html
<wa-tab-group [noScrollControls]="true">
  <wa-tab panel="tab1">Tab 1</wa-tab>
  <wa-tab panel="tab2">Tab 2</wa-tab>
  <wa-tab panel="tab3">Tab 3</wa-tab>
  <wa-tab panel="tab4">Tab 4</wa-tab>
  <wa-tab panel="tab5">Tab 5</wa-tab>
  
  <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
  <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
  <wa-tab-panel name="tab3">Content for Tab 3</wa-tab-panel>
  <wa-tab-panel name="tab4">Content for Tab 4</wa-tab-panel>
  <wa-tab-panel name="tab5">Content for Tab 5</wa-tab-panel>
</wa-tab-group>
```

## Using with Angular Forms

```typescript
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { WaTabGroupComponent, WaTabComponent, WaTabPanelComponent } from '@angular-awesome/directives/tab-group';

@Component({
  selector: 'app-tab-group-demo',
  template: `
    <wa-tab-group [(ngModel)]="activeTab">
      <wa-tab panel="personal">Personal Info</wa-tab>
      <wa-tab panel="address">Address</wa-tab>
      <wa-tab panel="payment">Payment</wa-tab>
      
      <wa-tab-panel name="personal">
        <h3>Personal Information</h3>
        <p>Enter your personal details here.</p>
      </wa-tab-panel>
      
      <wa-tab-panel name="address">
        <h3>Address Information</h3>
        <p>Enter your address details here.</p>
      </wa-tab-panel>
      
      <wa-tab-panel name="payment">
        <h3>Payment Information</h3>
        <p>Enter your payment details here.</p>
      </wa-tab-panel>
    </wa-tab-group>
    
    <div class="controls">
      <p>Current active tab: {{ activeTab }}</p>
      <button (click)="activeTab = 'personal'">Go to Personal</button>
      <button (click)="activeTab = 'address'">Go to Address</button>
      <button (click)="activeTab = 'payment'">Go to Payment</button>
    </div>
  `,
  standalone: true,
  imports: [WaTabGroupComponent, WaTabComponent, WaTabPanelComponent, FormsModule]
})
export class TabGroupDemoComponent {
  activeTab = 'personal';
}
```

## Event Handling

```typescript
import { Component } from '@angular/core';
import { WaTabGroupComponent, WaTabComponent, WaTabPanelComponent } from '@angular-awesome/directives/tab-group';

@Component({
  selector: 'app-tab-group-events-demo',
  template: `
    <wa-tab-group 
      (tabShow)="onTabShow($event)"
      (tabHide)="onTabHide($event)"
    >
      <wa-tab panel="tab1">Tab 1</wa-tab>
      <wa-tab panel="tab2">Tab 2</wa-tab>
      <wa-tab panel="tab3">Tab 3</wa-tab>
      
      <wa-tab-panel name="tab1">Content for Tab 1</wa-tab-panel>
      <wa-tab-panel name="tab2">Content for Tab 2</wa-tab-panel>
      <wa-tab-panel name="tab3">Content for Tab 3</wa-tab-panel>
    </wa-tab-group>
    
    <div class="event-log">
      <p>Last event: {{ lastEvent }}</p>
    </div>
  `,
  standalone: true,
  imports: [WaTabGroupComponent, WaTabComponent, WaTabPanelComponent]
})
export class TabGroupEventsDemoComponent {
  lastEvent = 'None';
  
  onTabShow(event: CustomEvent) {
    this.lastEvent = `Tab shown: ${event.detail.name}`;
    console.log('Tab shown:', event.detail);
  }
  
  onTabHide(event: CustomEvent) {
    this.lastEvent = `Tab hidden: ${event.detail.name}`;
    console.log('Tab hidden:', event.detail);
  }
}
```

## Dynamic Tabs

```typescript
import { Component } from '@angular/core';
import { WaTabGroupComponent, WaTabComponent, WaTabPanelComponent } from '@angular-awesome/directives/tab-group';
import { NgFor } from '@angular/common';

interface TabItem {
  id: string;
  title: string;
  content: string;
}

@Component({
  selector: 'app-dynamic-tabs-demo',
  template: `
    <div class="controls">
      <button (click)="addTab()">Add Tab</button>
      <button (click)="removeTab()" [disabled]="tabs.length <= 1">Remove Last Tab</button>
    </div>
    
    <wa-tab-group [(ngModel)]="activeTab">
      <wa-tab *ngFor="let tab of tabs" [panel]="tab.id">{{ tab.title }}</wa-tab>
      
      <wa-tab-panel *ngFor="let tab of tabs" [name]="tab.id">
        <p>{{ tab.content }}</p>
      </wa-tab-panel>
    </wa-tab-group>
  `,
  standalone: true,
  imports: [WaTabGroupComponent, WaTabComponent, WaTabPanelComponent, NgFor, FormsModule]
})
export class DynamicTabsDemoComponent {
  tabs: TabItem[] = [
    { id: 'tab1', title: 'Tab 1', content: 'Content for Tab 1' },
    { id: 'tab2', title: 'Tab 2', content: 'Content for Tab 2' }
  ];
  activeTab = 'tab1';
  
  addTab() {
    const id = `tab${this.tabs.length + 1}`;
    this.tabs.push({
      id,
      title: `Tab ${this.tabs.length + 1}`,
      content: `Content for Tab ${this.tabs.length + 1}`
    });
    this.activeTab = id;
  }
  
  removeTab() {
    if (this.tabs.length > 1) {
      const removedTab = this.tabs.pop();
      if (this.activeTab === removedTab?.id) {
        this.activeTab = this.tabs[this.tabs.length - 1].id;
      }
    }
  }
}
```
