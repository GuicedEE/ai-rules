# Split Panel Examples

## Basic Usage

```html
<wa-split-panel>
  <div slot="start">Left Panel Content</div>
  <div slot="end">Right Panel Content</div>
</wa-split-panel>
```

## Vertical Split

```html
<wa-split-panel [vertical]="true">
  <div slot="start">Top Panel Content</div>
  <div slot="end">Bottom Panel Content</div>
</wa-split-panel>
```

## Custom Initial Position

```html
<!-- Set position as percentage (0-100) -->
<wa-split-panel [position]="30">
  <div slot="start">Left Panel (30%)</div>
  <div slot="end">Right Panel (70%)</div>
</wa-split-panel>

<!-- Set position in pixels -->
<wa-split-panel [positionInPixels]="300">
  <div slot="start">Left Panel (300px)</div>
  <div slot="end">Right Panel (Remaining Space)</div>
</wa-split-panel>
```

## Primary Panel

```html
<!-- Start panel is primary (default) -->
<wa-split-panel primary="start">
  <div slot="start">Primary Panel (maintains size during window resize)</div>
  <div slot="end">Secondary Panel (resizes during window resize)</div>
</wa-split-panel>

<!-- End panel is primary -->
<wa-split-panel primary="end">
  <div slot="start">Secondary Panel (resizes during window resize)</div>
  <div slot="end">Primary Panel (maintains size during window resize)</div>
</wa-split-panel>
```

## Disabled State

```html
<wa-split-panel [disabled]="true" [position]="40">
  <div slot="start">Left Panel (40%)</div>
  <div slot="end">Right Panel (60%)</div>
</wa-split-panel>
```

## Snap Positions

```html
<!-- Snap to positions 0, 25, 50, 75, and 100 percent -->
<wa-split-panel snap="0,25,50,75,100">
  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
</wa-split-panel>

<!-- With custom snap threshold (distance in pixels to snap) -->
<wa-split-panel snap="0,33,66,100" [snapThreshold]="20">
  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
</wa-split-panel>
```

## Custom Styling

```html
<!-- Custom divider color -->
<wa-split-panel [dividerColor]="'#2196f3'">
  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
</wa-split-panel>

<!-- Custom divider width -->
<wa-split-panel [dividerWidth]="'8px'">
  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
</wa-split-panel>

<!-- Custom divider hit area (for easier grabbing) -->
<wa-split-panel [dividerHitArea]="'20px'">
  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
</wa-split-panel>

<!-- Min and max constraints -->
<wa-split-panel [min]="'200px'" [max]="'70%'">
  <div slot="start">Left Panel (min 200px, max 70%)</div>
  <div slot="end">Right Panel</div>
</wa-split-panel>

<!-- Combined custom styling -->
<wa-split-panel 
  [dividerColor]="'#ff4081'" 
  [dividerWidth]="'6px'" 
  [dividerHitArea]="'16px'"
  [min]="'150px'"
  [max]="'80%'">
  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
</wa-split-panel>
```

## Custom Divider Content

```html
<wa-split-panel>
  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
  <div slot="divider" style="display: flex; justify-content: center; align-items: center;">
    <div style="width: 16px; height: 40px; background-color: #2196f3; border-radius: 4px;"></div>
  </div>
</wa-split-panel>
```

## Event Handling

```html
<wa-split-panel (repositionEvent)="onReposition($event)">
  <div slot="start">Left Panel</div>
  <div slot="end">Right Panel</div>
</wa-split-panel>
```

```typescript
// In your component
onReposition(event: CustomEvent): void {
  console.log('Panel resized:', event.detail);
  // event.detail contains the new position information
}
```

## Using with Angular Bindings

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-split-panel-demo',
  template: `
    <div class="controls">
      <wa-checkbox 
        [(ngModel)]="isVertical" 
        label="Vertical Split">
      </wa-checkbox>
      
      <wa-select 
        [(ngModel)]="primaryPanel" 
        label="Primary Panel">
        <wa-option value="start">Start</wa-option>
        <wa-option value="end">End</wa-option>
      </wa-select>
      
      <wa-slider 
        [(ngModel)]="panelPosition" 
        label="Position" 
        [min]="0" 
        [max]="100" 
        [step]="1"
        (inputEvent)="updatePosition()">
      </wa-slider>
      
      <wa-input 
        type="color" 
        [(ngModel)]="dividerColorValue" 
        label="Divider Color">
      </wa-input>
      
      <wa-checkbox 
        [(ngModel)]="isPanelDisabled" 
        label="Disable Resizing">
      </wa-checkbox>
    </div>
    
    <wa-split-panel 
      [vertical]="isVertical" 
      [primary]="primaryPanel" 
      [position]="panelPosition" 
      [dividerColor]="dividerColorValue" 
      [disabled]="isPanelDisabled"
      (repositionEvent)="onPanelReposition($event)">
      <div slot="start" class="panel-content">
        <h3>Start Panel</h3>
        <p>This is the {{ primaryPanel === 'start' ? 'primary' : 'secondary' }} panel.</p>
        <p>Current position: {{ panelPosition }}%</p>
      </div>
      <div slot="end" class="panel-content">
        <h3>End Panel</h3>
        <p>This is the {{ primaryPanel === 'end' ? 'primary' : 'secondary' }} panel.</p>
      </div>
    </wa-split-panel>
  `,
  styles: [`
    .controls {
      margin-bottom: 20px;
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
    }
    
    .panel-content {
      padding: 16px;
      height: 100%;
      overflow: auto;
    }
  `]
})
export class SplitPanelDemoComponent {
  isVertical = false;
  primaryPanel = 'start';
  panelPosition = 50;
  dividerColorValue = '#cccccc';
  isPanelDisabled = false;
  
