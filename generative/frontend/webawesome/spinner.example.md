# Spinner Examples

## Basic Usage

```html
<wa-spinner></wa-spinner>
```

## Custom Styling

### Custom Size

```html
<!-- Using fontSize to control the overall size -->
<wa-spinner [fontSize]="'16px'"></wa-spinner>
<wa-spinner [fontSize]="'24px'"></wa-spinner>
<wa-spinner [fontSize]="'32px'"></wa-spinner>
<wa-spinner [fontSize]="'48px'"></wa-spinner>
```

### Custom Track Width

```html
<wa-spinner [trackWidth]="'2px'"></wa-spinner>
<wa-spinner [trackWidth]="'4px'"></wa-spinner>
<wa-spinner [trackWidth]="'6px'"></wa-spinner>
```

### Custom Colors

```html
<!-- Custom track color -->
<wa-spinner [trackColor]="'#e0e0e0'"></wa-spinner>

<!-- Custom indicator color -->
<wa-spinner [indicatorColor]="'#2196f3'"></wa-spinner>

<!-- Combined custom colors -->
<wa-spinner 
  [trackColor]="'#f5f5f5'" 
  [indicatorColor]="'#4caf50'">
</wa-spinner>
```

### Custom Animation Speed

```html
<wa-spinner [speed]="'0.5s'"></wa-spinner>
<wa-spinner [speed]="'1s'"></wa-spinner>
<wa-spinner [speed]="'2s'"></wa-spinner>
```

### Combined Custom Styling

```html
<wa-spinner 
  [fontSize]="'32px'" 
  [trackWidth]="'4px'" 
  [trackColor]="'#f0f0f0'" 
  [indicatorColor]="'#ff4081'" 
  [speed]="'1.5s'">
</wa-spinner>
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-spinner-demo',
  template: `
    <div class="controls">
      <wa-input 
        type="range" 
        [(ngModel)]="spinnerSize" 
        label="Size"
        min="16"
        max="64"
        step="4">
      </wa-input>
      
      <wa-input 
        type="range" 
        [(ngModel)]="trackWidthValue" 
        label="Track Width"
        min="1"
        max="8"
        step="1">
      </wa-input>
      
      <wa-input 
        type="color" 
        [(ngModel)]="trackColorValue" 
        label="Track Color">
      </wa-input>
      
      <wa-input 
        type="color" 
        [(ngModel)]="indicatorColorValue" 
        label="Indicator Color">
      </wa-input>
      
      <wa-input 
        type="range" 
        [(ngModel)]="speedValue" 
        label="Animation Speed"
        min="0.5"
        max="3"
        step="0.5">
      </wa-input>
    </div>
    
    <div class="spinner-preview">
      <wa-spinner 
        [fontSize]="spinnerSize + 'px'" 
        [trackWidth]="trackWidthValue + 'px'" 
        [trackColor]="trackColorValue" 
        [indicatorColor]="indicatorColorValue" 
        [speed]="speedValue + 's'">
      </wa-spinner>
    </div>
  `
})
export class SpinnerDemoComponent {
  spinnerSize = 32;
  trackWidthValue = 3;
  trackColorValue = '#e0e0e0';
  indicatorColorValue = '#2196f3';
  speedValue = 1;
}
```

## Common Use Cases

### Loading Button

```html
<button [disabled]="isLoading">
  <wa-spinner *ngIf="isLoading" [fontSize]="'16px'" [indicatorColor]="'#ffffff'"></wa-spinner>
  <span *ngIf="!isLoading">Submit</span>
  <span *ngIf="isLoading">Loading...</span>
</button>
```

### Loading Overlay

```html
<div class="loading-overlay" *ngIf="isLoading">
  <wa-spinner 
    [fontSize]="'48px'" 
    [indicatorColor]="'#ffffff'" 
    [trackColor]="'rgba(255, 255, 255, 0.3)'">
  </wa-spinner>
  <div class="loading-text">Loading...</div>
</div>

<style>
  .loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.7);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    z-index: 9999;
  }
  
  .loading-text {
    color: white;
    margin-top: 16px;
    font-size: 18px;
  }
</style>
```

### Inline Loading Indicator

```html
<div class="status-message">
  <span *ngIf="isLoading">
    <wa-spinner [fontSize]="'14px'" [indicatorColor]="'currentColor'"></wa-spinner>
    Loading data...
  </span>
  <span *ngIf="!isLoading && hasData">
    Data loaded successfully!
  </span>
  <span *ngIf="!isLoading && !hasData">
    No data available.
  </span>
</div>
```

### Card Loading State

