# Skeleton Examples

## Basic Usage

```html
<div waSkeleton>This content will be styled as a skeleton loader</div>
```

## Different Effects

```html
<!-- Default effect (sheen) -->
<div waSkeleton>Default sheen effect</div>

<!-- No animation effect -->
<div waSkeleton effect="none">No animation effect</div>

<!-- Pulse animation effect -->
<div waSkeleton effect="pulse">Pulse animation effect</div>

<!-- Sheen animation effect (explicitly set) -->
<div waSkeleton effect="sheen">Sheen animation effect</div>
```

## Custom Styling

```html
<!-- Custom border radius -->
<div waSkeleton [borderRadius]="'8px'">Rounded skeleton</div>

<!-- Custom color -->
<div waSkeleton [color]="'#e0e0e0'">Custom color skeleton</div>

<!-- Custom sheen color -->
<div waSkeleton [sheenColor]="'rgba(255, 255, 255, 0.5)'">Custom sheen color</div>

<!-- Combined custom styling -->
<div 
  waSkeleton 
  [borderRadius]="'16px'" 
  [color]="'#f0f0f0'" 
  [sheenColor]="'rgba(255, 255, 255, 0.7)'">
  Combined custom styling
</div>
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-skeleton-demo',
  template: `
    <div class="controls">
      <wa-select [(ngModel)]="selectedEffect" label="Effect">
        <wa-option value="sheen">Sheen</wa-option>
        <wa-option value="pulse">Pulse</wa-option>
        <wa-option value="none">None</wa-option>
      </wa-select>
      
      <wa-input 
        type="color" 
        [(ngModel)]="skeletonColor" 
        label="Skeleton Color">
      </wa-input>
      
      <wa-input 
        type="range" 
        [(ngModel)]="borderRadiusValue" 
        label="Border Radius"
        min="0"
        max="24"
        step="2">
      </wa-input>
    </div>
    
    <div 
      waSkeleton 
      [effect]="selectedEffect"
      [color]="skeletonColor"
      [borderRadius]="borderRadiusValue + 'px'">
      <div style="width: 300px; height: 50px;"></div>
    </div>
  `
})
export class SkeletonDemoComponent {
  selectedEffect = 'sheen';
  skeletonColor = '#e0e0e0';
  borderRadiusValue = 4;
}
```

## Common Use Cases

### Text Skeleton

```html
<!-- Text paragraph skeleton -->
<div class="skeleton-text">
  <div waSkeleton [borderRadius]="'4px'" style="height: 20px; margin-bottom: 8px; width: 100%;"></div>
  <div waSkeleton [borderRadius]="'4px'" style="height: 20px; margin-bottom: 8px; width: 90%;"></div>
  <div waSkeleton [borderRadius]="'4px'" style="height: 20px; margin-bottom: 8px; width: 95%;"></div>
  <div waSkeleton [borderRadius]="'4px'" style="height: 20px; margin-bottom: 8px; width: 85%;"></div>
  <div waSkeleton [borderRadius]="'4px'" style="height: 20px; width: 70%;"></div>
</div>
```

### Card Skeleton

```html
<!-- Card skeleton -->
<div class="skeleton-card" style="width: 300px; border-radius: 8px; overflow: hidden;">
  <!-- Image placeholder -->
  <div waSkeleton style="height: 200px; width: 100%;"></div>
  
  <!-- Content placeholders -->
  <div style="padding: 16px;">
    <!-- Title -->
    <div waSkeleton [borderRadius]="'4px'" style="height: 24px; width: 80%; margin-bottom: 16px;"></div>
    
    <!-- Description -->
    <div waSkeleton [borderRadius]="'4px'" style="height: 16px; width: 100%; margin-bottom: 8px;"></div>
    <div waSkeleton [borderRadius]="'4px'" style="height: 16px; width: 90%; margin-bottom: 8px;"></div>
    <div waSkeleton [borderRadius]="'4px'" style="height: 16px; width: 95%;"></div>
    
    <!-- Action buttons -->
    <div style="display: flex; gap: 8px; margin-top: 16px;">
      <div waSkeleton [borderRadius]="'4px'" style="height: 36px; width: 100px;"></div>
      <div waSkeleton [borderRadius]="'4px'" style="height: 36px; width: 100px;"></div>
    </div>
  </div>
</div>
```

### Profile Skeleton