  updatePosition(): void {
    console.log(`Panel position updated to ${this.panelPosition}%`);
  }
  
  onPanelReposition(event: CustomEvent): void {
    this.panelPosition = event.detail.position;
    console.log('Panel repositioned:', event.detail);
  }
}
```

## Real-World Example: Code Editor Layout

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-code-editor',
  template: `
    <div class="editor-container">
      <div class="toolbar">
        <div class="logo">CodeEditor</div>
        <div class="actions">
          <button>Run</button>
          <button>Save</button>
          <button>Share</button>
        </div>
      </div>
      
      <wa-split-panel 
        [position]="20" 
        [min]="'150px'" 
        [dividerColor]="'#444'" 
        [dividerWidth]="'1px'"
        class="main-split">
        <!-- File Explorer -->
        <div slot="start" class="file-explorer">
          <div class="panel-header">
            <h3>Files</h3>
            <button class="icon-button">+</button>
          </div>
          
          <div class="file-list">
            <div class="file active">index.html</div>
            <div class="file">styles.css</div>
            <div class="file">script.js</div>
            <div class="file">README.md</div>
          </div>
        </div>
        
        <!-- Editor and Preview -->
        <div slot="end" class="editor-preview-container">
          <wa-split-panel 
            [vertical]="true" 
            [position]="60" 
            [dividerColor]="'#444'" 
            [dividerWidth]="'1px'">
            <!-- Code Editor -->
            <div slot="start" class="code-editor">
              <div class="panel-header">
                <div class="tabs">
                  <div class="tab active">index.html</div>
                  <div class="tab">styles.css</div>
                </div>
              </div>
              
              <div class="editor-content">
                <pre><code>&lt;!DOCTYPE html&gt;
&lt;html&gt;
&lt;head&gt;
  &lt;title&gt;My Web Page&lt;/title&gt;
  &lt;link rel="stylesheet" href="styles.css"&gt;
  &lt;script src="script.js"&gt;&lt;/script&gt;
&lt;/head&gt;
&lt;body&gt;
  &lt;h1&gt;Hello, World!&lt;/h1&gt;
  &lt;p&gt;This is a sample web page.&lt;/p&gt;