```html
<div class="card">
  <div class="card-header">
    <h3>User Profile</h3>
  </div>
  
  <div class="card-content">
    <div *ngIf="isLoading" class="loading-container">
      <wa-spinner 
        [fontSize]="'32px'" 
        [indicatorColor]="'#2196f3'">
      </wa-spinner>
      <p>Loading profile data...</p>
    </div>
    
    <div *ngIf="!isLoading" class="profile-data">
      <!-- Profile content here -->
    </div>
  </div>
</div>

<style>
  .card {
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    background-color: white;
    overflow: hidden;
  }
  
  .card-header {
    padding: 16px;
    border-bottom: 1px solid #e0e0e0;
  }
  
  .card-content {
    padding: 16px;
    min-height: 200px;
  }
  
  .loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    min-height: 200px;
  }
</style>
```

## Real-World Example: Data Dashboard with Loading States

```typescript
import { Component, OnInit } from '@angular/core';

interface DashboardSection {
  id: string;
  title: string;
  loading: boolean;
  error: boolean;
  errorMessage?: string;
}

@Component({
  selector: 'app-dashboard',
  template: `
    <div class="dashboard">
      <h1>Analytics Dashboard</h1>
      
      <div class="dashboard-grid">
        <div class="dashboard-section" *ngFor="let section of sections">
          <div class="section-header">
            <h3>{{ section.title }}</h3>
            <button *ngIf="section.error || !section.loading" (click)="refreshSection(section.id)">
              <wa-icon name="refresh"></wa-icon>
            </button>
          </div>
          
          <div class="section-content">
            <!-- Loading state -->
            <div *ngIf="section.loading" class="loading-state">
              <wa-spinner 
                [fontSize]="'32px'" 
                [indicatorColor]="'#2196f3'" 
                [trackColor]="'#e3f2fd'">
              </wa-spinner>
              <p>Loading data...</p>
            </div>
            
            <!-- Error state -->
            <div *ngIf="section.error" class="error-state">
              <wa-icon name="alert-circle" style="color: #f44336; font-size: 32px;"></wa-icon>
              <p>{{ section.errorMessage || 'Failed to load data' }}</p>
            </div>
            
            <!-- Content state (would be replaced with actual content) -->
            <div *ngIf="!section.loading && !section.error" class="content-state">
              <!-- Section specific content would go here -->
              <div class="placeholder-content">
                <p>Data for {{ section.title }} would be displayed here</p>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="dashboard-actions">
        <button (click)="refreshAll()" [disabled]="isAnyLoading()">
          <wa-spinner *ngIf="isAnyLoading()" [fontSize]="'16px'" [indicatorColor]="'currentColor'"></wa-spinner>
          <span *ngIf="!isAnyLoading()">Refresh All</span>
          <span *ngIf="isAnyLoading()">Refreshing...</span>
        </button>
      </div>
    </div>
  `,
  styles: [`
    .dashboard {
      padding: 20px;
    }
    
    .dashboard-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 20px;
      margin: 20px 0;
    }
    
    .dashboard-section {
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      background-color: white;
      overflow: hidden;
    }
    
    .section-header {
      padding: 16px;
      border-bottom: 1px solid #e0e0e0;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    
    .section-content {
      padding: 16px;
      min-height: 200px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
    }
    
    .loading-state, .error-state, .content-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      width: 100%;
      height: 100%;
    }
    
    .error-state {
      color: #f44336;
    }
    
    .dashboard-actions {
      display: flex;
      justify-content: center;
      margin-top: 20px;
    }
    
    button {
      padding: 8px 16px;
      border-radius: 4px;
      border: none;
      background-color: #2196f3;
      color: white;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    button:disabled {
      background-color: #90caf9;
      cursor: not-allowed;
    }
  `]
})
export class DashboardComponent implements OnInit {
  sections: DashboardSection[] = [
    { id: 'users', title: 'User Statistics', loading: true, error: false },
    { id: 'revenue', title: 'Revenue', loading: true, error: false },
    { id: 'traffic', title: 'Traffic Sources', loading: true, error: false },
    { id: 'performance', title: 'Site Performance', loading: true, error: false }
  ];
  
  ngOnInit(): void {
    // Simulate loading data for each section
    this.sections.forEach(section => {
      this.loadSectionData(section.id);
    });
  }
  
  loadSectionData(sectionId: string): void {
    const section = this.sections.find(s => s.id === sectionId);
    if (!section) return;
    
    section.loading = true;
    section.error = false;
    
    // Simulate API call with random timing and occasional errors
    const delay = 1000 + Math.random() * 2000;
    const shouldError = Math.random() < 0.2; // 20% chance of error
    
    setTimeout(() => {
      section.loading = false;
      
      if (shouldError) {
        section.error = true;
        section.errorMessage = `Failed to load ${section.title} data. Please try again.`;
      }
    }, delay);
  }
  
  refreshSection(sectionId: string): void {
    this.loadSectionData(sectionId);
  }
  
  refreshAll(): void {
    this.sections.forEach(section => {
      this.loadSectionData(section.id);
    });
  }
  
  isAnyLoading(): boolean {
    return this.sections.some(section => section.loading);
  }
}
```
