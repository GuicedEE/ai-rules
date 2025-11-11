# WaBadgeComponent Usage Examples

The `WaBadgeComponent` is an Angular wrapper for the Web Awesome `<wa-badge>` web component. It provides a declarative way to use badges in Angular applications with full support for Angular's binding syntax.

## Basic Usage

```html
<wa-badge variant="brand">Brand</wa-badge>
```

## Appearance Options

```html
<!-- Default accent appearance -->
<wa-badge variant="success">Success</wa-badge>

<!-- Filled appearance -->
<wa-badge variant="warning" appearance="filled">Warning</wa-badge>

<!-- Outlined appearance -->
<wa-badge variant="danger" appearance="outlined">Danger</wa-badge>
```

## Shape Options

```html
<!-- Pill shape (rounded) -->
<wa-badge variant="brand" [pill]="true">Rounded</wa-badge>

<!-- With pulse animation -->
<wa-badge variant="danger" [pulse]="true">Alert</wa-badge>

<!-- Combined options -->
<wa-badge variant="warning" appearance="filled" [pill]="true" [pulse]="true">
  Important
</wa-badge>
```

## Custom Styling

```html
<!-- Custom font size -->
<wa-badge variant="success" [fontSize]="'var(--wa-font-size-s)'">✓</wa-badge>

<!-- Custom colors -->
<wa-badge 
  [backgroundColor]="'#e6f7ff'" 
  [borderColor]="'#1890ff'" 
  [textColor]="'#0050b3'">
  Custom
</wa-badge>
```

## Dynamic Content

```html
<wa-badge variant="brand" [pill]="isPill" [pulse]="isPulsing">
  {{ count }}
</wa-badge>
```

```typescript
@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  standalone: true,
  imports: [WaBadgeComponent]
})
export class ExampleComponent {
  count = 5;
  isPill = true;
  isPulsing = false;
}
```

## Integration with Angular Features

```typescript
// Component code
@Component({
  selector: 'app-example',
  template: `
    <!-- Conditional rendering -->
    <div *ngIf="showBadge">
      <wa-badge variant="success">Available</wa-badge>
    </div>

    <!-- Rendering a list of badges -->
    <div>
      <wa-badge 
        *ngFor="let status of statuses"
        [variant]="status.type"
        [appearance]="status.appearance">
        {{ status.label }}
      </wa-badge>
    </div>
  `,
  standalone: true,
  imports: [WaBadgeComponent, NgIf, NgFor]
})
export class ExampleComponent {
  showBadge = true;
  statuses = [
    { type: 'success', appearance: 'accent', label: 'Completed' },
    { type: 'warning', appearance: 'filled', label: 'Pending' },
    { type: 'danger', appearance: 'outlined', label: 'Failed' }
  ];
}
```
