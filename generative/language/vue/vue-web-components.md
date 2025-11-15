# Web Components in Vue

Guidance for consuming or exporting Custom Elements from Vue applications.

Consuming
- Register web components once per app entry (e.g., import `@shoelace-style/shoelace/dist/components/button/button.js`).
- Wrap components lacking Vue bindings inside wrapper SFCs to translate props/events to camelCase emitters.
- Use `defineCustomElement` only when shipping Vue components as custom elements; keep CSS scoped and avoid runtime-only APIs unsupported in CE builds.
- For SSR (Nuxt), guard custom element imports behind `if (process.client)` or lazy-load with dynamic components to prevent hydration mismatch.

Emitting
- When exposing Vue components as custom elements, create dedicated entry files via `defineCustomElement(App)` and register with `customElements.define`.
- Document attribute/event mappings inside the Vue topic glossary and host GLOSSARY.md.

Testing
- Use Web Components topic rules for end-to-end semantics (rules/generative/frontend/webcomponents/README.md).
- Mount wrappers in Vue Test Utils and assert custom events via `wrapper.element.addEventListener`.
