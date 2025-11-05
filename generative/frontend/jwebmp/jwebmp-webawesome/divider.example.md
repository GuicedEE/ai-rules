# Divider Examples

## Basic Usage

```html
<wa-divider></wa-divider>
```

## Horizontal Divider with Custom Styling

```html
<!-- Custom color -->
<wa-divider [color]="'#3f51b5'"></wa-divider>

<!-- Custom width -->
<wa-divider [width]="'4px'"></wa-divider>

<!-- Custom spacing -->
<wa-divider [spacing]="'2rem'"></wa-divider>

<!-- Combined custom styling -->
<wa-divider 
  [color]="'#e91e63'" 
  [width]="'3px'" 
  [spacing]="'1.5rem'">
</wa-divider>
```

## Vertical Divider

```html
<wa-divider [vertical]="true"></wa-divider>
```

## Vertical Divider Inside a Flex Container

```html
<div style="display: flex; align-items: center; height: 2rem;">
  First
  <wa-divider [vertical]="true" [spacing]="'1rem'"></wa-divider>
  Middle
  <wa-divider [vertical]="true" [spacing]="'1rem'"></wa-divider>
  Last
</div>
```

## Menu with Divider

```html
<wa-menu style="max-width: 200px;">
  <wa-menu-item value="1">Option 1</wa-menu-item>
  <wa-menu-item value="2">Option 2</wa-menu-item>
  <wa-menu-item value="3">Option 3</wa-menu-item>
  <wa-divider></wa-divider>
  <wa-menu-item value="4">Option 4</wa-menu-item>
</wa-menu>
```

## Divider with String Literal Attributes

```html
<!-- Using string literals instead of property binding -->
<wa-divider vertical></wa-divider>
<wa-divider color="#ff5722" width="2px" spacing="1rem"></wa-divider>
```

## Divider in a Card Layout

```html
<wa-card>
  <h3>Card Title</h3>
  <wa-divider [spacing]="'0.5rem'"></wa-divider>
  <p>Card content goes here.</p>
  <wa-divider [spacing]="'0.5rem'"></wa-divider>
  <div>
    <wa-button>Action</wa-button>
  </div>
</wa-card>
```

## Divider in a Form

```html
<form>
  <div class="form-group">
    <label for="name">Name</label>
    <wa-input id="name"></wa-input>
  </div>
  <wa-divider [spacing]="'1rem'"></wa-divider>
  <div class="form-group">
    <label for="email">Email</label>
    <wa-input id="email" type="email"></wa-input>
  </div>
  <wa-divider [spacing]="'1rem'"></wa-divider>
  <div class="form-group">
    <wa-button type="submit">Submit</wa-button>
  </div>
</form>
```

## Divider with Dynamic Styling

```typescript
// In your component
export class DividerExampleComponent {
  dividerColor = '#673ab7';
  dividerWidth = '2px';
  dividerSpacing = '1rem';
  isVertical = false;
  
  toggleOrientation() {
    this.isVertical = !this.isVertical;
  }
  
  updateColor(color: string) {
    this.dividerColor = color;
  }
}
```

```html
<wa-divider 
  [vertical]="isVertical"
  [color]="dividerColor"
  [width]="dividerWidth"
  [spacing]="dividerSpacing">
</wa-divider>

<div class="controls">
  <wa-button (click)="toggleOrientation()">
    Toggle Orientation
  </wa-button>
  <wa-color-picker [(ngModel)]="dividerColor"></wa-color-picker>
</div>
```

## Divider in a List

```html
<ul style="list-style: none; padding: 0;">
  <li>Item 1</li>
  <wa-divider [spacing]="'0.5rem'"></wa-divider>
  <li>Item 2</li>
  <wa-divider [spacing]="'0.5rem'"></wa-divider>
  <li>Item 3</li>
  <wa-divider [spacing]="'0.5rem'"></wa-divider>
  <li>Item 4</li>
</ul>
```

## Divider in a Dialog

```html
<wa-dialog label="Dialog with Divider">
  <h4>Dialog Title</h4>
  <wa-divider [spacing]="'1rem'"></wa-divider>
  <p>Dialog content goes here.</p>
  <wa-divider [spacing]="'1rem'"></wa-divider>
  <div slot="footer">
    <wa-button data-dialog="close">Close</wa-button>
  </div>
</wa-dialog>
```

## Divider with Responsive Styling

```html
<wa-divider 
  [width]="isMobile ? '1px' : '3px'"
  [spacing]="isMobile ? '0.5rem' : '1.5rem'">
</wa-divider>
```

```typescript
// In your component
export class DividerExampleComponent {
  isMobile = window.innerWidth < 768;
  
  @HostListener('window:resize')
  onResize() {
    this.isMobile = window.innerWidth < 768;
  }
}
```
