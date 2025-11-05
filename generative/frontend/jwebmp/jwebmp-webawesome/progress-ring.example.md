# Progress Ring Examples

## Basic Usage

```html
<wa-progress-ring value="50"></wa-progress-ring>
```

## With Label

```html
<wa-progress-ring value="75" label="Loading..."></wa-progress-ring>
```

## Different Sizes

```html
<wa-progress-ring value="60" [size]="'100px'"></wa-progress-ring>
<wa-progress-ring value="60" [size]="'150px'"></wa-progress-ring>
<wa-progress-ring value="60" [size]="'200px'"></wa-progress-ring>
```

## Custom Styling

```html
<!-- Custom track width and color -->
<wa-progress-ring 
  value="40" 
  [trackWidth]="'4px'" 
  [trackColor]="'#e0e0e0'">
</wa-progress-ring>

<!-- Custom indicator width and color -->
<wa-progress-ring 
  value="65" 
  [indicatorWidth]="'6px'" 
  [indicatorColor]="'#4caf50'">
</wa-progress-ring>

<!-- Custom transition duration -->
<wa-progress-ring 
  value="80" 
  [indicatorTransitionDuration]="'1.5s'">
</wa-progress-ring>

<!-- Combining multiple style customizations -->
<wa-progress-ring 
  value="70" 
  [size]="'120px'" 
  [trackWidth]="'3px'" 
  [trackColor]="'#f5f5f5'" 
  [indicatorWidth]="'5px'" 
  [indicatorColor]="'#2196f3'" 
  [indicatorTransitionDuration]="'0.8s'">
</wa-progress-ring>
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-progress-demo',
  template: `
    <wa-progress-ring 
      [value]="progressValue" 
      [label]="progressLabel"
      [size]="ringSize"
      [trackWidth]="trackWidth"
      [trackColor]="trackColor"
      [indicatorWidth]="indicatorWidth"
      [indicatorColor]="indicatorColor"
      [indicatorTransitionDuration]="transitionDuration"
      (focusEvent)="onFocus()"
      (blurEvent)="onBlur()">
    </wa-progress-ring>
    
    <div class="controls">
      <button (click)="incrementProgress()">Increment</button>
      <button (click)="resetProgress()">Reset</button>
    </div>
  `
})
export class ProgressRingDemoComponent {
  progressValue = 25;
  progressLabel = 'Loading...';
  ringSize = '120px';
  trackWidth = '4px';
  trackColor = '#e0e0e0';
  indicatorWidth = '4px';
  indicatorColor = '#2196f3';
  transitionDuration = '0.3s';
  
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
  
  updateLabel(): void {
    this.progressLabel = `Loading ${this.progressValue}%`;
  }
  
  onFocus(): void {
    console.log('Progress ring focused');
  }
  
  onBlur(): void {
    console.log('Progress ring blurred');
  }
}
```

## Using with ngModel

```html
<form #progressForm="ngForm">
  <wa-progress-ring 
    [(ngModel)]="downloadProgress" 
    name="downloadProgress">
  </wa-progress-ring>
  
  <div>Current progress: {{ downloadProgress }}%</div>
  
  <input 
    type="range" 
    min="0" 
    max="100" 
    [(ngModel)]="downloadProgress" 
    name="progressSlider">
</form>
```

## Real-World Example: File Upload with Progress Ring

```typescript
import { Component } from '@angular/core';
import { HttpClient, HttpEventType } from '@angular/common/http';

@Component({
  selector: 'app-file-upload',
  template: `
    <div class="upload-container">
      <h2>File Upload</h2>
      
      <div class="upload-area">
        <input 
          type="file" 
          (change)="onFileSelected($event)" 
          [disabled]="uploading">
        
        <div class="progress-container" *ngIf="uploading">
          <wa-progress-ring 
            [value]="uploadProgress" 
            [label]="uploadProgressLabel"
            [size]="'150px'"
            [indicatorColor]="'#4caf50'"
            [indicatorTransitionDuration]="'0.3s'">
          </wa-progress-ring>
        </div>
      </div>
      
      <div class="status" *ngIf="uploadComplete">
        Upload complete!
      </div>
      
      <div class="error" *ngIf="uploadError">
        {{ errorMessage }}
      </div>
    </div>
  `,
  styles: [`
    .upload-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 20px;
    }
    
    .upload-area {
      position: relative;
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    
    .progress-container {
      margin-top: 20px;
    }
  `]
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
    this.uploadProgressLabel = `${this.uploadProgress}%`;
  }
}
```

## Multiple Progress Rings for Dashboard

```html
<div class="dashboard">
  <div class="metric">
    <h3>CPU Usage</h3>
    <wa-progress-ring 
      value="85" 
      [size]="'100px'" 
      [indicatorColor]="'#f44336'" 
      label="85%">
    </wa-progress-ring>
  </div>
  
  <div class="metric">
    <h3>Memory</h3>
    <wa-progress-ring 
      value="60" 
      [size]="'100px'" 
      [indicatorColor]="'#2196f3'" 
      label="60%">
    </wa-progress-ring>
  </div>
  
  <div class="metric">
    <h3>Disk Space</h3>
    <wa-progress-ring 
      value="45" 
      [size]="'100px'" 
      [indicatorColor]="'#4caf50'" 
      label="45%">
    </wa-progress-ring>
  </div>
  
  <div class="metric">
    <h3>Network</h3>
    <wa-progress-ring 
      value="30" 
      [size]="'100px'" 
      [indicatorColor]="'#ff9800'" 
      label="30%">
    </wa-progress-ring>
  </div>
</div>
```

## Progress Ring with Custom Content

```html
<wa-progress-ring value="65" [size]="'150px'">
  <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%;">
    <strong style="font-size: 24px;">65%</strong>
    <span>Complete</span>
  </div>
</wa-progress-ring>
```

## Animated Progress Ring

```typescript
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-animated-progress',
  template: `
    <wa-progress-ring 
      [value]="currentValue" 
      [size]="'150px'" 
      [indicatorColor]="'#673ab7'" 
      [indicatorTransitionDuration]="'0.5s'">
      <div class="content">
        <strong>{{ currentValue }}%</strong>
      </div>
    </wa-progress-ring>
  `,
  styles: [`
    .content {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100%;
      font-size: 24px;
    }
  `]
})
export class AnimatedProgressComponent implements OnInit {
  currentValue = 0;
  
  ngOnInit(): void {
    this.animateProgress();
  }
  
  animateProgress(): void {
    const interval = setInterval(() => {
      if (this.currentValue < 100) {
        this.currentValue += 1;
      } else {
        clearInterval(interval);
      }
    }, 50);
  }
}
```
