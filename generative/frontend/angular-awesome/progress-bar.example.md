# Progress Bar Examples

## Basic Usage

```html
<wa-progress-bar value="50"></wa-progress-bar>
```

## With Label

```html
<wa-progress-bar value="75" label="Loading..."></wa-progress-bar>
```

## Indeterminate State

```html
<wa-progress-bar [indeterminate]="true"></wa-progress-bar>
<wa-progress-bar [indeterminate]="true" label="Processing..."></wa-progress-bar>
```

## Custom Styling

```html
<!-- Custom indicator color -->
<wa-progress-bar 
  value="60" 
  [indicatorColor]="'#4caf50'">
</wa-progress-bar>

<!-- Custom display -->
<wa-progress-bar 
  value="40" 
  [display]="'inline-block'" 
  [indicatorColor]="'#ff9800'">
</wa-progress-bar>
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-progress-demo',
  template: `
    <wa-progress-bar 
      [value]="progressValue" 
      [label]="progressLabel"
      [indeterminate]="isIndeterminate"
      [indicatorColor]="indicatorColor"
      (focusEvent)="onFocus()"
      (blurEvent)="onBlur()">
    </wa-progress-bar>
    
    <div class="controls">
      <button (click)="incrementProgress()">Increment</button>
      <button (click)="resetProgress()">Reset</button>
      <button (click)="toggleIndeterminate()">Toggle Indeterminate</button>
    </div>
  `
})
export class ProgressDemoComponent {
  progressValue = 25;
  progressLabel = 'Loading...';
  isIndeterminate = false;
  indicatorColor = '#2196f3';
  
  incrementProgress(): void {
    if (this.progressValue < 100) {
      this.progressValue += 10;
      this.updateLabel();
    }
  }
  
  resetProgress(): void {
    this.progressValue = 0;
    this.updateLabel();
  }
  
  toggleIndeterminate(): void {
    this.isIndeterminate = !this.isIndeterminate;
    this.progressLabel = this.isIndeterminate ? 'Processing...' : 'Loading...';
  }
  
  updateLabel(): void {
    this.progressLabel = `Loading ${this.progressValue}%`;
  }
  
  onFocus(): void {
    console.log('Progress bar focused');
  }
  
  onBlur(): void {
    console.log('Progress bar blurred');
  }
}
```

## Using with ngModel

```html
<form #progressForm="ngForm">
  <wa-progress-bar 
    [(ngModel)]="downloadProgress" 
    name="downloadProgress">
  </wa-progress-bar>
  
  <div>Current progress: {{ downloadProgress }}%</div>
  
  <input 
    type="range" 
    min="0" 
    max="100" 
    [(ngModel)]="downloadProgress" 
    name="progressSlider">
</form>
```

## Real-World Example: File Upload Progress

```typescript
import { Component } from '@angular/core';
import { HttpClient, HttpEventType } from '@angular/common/http';

@Component({
  selector: 'app-file-upload',
  template: `
    <div class="upload-container">
      <h2>File Upload</h2>
      
      <input 
        type="file" 
        (change)="onFileSelected($event)" 
        [disabled]="uploading">
      
      <div class="progress-container" *ngIf="uploading">
        <wa-progress-bar 
          [value]="uploadProgress" 
          [label]="uploadProgressLabel"
          [indicatorColor]="'#4caf50'">
        </wa-progress-bar>
      </div>
      
      <div class="status" *ngIf="uploadComplete">
        Upload complete!
      </div>
      
      <div class="error" *ngIf="uploadError">
        {{ errorMessage }}
      </div>
    </div>
  `
})
export class FileUploadComponent {
  uploading = false;
  uploadProgress = 0;
  uploadProgressLabel = '';
  uploadComplete = false;
  uploadError = false;
  errorMessage = '';
  
  constructor(private http: HttpClient) {}
  
  onFileSelected(event: Event): void {
    const fileInput = event.target as HTMLInputElement;
    if (fileInput.files && fileInput.files.length > 0) {
      const file = fileInput.files[0];
      this.uploadFile(file);
    }
  }
  
  uploadFile(file: File): void {
    this.uploading = true;
    this.uploadComplete = false;
    this.uploadError = false;
    this.uploadProgress = 0;
    this.updateProgressLabel();
    
    const formData = new FormData();
    formData.append('file', file);
    
    this.http.post('https://api.example.com/upload', formData, {
      reportProgress: true,
      observe: 'events'
    }).subscribe({
      next: (event) => {
        if (event.type === HttpEventType.UploadProgress) {
          if (event.total) {
            this.uploadProgress = Math.round(100 * event.loaded / event.total);
            this.updateProgressLabel();
          }
        } else if (event.type === HttpEventType.Response) {
          this.uploading = false;
          this.uploadComplete = true;
        }
      },
      error: (error) => {
        this.uploading = false;
        this.uploadError = true;
        this.errorMessage = 'Upload failed: ' + error.message;
      }
    });
  }
  
  updateProgressLabel(): void {
    this.uploadProgressLabel = `Uploading ${this.uploadProgress}%`;
  }
}
```

## Progress Bar with Custom Content

```html
<wa-progress-bar value="65">
  <div slot="prefix">
    <wa-icon name="download"></wa-icon>
  </div>
  Downloading 65%
</wa-progress-bar>
```

## Multiple Progress Bars for Different Tasks

```html
<div class="progress-container">
  <div class="progress-item">
    <div class="progress-label">CPU Usage</div>
    <wa-progress-bar 
      value="85" 
      [indicatorColor]="'#f44336'">
    </wa-progress-bar>
  </div>
  
  <div class="progress-item">
    <div class="progress-label">Memory Usage</div>
    <wa-progress-bar 
      value="60" 
      [indicatorColor]="'#2196f3'">
    </wa-progress-bar>
  </div>
  
  <div class="progress-item">
    <div class="progress-label">Disk Usage</div>
    <wa-progress-bar 
      value="45" 
      [indicatorColor]="'#4caf50'">
    </wa-progress-bar>
  </div>
  
  <div class="progress-item">
    <div class="progress-label">Network</div>
    <wa-progress-bar 
      [indeterminate]="true" 
      [indicatorColor]="'#ff9800'">
    </wa-progress-bar>
  </div>
</div>
```
