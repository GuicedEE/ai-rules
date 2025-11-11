# Page Examples

## Basic Usage

```html
<wa-page>
  <header waPageHeader>
    <h1>Page Title</h1>
  </header>
  
  <main>
    <p>Main content goes here.</p>
  </main>
  
  <footer waPageFooter>
    <p>Footer content</p>
  </footer>
</wa-page>
```

## With Navigation

```html
<wa-page>
  <header waPageHeader>
    <h1>Page with Navigation</h1>
  </header>
  
  <nav waPageNavigation>
    <ul>
      <li><a href="#">Home</a></li>
      <li><a href="#">About</a></li>
      <li><a href="#">Services</a></li>
      <li><a href="#">Contact</a></li>
    </ul>
  </nav>
  
  <main>
    <p>Main content with navigation.</p>
  </main>
  
  <footer waPageFooter>
    <p>Footer content</p>
  </footer>
</wa-page>
```

## With Banner and Subheader

```html
<wa-page>
  <div waPageBanner>
    <p>Important announcement or promotional content</p>
  </div>
  
  <header waPageHeader>
    <h1>Page with Banner and Subheader</h1>
  </header>
  
  <div waPageSubheader>
    <nav>
      <ul>
        <li><a href="#">Subheader Link 1</a></li>
        <li><a href="#">Subheader Link 2</a></li>
      </ul>
    </nav>
  </div>
  
  <main>
    <p>Main content with banner and subheader.</p>
  </main>
  
  <footer waPageFooter>
    <p>Footer content</p>
  </footer>
</wa-page>
```

## With Aside Content

```html
<wa-page>
  <header waPageHeader>
    <h1>Page with Aside</h1>
  </header>
  
  <main>
    <p>Main content with aside section.</p>
  </main>
  
  <aside waPageAside>
    <h2>Related Information</h2>
    <ul>
      <li>Related item 1</li>
      <li>Related item 2</li>
      <li>Related item 3</li>
    </ul>
  </aside>
  
  <footer waPageFooter>
    <p>Footer content</p>
  </footer>
</wa-page>
```

## With Menu and Main Header/Footer

```html
<wa-page>
  <header waPageHeader>
    <h1>Page with Menu</h1>
  </header>
  
  <div waPageMenu>
    <h2>Menu</h2>
    <ul>
      <li><a href="#">Menu Item 1</a></li>
      <li><a href="#">Menu Item 2</a></li>
      <li><a href="#">Menu Item 3</a></li>
    </ul>
  </div>
  
  <header waPageMainHeader>
    <h2>Main Content Header</h2>
  </header>
  
  <main>
    <p>Main content with menu and main header/footer.</p>
  </main>
  
  <footer waPageMainFooter>
    <p>Main content footer</p>
  </footer>
  
  <footer waPageFooter>
    <p>Page footer content</p>
  </footer>
</wa-page>
```

## With Skip to Content Link

```html
<wa-page>
  <a href="#main-content" waPageSkipToContent>Skip to content</a>
  
  <header waPageHeader>
    <h1>Accessible Page</h1>
  </header>
  
  <nav waPageNavigation>
    <ul>
      <li><a href="#">Home</a></li>
      <li><a href="#">About</a></li>
      <li><a href="#">Services</a></li>
      <li><a href="#">Contact</a></li>
    </ul>
  </nav>
  
  <main id="main-content">
    <p>Main content with skip to content link for accessibility.</p>
  </main>
  
  <footer waPageFooter>
    <p>Footer content</p>
  </footer>
</wa-page>
```

## Navigation with Header and Footer

```html
<wa-page>
  <header waPageHeader>
    <h1>Page with Navigation Header/Footer</h1>
  </header>
  
  <header waPageNavigationHeader>
    <h2>Navigation Header</h2>
  </header>
  
  <nav waPageNavigation>
    <ul>
      <li><a href="#">Home</a></li>
      <li><a href="#">About</a></li>
      <li><a href="#">Services</a></li>
      <li><a href="#">Contact</a></li>
    </ul>
  </nav>
  
  <footer waPageNavigationFooter>
    <p>Navigation Footer</p>
  </footer>
  
  <main>
    <p>Main content with navigation header and footer.</p>
  </main>
  
  <footer waPageFooter>
    <p>Page footer content</p>
  </footer>
</wa-page>
```

## Custom Styling

