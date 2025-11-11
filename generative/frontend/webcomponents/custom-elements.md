# Custom Elements (Modular Overview)

This is the modular entry for the Custom Elements part of the W3C Web Components standard. Prefer starting here when prompts reference “custom element(s)”, “define a tag”, or lifecycle callbacks.

- Why modular: This file distills essentials for fast generative AI consumption.

## Quick start
- Define: `class MyEl extends HTMLElement { /* … */ }`
- Register: `customElements.define('my-el', MyEl)`
- Lifecycle: `constructor`, `connectedCallback`, `disconnectedCallback`, `attributeChangedCallback`, `adoptedCallback`
- Observed attributes: `static get observedAttributes() { return ['name']; }`

## Minimal example
```javascript
class HelloWorld extends HTMLElement {
  constructor() {
    super();
    this.textContent = 'Hello, World!';
  }
}
customElements.define('hello-world', HelloWorld);
```

## Patterns and guidance
- Prefer attributes for simple configuration; use properties for rich objects.
- Use CustomEvent for outputs: `this.dispatchEvent(new CustomEvent('changed', { detail }))`.
- Keep constructors side-effect free; defer DOM work to `connectedCallback`.

## See also
- Shadow DOM — ./shadow-dom.md
- HTML Templates — ./html-templates.md
- ES Modules — ./es-modules.md
