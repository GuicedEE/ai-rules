# Format Bytes Examples

## Basic Usage

```html
<wa-format-bytes [value]="1024"></wa-format-bytes>
```

## With Two-Way Binding

```html
<wa-format-bytes [(ngModel)]="fileSize"></wa-format-bytes>
```

```typescript
// In your component
export class FormatBytesExampleComponent {
  fileSize = 1024;
}
```

## Different Units

```html
<!-- Default is 'byte' -->
<wa-format-bytes [value]="1024"></wa-format-bytes>

<!-- Using 'bit' -->
<wa-format-bytes [value]="1024" unit="bit"></wa-format-bytes>
```

## Display Options

```html
<!-- Default is 'short' -->
<wa-format-bytes [value]="1024"></wa-format-bytes>

<!-- Long format -->
<wa-format-bytes [value]="1024" display="long"></wa-format-bytes>

<!-- Narrow format -->
<wa-format-bytes [value]="1024" display="narrow"></wa-format-bytes>
```

## Localization

```html
<!-- Default uses browser locale -->
<wa-format-bytes [value]="1024"></wa-format-bytes>

<!-- German locale -->
<wa-format-bytes [value]="1024" lang="de"></wa-format-bytes>

<!-- French locale -->
<wa-format-bytes [value]="1024" lang="fr"></wa-format-bytes>

<!-- Japanese locale -->
<wa-format-bytes [value]="1024" lang="ja"></wa-format-bytes>
```

## Combined Options

```html
<wa-format-bytes 
  [value]="1024" 
  unit="bit" 
  display="long" 
  lang="de">
</wa-format-bytes>
```

## In a Form

```html
<form>
  <div class="form-group">
    <label for="fileSize">File Size (bytes):</label>
    <input 
      type="number" 
      id="fileSize" 
      [(ngModel)]="fileSize" 
      name="fileSize">
  </div>

  <div class="form-group">
    <label>Formatted Size:</label>
    <wa-format-bytes [value]="fileSize"></wa-format-bytes>
  </div>
</form>
```

## With Dynamic Values

```html
<div>
  <input 
    type="range" 
    [(ngModel)]="fileSize" 
    min="0" 
    max="1073741824" 
    step="1024">

  <p>
    Raw value: {{ fileSize }} bytes
  </p>

  <p>
    Formatted (bytes): <wa-format-bytes [value]="fileSize" unit="byte"></wa-format-bytes>
  </p>

  <p>
    Formatted (bits): <wa-format-bytes [value]="fileSize" unit="bit"></wa-format-bytes>
  </p>
</div>
```

## In a Table

```html
<!-- Example of using format-bytes in a table -->
<table>
  <thead>
    <tr>
      <th>File Name</th>
      <th>Size (bytes)</th>
      <th>Formatted Size</th>
    </tr>
  </thead>
  <tbody>
    <!-- Using ngFor to iterate through files -->
    <tr *ngFor="let file of files">
      <td>{{ file.name }}</td>
      <td>{{ file.size }}</td>
      <td><wa-format-bytes [value]="file.size"></wa-format-bytes></td>
    </tr>
  </tbody>
</table>
```

```typescript
// In your component
export class FormatBytesExampleComponent {
  files = [
    { name: 'document.pdf', size: 1024 * 1024 * 2.5 }, // 2.5 MB
    { name: 'image.jpg', size: 1024 * 512 }, // 512 KB
    { name: 'spreadsheet.xlsx', size: 1024 * 1024 * 5.2 }, // 5.2 MB
    { name: 'video.mp4', size: 1024 * 1024 * 1024 * 1.3 } // 1.3 GB
  ];
}
```

## With Conditional Display

```html
<div *ngIf="fileSize > 0">
  File size: <wa-format-bytes [value]="fileSize"></wa-format-bytes>
</div>
<div *ngIf="fileSize === 0">
  Empty file
</div>
```

## In a File Upload Component

```html
<div class="file-upload">
  <input 
    type="file" 
    (change)="onFileSelected($event)">

  <div *ngIf="selectedFile">
    <p>Selected file: {{ selectedFile.name }}</p>
    <p>Size: <wa-format-bytes [value]="selectedFile.size"></wa-format-bytes></p>
  </div>
</div>
```

```typescript
// In your component
export class FormatBytesExampleComponent {
  selectedFile: File | null = null;

  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.selectedFile = input.files[0];
    }
  }
}
```