&lt;/body&gt;
&lt;/html&gt;</code></pre>
              </div>
            </div>
            
            <!-- Preview -->
            <div slot="end" class="preview">
              <div class="panel-header">
                <h3>Preview</h3>
                <button class="icon-button">↻</button>
              </div>
              
              <div class="preview-content">
                <div class="preview-frame">
                  <h1>Hello, World!</h1>
                  <p>This is a sample web page.</p>
                </div>
              </div>
            </div>
          </wa-split-panel>
        </div>
      </wa-split-panel>
      
      <div class="status-bar">
        <div>Ready</div>
        <div>HTML</div>
        <div>UTF-8</div>
      </div>
    </div>
  `,
  styles: [`
    .editor-container {
      display: flex;
      flex-direction: column;
      height: 600px;
      border: 1px solid #ddd;
      border-radius: 4px;
      overflow: hidden;
    }
    
    .toolbar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 16px;
      background-color: #f5f5f5;
      border-bottom: 1px solid #ddd;
    }
    
    .logo {
      font-weight: bold;
      font-size: 18px;
    }
    
    .actions {
      display: flex;
      gap: 8px;
    }
    
    .main-split {
      flex: 1;
      overflow: hidden;
    }
    
    .panel-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 16px;
      background-color: #f5f5f5;
      border-bottom: 1px solid #ddd;
    }
    
    .file-explorer {
      height: 100%;
      display: flex;
      flex-direction: column;
      background-color: #fafafa;
    }
    
    .file-list {
      flex: 1;
      overflow: auto;
    }
    
    .file {
      padding: 8px 16px;
      cursor: pointer;
    }
    
    .file.active {
      background-color: #e3f2fd;
      color: #2196f3;
    }
    
    .file:hover:not(.active) {
      background-color: #f5f5f5;
    }
    
    .editor-preview-container {
      height: 100%;
    }
    
    .code-editor {
      height: 100%;
      display: flex;
      flex-direction: column;
      background-color: #fafafa;
    }
    
    .tabs {
      display: flex;
      gap: 2px;
    }
    
    .tab {
      padding: 8px 16px;
      background-color: #f0f0f0;
      border-right: 1px solid #ddd;
      cursor: pointer;
    }
    
    .tab.active {
      background-color: #fff;
      border-bottom: 2px solid #2196f3;
    }
    
    .editor-content {
      flex: 1;
      overflow: auto;
      padding: 16px;
      font-family: monospace;
      background-color: #fff;
    }
    
    .preview {
      height: 100%;
      display: flex;
      flex-direction: column;
      background-color: #fff;
    }
    
    .preview-content {
      flex: 1;
      overflow: auto;
      padding: 16px;
    }
    
    .preview-frame {
      padding: 16px;
      border: 1px dashed #ddd;
      border-radius: 4px;
    }
    
    .status-bar {
      display: flex;
      gap: 16px;
      padding: 4px 16px;
      background-color: #f5f5f5;
      border-top: 1px solid #ddd;
      font-size: 12px;
      color: #666;
    }
    
    button {
      padding: 4px 12px;
      background-color: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    
    .icon-button {
      width: 24px;
      height: 24px;
      padding: 0;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    h3 {
      margin: 0;
      font-size: 14px;
    }
    
    pre {
      margin: 0;
    }
  `]
})
export class CodeEditorComponent {
  // Component logic would go here
}
```

## Real-World Example: File Explorer with Preview

```html
<div class="file-explorer-container">
  <wa-split-panel [position]="30" [min]="'200px'" [max]="'50%'">
    <!-- File Tree -->
    <div slot="start" class="file-tree">
      <div class="folder">
        <div class="folder-name">
          <span class="icon">📁</span> Documents
        </div>
        <div class="folder-contents">
          <div class="file" (click)="selectFile('report.pdf')">
            <span class="icon">📄</span> report.pdf
          </div>
          <div class="file" (click)="selectFile('presentation.pptx')">
            <span class="icon">📄</span> presentation.pptx
          </div>
        </div>
      </div>
      
      <div class="folder">
        <div class="folder-name">
          <span class="icon">📁</span> Images
        </div>
        <div class="folder-contents">
          <div class="file" (click)="selectFile('photo1.jpg')">
            <span class="icon">🖼️</span> photo1.jpg
          </div>
          <div class="file" (click)="selectFile('photo2.jpg')">
            <span class="icon">🖼️</span> photo2.jpg
          </div>
          <div class="file" (click)="selectFile('photo3.jpg')">
            <span class="icon">🖼️</span> photo3.jpg
          </div>
        </div>
      </div>
    </div>
    
    <!-- File Preview -->
    <div slot="end" class="file-preview">
      <div *ngIf="!selectedFile" class="no-selection">
        <p>Select a file to preview</p>
      </div>
      
      <div *ngIf="selectedFile" class="preview-content">
        <div class="preview-header">
          <h3>{{ selectedFile }}</h3>
          <div class="actions">
            <button>Download</button>
            <button>Share</button>
          </div>
        </div>
        
        <div class="preview-body">
          <!-- File preview would go here -->
          <div class="placeholder-preview">
            <p>Preview for {{ selectedFile }}</p>
          </div>
        </div>
      </div>
    </div>
  </wa-split-panel>
</div>

<style>
  .file-explorer-container {
    height: 500px;
    border: 1px solid #ddd;
    border-radius: 4px;
    overflow: hidden;
  }
  
  .file-tree {
    height: 100%;
    overflow: auto;
    padding: 16px;
    background-color: #f5f5f5;
  }
  
  .folder {
    margin-bottom: 8px;
  }
  
  .folder-name {
    font-weight: bold;
    padding: 4px 0;
    cursor: pointer;
  }
  
  .folder-contents {
    padding-left: 20px;
  }
  
  .file {
    padding: 4px 0;
    cursor: pointer;
  }
  
  .file:hover {
    color: #2196f3;
  }
  
  .icon {
    margin-right: 4px;
  }
  
  .file-preview {
    height: 100%;
    display: flex;
    flex-direction: column;
    background-color: white;
  }
  
  .no-selection {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    color: #999;
  }
  
  .preview-content {
    display: flex;
    flex-direction: column;
    height: 100%;
  }
  
  .preview-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    border-bottom: 1px solid #ddd;
  }
  
  .actions {
    display: flex;
    gap: 8px;
  }
  
  .preview-body {
    flex: 1;
    overflow: auto;
    padding: 16px;
  }
  
  .placeholder-preview {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    border: 1px dashed #ddd;
    border-radius: 4px;
  }
  
  button {
    padding: 4px 12px;
    background-color: #2196f3;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
  
  h3 {
    margin: 0;
  }
</style>
```

```typescript
// In your component
selectedFile: string | null = null;

selectFile(filename: string): void {
  this.selectedFile = filename;
}
```
