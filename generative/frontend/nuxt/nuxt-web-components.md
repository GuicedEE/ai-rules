# Web Components in Nuxt

Nuxt inherits Vue's custom element support plus SSR considerations.

Usage
- Register web components inside plugins with `.client.ts` suffix to avoid SSR execution errors, or lazy-load them via dynamic imports inside `<client-only>`.
- When SSR is required, use placeholders that hydrate into custom elements only on the client, or leverage server-friendly wrappers that skip registration until mounted.
- Map attributes/events through Vue wrapper components if you need TypeScript typing or slot management.

Exports
- To expose Vue components as custom elements from a Nuxt codebase, create a separate entry with `defineCustomElement` and exclude Nuxt-specific modules (router, runtime config).

Testing
- Use Nuxt + Vue test utils; register custom elements in a shared setup file to avoid duplicate definition errors.
- For end-to-end flows, rely on Web Components topic rules and Nuxt's Playwright harness.

References
- Vue Web Components guide — ../../language/vue/vue-web-components.md
- Web Components topic — ../webcomponents/README.md
