# Carousel Examples

## Basic Usage

```html
<wa-carousel>
  <wa-carousel-item>
    <img src="https://example.com/image1.jpg" alt="Slide 1">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image2.jpg" alt="Slide 2">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image3.jpg" alt="Slide 3">
  </wa-carousel-item>
</wa-carousel>
```

## With Navigation and Pagination

```html
<wa-carousel navigation pagination>
  <wa-carousel-item>
    <img src="https://example.com/image1.jpg" alt="Slide 1">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image2.jpg" alt="Slide 2">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image3.jpg" alt="Slide 3">
  </wa-carousel-item>
</wa-carousel>
```

## With Autoplay

```html
<wa-carousel autoplay autoplay-interval="5000">
  <wa-carousel-item>
    <img src="https://example.com/image1.jpg" alt="Slide 1">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image2.jpg" alt="Slide 2">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image3.jpg" alt="Slide 3">
  </wa-carousel-item>
</wa-carousel>
```

## With Loop and Mouse Dragging

```html
<wa-carousel loop mouse-dragging>
  <wa-carousel-item>
    <img src="https://example.com/image1.jpg" alt="Slide 1">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image2.jpg" alt="Slide 2">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image3.jpg" alt="Slide 3">
  </wa-carousel-item>
</wa-carousel>
```

## Vertical Orientation

```html
<wa-carousel orientation="vertical" style="height: 400px;">
  <wa-carousel-item>
    <img src="https://example.com/image1.jpg" alt="Slide 1">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image2.jpg" alt="Slide 2">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image3.jpg" alt="Slide 3">
  </wa-carousel-item>
</wa-carousel>
```

## Multiple Slides Per Page

```html
<wa-carousel slides-per-page="3" slides-per-move="1">
  <wa-carousel-item>
    <img src="https://example.com/image1.jpg" alt="Slide 1">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image2.jpg" alt="Slide 2">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image3.jpg" alt="Slide 3">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image4.jpg" alt="Slide 4">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image5.jpg" alt="Slide 5">
  </wa-carousel-item>
</wa-carousel>
```

## Custom Navigation Icons

```html
<wa-carousel navigation>
  <wa-icon slot="previous-icon" name="chevron-left" variant="solid"></wa-icon>
  <wa-icon slot="next-icon" name="chevron-right" variant="solid"></wa-icon>
  
  <wa-carousel-item>
    <img src="https://example.com/image1.jpg" alt="Slide 1">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image2.jpg" alt="Slide 2">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image3.jpg" alt="Slide 3">
  </wa-carousel-item>
</wa-carousel>
```

## With Custom Styling

```html
<style>
  .custom-carousel {
    --aspect-ratio: 16/9;
    --slide-gap: 1rem;
    --pagination-color: #cccccc;
    --pagination-color-active: #ff5722;
    --scroll-hint: 10px;
  }
</style>

<wa-carousel class="custom-carousel" navigation pagination>
  <wa-carousel-item>
    <img src="https://example.com/image1.jpg" alt="Slide 1">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image2.jpg" alt="Slide 2">
  </wa-carousel-item>
  <wa-carousel-item>
    <img src="https://example.com/image3.jpg" alt="Slide 3">
  </wa-carousel-item>
</wa-carousel>
```

## With Rich Content

```html
<wa-carousel navigation pagination>
  <wa-carousel-item>
    <wa-card [withHeader]="true" [withFooter]="true">
      <div slot="header">Card 1 Header</div>
      <p>This is the content of card 1.</p>
      <div slot="footer">
        <wa-button variant="brand">Learn More</wa-button>
      </div>
    </wa-card>
  </wa-carousel-item>
  
  <wa-carousel-item>
    <wa-card [withHeader]="true" [withFooter]="true">
      <div slot="header">Card 2 Header</div>
      <p>This is the content of card 2.</p>
      <div slot="footer">
        <wa-button variant="brand">Learn More</wa-button>
      </div>
    </wa-card>
  </wa-carousel-item>
  
  <wa-carousel-item>
    <wa-card [withHeader]="true" [withFooter]="true">
      <div slot="header">Card 3 Header</div>
      <p>This is the content of card 3.</p>
      <div slot="footer">
        <wa-button variant="brand">Learn More</wa-button>
      </div>
    </wa-card>
  </wa-carousel-item>
</wa-carousel>
```

## Using with Angular Bindings

```html
<wa-carousel 
  [navigation]="showNavigation" 
  [pagination]="showPagination"
  [loop]="enableLoop"
  [autoplay]="enableAutoplay"
  [autoplayInterval]="autoplaySpeed"
  [slidesPerPage]="slidesPerView"
  [slidesPerMove]="slidesToMove"
  [orientation]="carouselOrientation"
  [mouseDragging]="enableMouseDrag"
  (waSlideChange)="onSlideChange($event)">
  
  <wa-carousel-item *ngFor="let slide of slides">
    <img [src]="slide.imageUrl" [alt]="slide.caption">
    <div class="caption">{{slide.caption}}</div>
  </wa-carousel-item>
</wa-carousel>
```

## Programmatic Control

```typescript
import { Component, ViewChild } from '@angular/core';
import { WaCarouselDirective } from './carousel.directive';

@Component({
  selector: 'app-carousel-demo',
  template: `
    <div>
      <wa-carousel #myCarousel navigation pagination>
        <wa-carousel-item *ngFor="let slide of slides">
          <img [src]="slide.imageUrl" [alt]="slide.caption">
        </wa-carousel-item>
      </wa-carousel>
      
      <div class="controls">
        <wa-button (click)="prevSlide()">Previous</wa-button>
        <wa-button (click)="nextSlide()">Next</wa-button>
        <wa-button (click)="goToSlide(2)">Go to Slide 3</wa-button>
      </div>
    </div>
  `
})
export class CarouselDemoComponent {
  @ViewChild('myCarousel') carousel!: WaCarouselDirective;
  
  slides = [
    { imageUrl: 'https://example.com/image1.jpg', caption: 'Slide 1' },
    { imageUrl: 'https://example.com/image2.jpg', caption: 'Slide 2' },
    { imageUrl: 'https://example.com/image3.jpg', caption: 'Slide 3' },
    { imageUrl: 'https://example.com/image4.jpg', caption: 'Slide 4' }
  ];
  
  nextSlide(): void {
    this.carousel.next();
  }
  
  prevSlide(): void {
    this.carousel.previous();
  }
  
  goToSlide(index: number): void {
    this.carousel.goToSlide(index);
  }
}
```
