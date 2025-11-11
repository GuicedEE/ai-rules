# Copy Button Examples

## Basic Usage

```html
<wa-copy-button value="Text to copy"></wa-copy-button>
```

## With Custom Labels

```html
<wa-copy-button 
  value="Text to copy"
  copyLabel="Click to copy"
  successLabel="Copied!"
  errorLabel="Failed to copy">
</wa-copy-button>
```

## Copying from Another Element

```html
<wa-input id="myInput" value="Text from input"></wa-input>
<wa-copy-button from="myInput"></wa-copy-button>

<!-- Using property syntax -->
<wa-input id="myInput2" value="Text from input property"></wa-input>
<wa-copy-button from="myInput2.value"></wa-copy-button>

<!-- Using attribute syntax -->
<wa-input id="myInput3" data-copy-value="Text from attribute"></wa-input>
<wa-copy-button from="myInput3[data-copy-value]"></wa-copy-button>
```

## With Custom Feedback Duration

```html
<wa-copy-button 
  value="Text to copy"
  feedbackDuration="5000">
</wa-copy-button>
```

## With Custom Tooltip Placement

```html
<wa-copy-button 
  value="Text to copy"
  tooltipPlacement="right">
</wa-copy-button>

<wa-copy-button 
  value="Text to copy"
  tooltipPlacement="bottom">
</wa-copy-button>

<wa-copy-button 
  value="Text to copy"
  tooltipPlacement="left">
</wa-copy-button>

<wa-copy-button 
  value="Text to copy"
  tooltipPlacement="top">
</wa-copy-button>
```

## Disabled State

```html
<wa-copy-button 
  value="Cannot copy this"
  disabled>
</wa-copy-button>
```

## With Custom Icons

```html
<wa-copy-button value="Text to copy">
  <wa-icon slot="copy-icon" name="copy" variant="regular"></wa-icon>
  <wa-icon slot="success-icon" name="check" variant="solid"></wa-icon>
  <wa-icon slot="error-icon" name="exclamation-circle" variant="solid"></wa-icon>
</wa-copy-button>
```

## Event Handling

```html
<wa-copy-button 
  value="Text to copy"
  (waCopy)="onCopySuccess()"
  (waError)="onCopyError($event)">
</wa-copy-button>
```

```typescript
// In your component
export class CopyButtonExampleComponent {
  onCopySuccess(): void {
    console.log('Text copied successfully!');
  }

  onCopyError(error: Error): void {
    console.error('Failed to copy text:', error);
  }
}
```

## Using with ngModel

```html
<wa-copy-button 
  [(ngModel)]="textToCopy"
  copyLabel="Click to copy"
  successLabel="Copied!">
</wa-copy-button>
```

```typescript
// In your component
export class CopyButtonExampleComponent {
  textToCopy = 'This text can be edited and copied';
}
```

## Styling Examples

### Using Shortcut Classes

```html
<!-- Semantic coloring -->
<wa-copy-button value="Primary style" class="wa-primary"></wa-copy-button>
<wa-copy-button value="Danger style" class="wa-danger"></wa-copy-button>
<wa-copy-button value="Muted style" class="wa-muted"></wa-copy-button>

<!-- Sizing -->
<wa-copy-button value="Small size" class="wa-sm"></wa-copy-button>
<wa-copy-button value="Medium size" class="wa-md"></wa-copy-button>
<wa-copy-button value="Large size" class="wa-lg"></wa-copy-button>

<!-- Display -->
<wa-copy-button value="Inline display" class="wa-inline"></wa-copy-button>
```

### Using Custom CSS

```html
<style>
  .custom-copy-button::part(button) {
    background-color: #6200ee;
    color: white;
    border-radius: 8px;
  }
  
  .custom-copy-button::part(copy-icon) {
    color: white;
  }
  
  .custom-copy-button::part(success-icon) {
    color: #00e676;
  }
  
  .custom-copy-button::part(error-icon) {
    color: #ff1744;
  }
</style>

<wa-copy-button 
  value="Custom styled button"
  class="custom-copy-button">
</wa-copy-button>
```

## Accessibility Examples

```html
<!-- Using aria-label -->
<wa-copy-button 
  value="Text to copy"
  aria-label="Copy text to clipboard">
</wa-copy-button>

<!-- Using contextual labels -->
<label id="copy-label">Copy the following text</label>
<wa-copy-button 
  value="Text to copy"
  aria-labelledby="copy-label">
</wa-copy-button>
```

## Common Use Cases

### Copy Code Snippet

```html
<pre><code id="codeSnippet">
function example() {
  console.log('Hello, world!');
}
</code></pre>
<wa-copy-button 
  from="codeSnippet"
  copyLabel="Copy code"
  successLabel="Code copied!">
</wa-copy-button>
```

### Copy URL

```html
<div class="share-url">
  <span id="pageUrl">https://example.com/shared-page</span>
  <wa-copy-button 
    from="pageUrl"
    copyLabel="Copy URL"
    successLabel="URL copied!">
  </wa-copy-button>
</div>
```

### Copy to Clipboard Button in Form

```html
<div class="form-field">
  <label for="apiKey">Your API Key:</label>
  <wa-input id="apiKey" value="sk_test_abcdefghijklmnopqrstuvwxyz" readonly></wa-input>
  <wa-copy-button 
    from="apiKey"
    copyLabel="Copy API key"
    successLabel="API key copied!">
  </wa-copy-button>
</div>
```
