# WaAnimationDirective Usage Examples

The `WaAnimationDirective` is an Angular wrapper for the Web Awesome `<wa-animation>` web component. It provides a declarative way to use animations in Angular applications with full support for Angular's binding syntax.

## Basic Usage

```html
<!-- Basic animation with required attributes -->
<wa-animation name="bounce" play>
  <div class="box"></div>
</wa-animation>

<!-- Animation with duration and iterations -->
<wa-animation 
  name="rubberBand" 
  [duration]="1000" 
  [iterations]="1" 
  play>
  <wa-button variant="brand">Click Me</wa-button>
</wa-animation>

<!-- Animation with dynamic properties -->
<wa-animation 
  [name]="animation" 
  [duration]="2000" 
  [easing]="'ease-in-out'">
  <div class="box"></div>
</wa-animation>
```

## Using Template References

```html
<!-- Using template reference to control animation -->
<wa-animation #myAnim name="flip" [playbackRate]="2">
  <div class="icon"></div>
</wa-animation>
<button (click)="startAnim()">Start</button>
```

```typescript
@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  standalone: true,
  imports: [WaAnimationDirective]
})
export class ExampleComponent {
  @ViewChild('myAnim') animRef!: ElementRef;
  
  startAnim() {
    this.animRef.nativeElement.play = true;
  }
}
```

## Custom Keyframes

```html
<!-- Using custom keyframes -->
<wa-animation [keyframes]="keyframes" [duration]="1000" play>
  <div class="rotating-element"></div>
</wa-animation>
```

```typescript
@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  standalone: true,
  imports: [WaAnimationDirective]
})
export class ExampleComponent {
  keyframes = [
    {
      offset: 0,
      easing: 'ease-in-out',
      fillMode: 'both',
      transform: 'rotate(0deg)'
    },
    {
      offset: 1,
      easing: 'ease-in-out',
      fillMode: 'both',
      transform: 'rotate(90deg)'
    }
  ];
}
```

## Event Handling

```html
<!-- Handling animation events -->
<wa-animation
  (wa-start)="onStart()"
  (wa-finish)="onFinish()"
  (wa-cancel)="onCancel()"
  name="jello"
  play>
  <div class="box"></div>
</wa-animation>
```

```typescript
@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  standalone: true,
  imports: [WaAnimationDirective]
})
export class ExampleComponent {
  onStart() {
    console.log('Animation started');
  }
  
  onFinish() {
    console.log('Animation completed');
  }
  
  onCancel() {
    console.log('Animation cancelled');
  }
}
```

## Custom Styling

```html
<!-- Custom styling using CSS variables -->
<wa-animation 
  name="bounce" 
  [controlBoxSize]="'2.5rem'"
  [iconSize]="'1.5rem'"
  play>
  <div class="box"></div>
</wa-animation>

<!-- Using style binding for CSS variables -->
<wa-animation 
  name="pulse" 
  [style.--control-box-size]="'2rem'"
  [style.--icon-size]="'1.25rem'"
  play>
  <div class="box"></div>
</wa-animation>
```

## Animation Direction and Timing

```html
<!-- Controlling animation direction and timing -->
<wa-animation 
  name="fadeIn" 
  [direction]="'alternate'" 
  [iterations]="3"
  [delay]="500"
  [endDelay]="200"
  [fill]="'forwards'"
  play>
  <div class="box"></div>
</wa-animation>
```

## Dynamic Content

```html
<wa-animation 
  [name]="animationName" 
  [duration]="animationDuration"
  [play]="isPlaying">
  <div class="box"></div>
</wa-animation>
```

```typescript
@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  standalone: true,
  imports: [WaAnimationDirective]
})
export class ExampleComponent {
  animationName = 'bounce';
  animationDuration = 1000;
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
      <wa-animation [name]="animationName" play>
        <div class="box"></div>
      </wa-animation>
    </div>

    <!-- Rendering a list of animations -->
    <div>
      <wa-animation 
        *ngFor="let anim of animations"
        [name]="anim.name"
        [duration]="anim.duration"
        [play]="anim.autoplay">
        <div [class]="anim.elementClass"></div>
      </wa-animation>
    </div>
  `,
  standalone: true,
  imports: [WaAnimationDirective, NgIf, NgFor]
})
export class ExampleComponent {
  showAnimation = true;
  animationName = 'bounce';
  
  animations = [
    { name: 'bounce', duration: 1000, autoplay: true, elementClass: 'box' },
    { name: 'flip', duration: 1500, autoplay: false, elementClass: 'card' },
    { name: 'pulse', duration: 800, autoplay: false, elementClass: 'circle' }
  ];
}
```

## Using with IntersectionObserver

```typescript
@Component({
  selector: 'app-example',
  template: `
    <wa-animation #anim name="fadeIn" [duration]="1000">
      <div class="box" #target></div>
    </wa-animation>
  `,
  standalone: true,
  imports: [WaAnimationDirective]
})
export class ExampleComponent implements AfterViewInit {
  @ViewChild('anim') animRef!: ElementRef;
  @ViewChild('target') targetRef!: ElementRef;
  
  private observer!: IntersectionObserver;
  
  ngAfterViewInit() {
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.animRef.nativeElement.play = true;
        }
      });
    }, { threshold: 0.5 });
    
    this.observer.observe(this.targetRef.nativeElement);
  }
  
  ngOnDestroy() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }
}
```
