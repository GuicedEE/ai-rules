# Tag Examples

## Basic Usage

```html
<wa-tag ngModel>Basic Tag</wa-tag>
```

## Variants

```html
<!-- Brand variant -->
<wa-tag ngModel variant="brand">Brand</wa-tag>

<!-- Neutral variant -->
<wa-tag ngModel variant="neutral">Neutral</wa-tag>

<!-- Success variant -->
<wa-tag ngModel variant="success">Success</wa-tag>

<!-- Warning variant -->
<wa-tag ngModel variant="warning">Warning</wa-tag>

<!-- Danger variant -->
<wa-tag ngModel variant="danger">Danger</wa-tag>
```

## Appearances

```html
<!-- Accent appearance -->
<wa-tag ngModel appearance="accent">Accent</wa-tag>

<!-- Outlined accent appearance -->
<wa-tag ngModel appearance="outlined accent">Outlined Accent</wa-tag>

<!-- Filled appearance -->
<wa-tag ngModel appearance="filled">Filled</wa-tag>

<!-- Outlined appearance -->
<wa-tag ngModel appearance="outlined">Outlined</wa-tag>

<!-- Outlined filled appearance (default) -->
<wa-tag ngModel appearance="outlined filled">Outlined Filled</wa-tag>
```

## Sizes

```html
<!-- Small size -->
<wa-tag ngModel size="small">Small</wa-tag>

<!-- Medium size -->
<wa-tag ngModel size="medium">Medium</wa-tag>

<!-- Large size -->
<wa-tag ngModel size="large">Large</wa-tag>
```

## Pill Shape

```html
<!-- Regular tag -->
<wa-tag ngModel>Regular</wa-tag>

<!-- Pill-shaped tag -->
<wa-tag ngModel [pill]="true">Pill</wa-tag>
```

## Removable Tags

```html
<!-- Non-removable tag -->
<wa-tag ngModel>Non-removable</wa-tag>

<!-- Removable tag -->
<wa-tag ngModel [removable]="true" (waRemove)="handleRemove($event)">Removable</wa-tag>
```

## Combined Examples

```html
<!-- Success pill tag with filled appearance -->
<wa-tag 
  ngModel 
  variant="success" 
  appearance="filled" 
  [pill]="true"
>
  Success
</wa-tag>

<!-- Warning removable tag with medium size -->
<wa-tag 
  ngModel 
  variant="warning" 
  size="medium" 
  [removable]="true" 
  (waRemove)="handleRemove($event)"
>
  Warning
</wa-tag>

<!-- Danger outlined accent tag -->
<wa-tag 
  ngModel 
  variant="danger" 
  appearance="outlined accent" 
  size="large"
>
  Danger
</wa-tag>
```

## Using with Angular Components

```typescript
import { Component } from '@angular/core';
import { WaTagDirective } from '@angular-awesome/directives/tag';

@Component({
  selector: 'app-tag-demo',
  template: `
    <div class="tag-container">
      <wa-tag 
        *ngFor="let tag of tags" 
        ngModel
        [variant]="tag.variant" 
        [appearance]="tag.appearance"
        [removable]="true"
        (waRemove)="removeTag(tag)"
      >
        {{ tag.label }}
      </wa-tag>
      
      <button (click)="addTag()">Add Tag</button>
    </div>
  `,
  standalone: true,
  imports: [WaTagDirective]
})
export class TagDemoComponent {
  tags = [
    { id: 1, label: 'Angular', variant: 'brand', appearance: 'filled' },
    { id: 2, label: 'React', variant: 'neutral', appearance: 'outlined' },
    { id: 3, label: 'Vue', variant: 'success', appearance: 'accent' }
  ];
  
  removeTag(tagToRemove: any) {
    this.tags = this.tags.filter(tag => tag.id !== tagToRemove.id);
  }
  
  addTag() {
    const variants = ['brand', 'neutral', 'success', 'warning', 'danger'];
    const appearances = ['accent', 'outlined accent', 'filled', 'outlined', 'outlined filled'];
    
    this.tags.push({
      id: this.tags.length + 1,
      label: `Tag ${this.tags.length + 1}`,
      variant: variants[Math.floor(Math.random() * variants.length)],
      appearance: appearances[Math.floor(Math.random() * appearances.length)]
    });
  }
}
```

## Tag Filter Example

```typescript
import { Component } from '@angular/core';
import { WaTagDirective } from '@angular-awesome/directives/tag';

interface FilterTag {
  id: number;
  label: string;
  selected: boolean;
}

@Component({
  selector: 'app-tag-filter',
  template: `
    <div class="filter-container">
      <h3>Filter by:</h3>
      <div class="tags">
        <wa-tag 
          *ngFor="let tag of filterTags" 
          ngModel
          [variant]="tag.selected ? 'brand' : 'neutral'"
          [appearance]="tag.selected ? 'filled' : 'outlined'"
          (click)="toggleTag(tag)"
        >
          {{ tag.label }}
        </wa-tag>
      </div>
      
      <div class="results" *ngIf="selectedTags.length > 0">
        <p>Filtered by: {{ selectedTags.join(', ') }}</p>
      </div>
    </div>
  `,
  standalone: true,
  imports: [WaTagDirective]
})
export class TagFilterComponent {
  filterTags: FilterTag[] = [
    { id: 1, label: 'JavaScript', selected: false },
    { id: 2, label: 'TypeScript', selected: false },
    { id: 3, label: 'Angular', selected: false },
    { id: 4, label: 'React', selected: false },
    { id: 5, label: 'Vue', selected: false },
    { id: 6, label: 'Node.js', selected: false }
  ];
  
  get selectedTags(): string[] {
    return this.filterTags
      .filter(tag => tag.selected)
      .map(tag => tag.label);
  }
  
  toggleTag(tag: FilterTag) {
    tag.selected = !tag.selected;
  }
}
```
