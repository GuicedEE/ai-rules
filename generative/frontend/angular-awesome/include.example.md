# Include Examples

## Basic Usage

```html
<wa-include [src]="'templates/header.html'"></wa-include>
```

## With Different CORS Modes

```html
<!-- Default mode is 'cors' -->
<wa-include [src]="'https://example.com/content.html'"></wa-include>

<!-- Using 'no-cors' mode -->
<wa-include 
  [src]="'https://example.com/content.html'" 
  mode="no-cors">
</wa-include>

<!-- Using 'same-origin' mode -->
<wa-include 
  [src]="'templates/footer.html'" 
  mode="same-origin">
</wa-include>
```

## Allowing Scripts

By default, scripts in included content are not executed. You can enable script execution with the `allowScripts` attribute:

```html
<wa-include 
  [src]="'templates/interactive-widget.html'" 
  [allowScripts]="true">
</wa-include>
```

> ⚠️ **Security Warning**: Only enable script execution for trusted content sources. Allowing scripts from untrusted sources can lead to cross-site scripting (XSS) vulnerabilities.

## Event Handling

```html
<wa-include 
  [src]="'templates/content.html'"
  (waLoad)="onContentLoaded()"
  (waError)="onLoadError($event)">
</wa-include>
```

```typescript
// In your component
export class IncludeExampleComponent {
  onContentLoaded(): void {
    console.log('Content loaded successfully!');
  }

  onLoadError(error: { status: number }): void {
    console.error('Failed to load content:', error.status);
    // Handle different error codes
    if (error.status === 404) {
      // Handle not found error
    } else if (error.status === 403) {
      // Handle forbidden error
    }
  }
}
```

## Dynamic Source

```html
<wa-include [src]="dynamicContentUrl"></wa-include>

<div class="controls">
  <wa-button (click)="loadHeader()">Load Header</wa-button>
  <wa-button (click)="loadFooter()">Load Footer</wa-button>
  <wa-button (click)="loadSidebar()">Load Sidebar</wa-button>
</div>
```

```typescript
// In your component
export class IncludeExampleComponent {
  dynamicContentUrl = 'templates/default.html';

  loadHeader(): void {
    this.dynamicContentUrl = 'templates/header.html';
  }

  loadFooter(): void {
    this.dynamicContentUrl = 'templates/footer.html';
  }

  loadSidebar(): void {
    this.dynamicContentUrl = 'templates/sidebar.html';
  }
}
```

## Loading State Handling

```html
<ng-container *ngIf="isLoading; else content">
  <div class="loading-spinner">Loading...</div>
</ng-container>

<ng-template #content>
  <wa-include 
    [src]="contentUrl"
    (waLoad)="isLoading = false"
    (waError)="handleError($event)">
  </wa-include>
</ng-template>
```

```typescript
// In your component
export class IncludeExampleComponent {
  contentUrl = 'templates/content.html';
  isLoading = true;
  errorMessage = '';

  handleError(error: { status: number }): void {
    this.isLoading = false;
    this.errorMessage = `Failed to load content: ${error.status}`;
  }
}
```

## Common Use Cases

### Including Partial Views

```html
<!-- Page layout with included partials -->
<header>
  <wa-include [src]="'partials/header.html'"></wa-include>
</header>

<nav>
  <wa-include [src]="'partials/navigation.html'"></wa-include>
</nav>

<main>
  <wa-include [src]="currentView"></wa-include>
</main>

<footer>
  <wa-include [src]="'partials/footer.html'"></wa-include>
</footer>
```

### Including External Content

```html
<!-- Including content from another domain -->
<wa-include 
  [src]="'https://trusted-domain.com/widget.html'"
  mode="cors"
  [allowScripts]="false"
  (waError)="handleExternalContentError($event)">
</wa-include>
```

### Including Templates Based on User Preferences

```html
<wa-include [src]="getUserThemeTemplate()"></wa-include>
```

```typescript
// In your component
export class IncludeExampleComponent {
  userTheme = 'light';

  getUserThemeTemplate(): string {
    return `templates/${this.userTheme}-theme.html`;
  }

  setTheme(theme: 'light' | 'dark'): void {
    this.userTheme = theme;
  }
}
```

### Including Localized Content

```html
<wa-include [src]="getLocalizedTemplate()"></wa-include>
```

```typescript
// In your component
export class IncludeExampleComponent {
  currentLocale = 'en-US';

  getLocalizedTemplate(): string {
    return `templates/${this.currentLocale}/content.html`;
  }

  setLocale(locale: string): void {
    this.currentLocale = locale;
  }
}
```

## Error Handling with Fallback Content

```html
<ng-container *ngIf="!loadError; else errorTemplate">
  <wa-include 
    [src]="contentUrl"
    (waError)="loadError = true">
  </wa-include>
</ng-container>

<ng-template #errorTemplate>
  <div class="error-message">
    <p>Sorry, we couldn't load the requested content.</p>
    <wa-button (click)="retryLoad()">Retry</wa-button>
  </div>
</ng-template>
```

```typescript
// In your component
export class IncludeExampleComponent {
  contentUrl = 'templates/content.html';
  loadError = false;

  retryLoad(): void {
    this.loadError = false;
    // Optionally force a refresh by changing the URL slightly
    this.contentUrl = `templates/content.html?t=${Date.now()}`;
  }
}
```

## Security Considerations

When using the include directive, keep these security best practices in mind:

1. **Only include content from trusted sources** to prevent XSS attacks.
2. **Disable scripts** (`[allowScripts]="false"`) when including content from external sources.
3. **Use CORS appropriately** to control which domains can provide content.
4. **Validate and sanitize** any dynamic URLs before using them as the `src` attribute.
5. **Consider Content Security Policy (CSP)** settings for your application.

```html
<!-- Example with security best practices -->
<wa-include 
  [src]="sanitizedUrl" 
  mode="same-origin"
  [allowScripts]="false">
</wa-include>
```

```typescript
// In your component
import { DomSanitizer, SafeUrl } from '@angular/platform-browser';

export class SecureIncludeExampleComponent {
  rawUrl = 'templates/content.html';
  sanitizedUrl: SafeUrl;

  constructor(private sanitizer: DomSanitizer) {
    // Sanitize URLs before using them
    this.sanitizedUrl = this.sanitizer.bypassSecurityTrustResourceUrl(this.rawUrl);
  }
}
```
