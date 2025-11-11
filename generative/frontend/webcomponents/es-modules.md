# ES Modules (Modular Overview)

Use this modular entry when prompts involve modular JS, `import/export`, or bundling strategies for Web Components.

- Why modular: Concise, AI-oriented guide.

## Quick start
```javascript
// my-el.js
export class MyEl extends HTMLElement { /* ... */ }
customElements.define('my-el', MyEl);

// usage
import './my-el.js';
```

## Patterns and guidance
- Publish as standard ESM; avoid UMD where possible.
- Provide `type="module"` scripts in HTML; consider import maps if needed.
- For libraries, ship modern ESM and a transpiled fallback only if required by consumers.

## See also
- Custom Elements — ./custom-elements.md
- Shadow DOM — ./shadow-dom.md
- HTML Templates — ./html-templates.md
