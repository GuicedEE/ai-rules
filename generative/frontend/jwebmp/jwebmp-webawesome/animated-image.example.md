# WaAnimatedImageDirective Usage Examples

The `WaAnimatedImageDirective` is an Angular wrapper for the Web Awesome `<wa-animated-image>` web component. It provides a declarative way to use animated images in Angular applications with full support for Angular's binding syntax.

## Basic Usage

```html
<!-- Basic animated image with required attributes -->
<wa-animated-image 
  src="assets/animations/loading.gif" 
  alt="Loading animation">
</wa-animated-image>

<!-- Animated image that plays automatically -->
<wa-animated-image 
  src="assets/animations/walk.gif" 
  alt="Walking animation" 
  [play]="true">
</wa-animated-image>
```

## Custom Control Icons

```html
<!-- Using custom play and pause icons -->
<wa-animated-image src="assets/animations/tie.webp" alt="Shoe being tied">
  <wa-icon slot="play-icon" name="play"></wa-icon>
  <wa-icon slot="pause-icon" name="pause"></wa-icon>
</wa-animated-image>
```

## Custom Styling

```html
<!-- Custom icon size -->
<wa-animated-image 
  src="assets/animations/loading.gif" 
  alt="Loading animation" 
  [iconSize]="'1.5rem'">
</wa-animated-image>

<!-- Custom control box size -->
<wa-animated-image 
  src="assets/animations/loading.gif" 
  alt="Loading animation" 
  [controlBoxSize]="'2.5rem'">
</wa-animated-image>
```

## Using CSS Variables

```html
<!-- Using style binding for CSS variables -->
<wa-animated-image 
  src="assets/animations/loading.gif" 
  alt="Loading animation"
  [style.--icon-size]="'1.25rem'"
  [style.--control-box-size]="'2rem'">
</wa-animated-image>

<!-- Custom sizing of the image itself -->
<wa-animated-image 
  src="assets/animations/loading.gif" 
  alt="Loading animation"
  style="width: 160px; height: 160px">
</wa-animated-image>
```

## Event Handling

```html
<!-- Handling load and error events -->
<wa-animated-image 
  src="assets/animations/loading.gif" 
  alt="Loading animation"
  (wa-load)="onImageLoaded($event)"
  (wa-error)="onImageError($event)">
</wa-animated-image>
```

```typescript
@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  standalone: true,
  imports: [WaAnimatedImageDirective]
})
export class ExampleComponent {
  onImageLoaded(event: Event) {
    console.log('Image loaded successfully', event);
  }
  
  onImageError(event: Event) {
    console.error('Image failed to load', event);
  }
}
```

## Dynamic Content

```html
<wa-animated-image 
  [src]="animationSrc" 
  [alt]="animationAlt"
  [play]="isPlaying">
</wa-animated-image>
```

```typescript
@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  standalone: true,
  imports: [WaAnimatedImageDirective]
})
export class ExampleComponent {
  animationSrc = 'assets/animations/loading.gif';
  animationAlt = 'Loading animation';
  isPlaying = false;
  
  togglePlay() {
    this.isPlaying = !this.isPlaying;
  }
}
```

## Integration with Angular Features

```typescript
// Component code
@Component({
  selector: 'app-example',
  template: `
    <!-- Conditional rendering -->
    <div *ngIf="showAnimation">
      <wa-animated-image [src]="animationSrc" [alt]="animationAlt"></wa-animated-image>
    </div>

    <!-- Rendering a list of animations -->
    <div>
      <wa-animated-image 
        *ngFor="let animation of animations"
        [src]="animation.src"
        [alt]="animation.alt"
        [play]="animation.autoplay">
      </wa-animated-image>
    </div>
  `,
  standalone: true,
  imports: [WaAnimatedImageDirective, NgIf, NgFor]
})
export class ExampleComponent {
  showAnimation = true;
  animationSrc = 'assets/animations/loading.gif';
  animationAlt = 'Loading animation';
  
  animations = [
    { src: 'assets/animations/walk.gif', alt: 'Walking animation', autoplay: true },
    { src: 'assets/animations/jump.gif', alt: 'Jumping animation', autoplay: false },
    { src: 'assets/animations/run.gif', alt: 'Running animation', autoplay: false }
  ];
}
```