```html
<!-- Profile skeleton -->
<div class="skeleton-profile" style="display: flex; align-items: center; gap: 16px;">
  <!-- Avatar placeholder -->
  <div waSkeleton [borderRadius]="'50%'" style="height: 64px; width: 64px;"></div>
  
  <!-- Info placeholders -->
  <div style="flex: 1;">
    <!-- Name -->
    <div waSkeleton [borderRadius]="'4px'" style="height: 20px; width: 150px; margin-bottom: 8px;"></div>
    
    <!-- Title -->
    <div waSkeleton [borderRadius]="'4px'" style="height: 16px; width: 200px;"></div>
  </div>
</div>
```

### Table Skeleton

```html
<!-- Table skeleton -->
<table style="width: 100%; border-collapse: collapse;">
  <thead>
    <tr>
      <th style="padding: 12px 16px; text-align: left; width: 40%;">Name</th>
      <th style="padding: 12px 16px; text-align: left; width: 30%;">Email</th>
      <th style="padding: 12px 16px; text-align: left; width: 30%;">Role</th>
    </tr>
  </thead>
  <tbody>
    <tr *ngFor="let i of [1, 2, 3, 4, 5]">
      <td style="padding: 12px 16px;">
        <div waSkeleton [borderRadius]="'4px'" style="height: 20px; width: 90%;"></div>
      </td>
      <td style="padding: 12px 16px;">
        <div waSkeleton [borderRadius]="'4px'" style="height: 20px; width: 90%;"></div>
      </td>
      <td style="padding: 12px 16px;">
        <div waSkeleton [borderRadius]="'4px'" style="height: 20px; width: 90%;"></div>
      </td>
    </tr>
  </tbody>
</table>
```

## Real-World Example: Loading State for a Dashboard

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-dashboard',
  template: `
    <div class="dashboard">
      <h2>Dashboard</h2>
      
      <!-- Loading state -->
      <div *ngIf="loading; else loadedContent">
        <!-- Stats cards -->
        <div class="stats-row">
          <div class="stat-card" *ngFor="let i of [1, 2, 3, 4]">
            <div waSkeleton [borderRadius]="'4px'" style="height: 24px; width: 50%; margin-bottom: 12px;"></div>
            <div waSkeleton [borderRadius]="'4px'" style="height: 36px; width: 70%;"></div>
          </div>
        </div>
        
        <!-- Chart placeholder -->
        <div class="chart-container">
          <div waSkeleton style="height: 300px; width: 100%; margin: 24px 0;"></div>
        </div>
        
        <!-- Table placeholder -->
        <div class="table-container">
          <div waSkeleton [borderRadius]="'4px'" style="height: 24px; width: 30%; margin-bottom: 16px;"></div>
          
          <table style="width: 100%; border-collapse: collapse;">
            <thead>
              <tr>
                <th style="padding: 12px 16px; text-align: left;">Product</th>
                <th style="padding: 12px 16px; text-align: left;">Sales</th>
                <th style="padding: 12px 16px; text-align: left;">Status</th>
                <th style="padding: 12px 16px; text-align: left;">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr *ngFor="let i of [1, 2, 3, 4, 5]">
                <td style="padding: 12px 16px;">
                  <div waSkeleton [borderRadius]="'4px'" style="height: 20px; width: 90%;"></div>
                </td>
                <td style="padding: 12px 16px;">
                  <div waSkeleton [borderRadius]="'4px'" style="height: 20px; width: 60%;"></div>
                </td>
                <td style="padding: 12px 16px;">
                  <div waSkeleton [borderRadius]="'16px'" style="height: 24px; width: 80px;"></div>
                </td>
                <td style="padding: 12px 16px;">
                  <div style="display: flex; gap: 8px;">
                    <div waSkeleton [borderRadius]="'4px'" style="height: 32px; width: 32px;"></div>
                    <div waSkeleton [borderRadius]="'4px'" style="height: 32px; width: 32px;"></div>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- Loaded content -->
      <ng-template #loadedContent>
        <!-- Actual dashboard content goes here -->
        <div class="stats-row">
          <!-- Real stats cards -->
        </div>
        
        <div class="chart-container">
          <!-- Real chart -->
        </div>
        
        <div class="table-container">
          <!-- Real table -->
        </div>
      </ng-template>
      
      <button (click)="toggleLoading()">Toggle Loading State</button>
    </div>
  `,
  styles: [`
    .dashboard {
      padding: 20px;
    }
    
    .stats-row {
      display: flex;
      gap: 16px;
      margin-bottom: 24px;
    }
    
    .stat-card {
      flex: 1;
      padding: 16px;
      border-radius: 8px;
      background-color: #ffffff;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .chart-container, .table-container {
      padding: 16px;
      border-radius: 8px;
      background-color: #ffffff;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      margin-bottom: 24px;
    }
  `]
})
export class DashboardComponent {
  loading = true;
  
  toggleLoading(): void {
    this.loading = !this.loading;
  }
}
```
