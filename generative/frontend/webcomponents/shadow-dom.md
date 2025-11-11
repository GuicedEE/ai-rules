# Shadow DOM (Modular Overview)

Use this modular entry when prompts reference “Shadow DOM”, encapsulation, slots, or styling isolation.

- Why modular: Focused guidance for generative AI.

## Quick start
- Attach: `const root = this.attachShadow({ mode: 'open' })`
- Template: `root.innerHTML = `<style>/* scoped */</style><slot></slot>`
- Select slots: `<slot name="prefix"></slot>` and child uses `slot="prefix"`
- Style parts: expose `::part(name)` from inner components for outer styling

## Minimal example
```javascript
class ShadowCard extends HTMLElement {
  constructor() {
    super();
    const root = this.attachShadow({ mode: 'open' });
    root.innerHTML = `
      <style>
        :host { display: block; border: 1px solid #ddd; padding: 8px; }
        .title { font-weight: bold; }
      </style>
      <div class="title"><slot name="title">Title</slot></div>
      <div class="content"><slot></slot></div>
    `;
  }
}
customElements.define('shadow-card', ShadowCard);
```

## Patterns and guidance
- Prefer `open` mode for app components; `closed` for library internals when necessary.
- Use `:host`, `:host-context()`, and `::slotted()` selectors appropriately.
- Keep light DOM API surface predictable; avoid leaking internal DOM details.

## See also
- Custom Elements — ./custom-elements.md
- HTML Templates — ./html-templates.md
- ES Modules — ./es-modules.md