```html
<wa-page
  [menuWidth]="'300px'"
  [mainWidth]="'800px'"
  [asideWidth]="'250px'"
  [bannerHeight]="'50px'"
  [headerHeight]="'80px'"
  [subheaderHeight]="'40px'"
>
  <div waPageBanner>Banner content</div>
  
  <header waPageHeader>
    <h1>Custom Styled Page</h1>
  </header>
  
  <div waPageSubheader>Subheader content</div>
  
  <nav waPageNavigation>
    <ul>
      <li><a href="#">Home</a></li>
      <li><a href="#">About</a></li>
      <li><a href="#">Services</a></li>
      <li><a href="#">Contact</a></li>
    </ul>
  </nav>
  
  <div waPageMenu>
    <h2>Menu</h2>
    <ul>
      <li><a href="#">Menu Item 1</a></li>
      <li><a href="#">Menu Item 2</a></li>
      <li><a href="#">Menu Item 3</a></li>
    </ul>
  </div>
  
  <main>
    <p>Main content with custom dimensions.</p>
  </main>
  
  <aside waPageAside>
    <h2>Aside Content</h2>
    <p>Sidebar content here.</p>
  </aside>
  
  <footer waPageFooter>
    <p>Footer content</p>
  </footer>
</wa-page>
```

## Mobile Breakpoint and Navigation Control

```typescript
import { Component } from '@angular/core';
import { WaPageComponent } from '@angular-awesome/directives/page';

@Component({
  selector: 'app-responsive-page-demo',
  template: `
    <wa-page
      [mobileBreakpoint]="'768px'"
      [navOpen]="isNavOpen"
      [navigationPlacement]="'start'"
      (click)="closeNavOnMobile($event)"
    >
      <header waPageHeader>
        <button (click)="toggleNavigation()">
          <span>☰</span> Menu
        </button>
        <h1>Responsive Page</h1>
      </header>
      
      <nav waPageNavigation>
        <ul>
          <li><a href="#">Home</a></li>
          <li><a href="#">About</a></li>
          <li><a href="#">Services</a></li>
          <li><a href="#">Contact</a></li>
        </ul>
      </nav>
      
      <main>
        <p>This page has responsive navigation that can be toggled on mobile devices.</p>
        <p>Current view: {{ currentView }}</p>
        <button (click)="toggleNavigation()">Toggle Navigation</button>
      </main>
      
      <footer waPageFooter>
        <p>Footer content</p>
      </footer>
    </wa-page>
  `,
  standalone: true,
  imports: [WaPageComponent]
})
export class ResponsivePageDemoComponent {
  isNavOpen = false;
  
  get currentView(): string {
    const pageElement = document.querySelector('wa-page');
    return pageElement?.getAttribute('view') || 'unknown';
  }
  
  toggleNavigation() {
    this.isNavOpen = !this.isNavOpen;
  }
  
  closeNavOnMobile(event: MouseEvent) {
    // Close navigation when clicking outside on mobile
    if (this.currentView === 'mobile' && this.isNavOpen) {
      const target = event.target as HTMLElement;
      if (!target.closest('[waPageNavigation]')) {
        this.isNavOpen = false;
      }
    }
  }
}
```

## Disable Sticky Elements

```html
<wa-page [disableSticky]="'header'">
  <header waPageHeader>
    <h1>Page with Non-Sticky Header</h1>
  </header>
  
  <main>
    <p>This page has a header that doesn't stick to the top when scrolling.</p>
    <!-- Add lots of content to enable scrolling -->
  </main>
  
  <footer waPageFooter>
    <p>Footer content</p>
  </footer>
</wa-page>
```

## Dialog Integration

```html
<wa-page>
  <header waPageHeader>
    <h1>Page with Dialog</h1>
  </header>
  
  <main>
    <p>Main content with dialog integration.</p>
    <button (click)="openDialog()">Open Dialog</button>
  </main>
  
  <div waPageDialogWrapper>
    <!-- Dialogs will be rendered here -->
    <wa-dialog id="example-dialog" label="Example Dialog">
      <p>This is a dialog that's properly integrated with the page layout.</p>
      <button slot="footer" (click)="closeDialog()">Close</button>
    </wa-dialog>
  </div>
  
  <footer waPageFooter>
    <p>Footer content</p>
  </footer>
</wa-page>
```

```typescript
// Dialog control methods
function openDialog() {
  const dialog = document.getElementById('example-dialog') as any;
  dialog?.show();
}

function closeDialog() {
  const dialog = document.getElementById('example-dialog') as any;
  dialog?.hide();
}
```
