# Nuxt TDD Overrides

Extends the Architecture → TDD base rules and Vue TDD guidance for Nuxt 3.

Scope
- Pages under `pages/`, server routes under `server/api/`, middleware, plugins, and composables.

Practices
- Use `@nuxt/test-utils` or `nuxt-vitest` to mount pages/composables; configure harnesses with realistic runtime config and route params.
- When testing `useAsyncData`/`useFetch`, stub HTTP responses via Nitro mocks or local test servers; avoid hitting live services.
- Validate server API routes with supertest-like clients calling the Nitro dev server; assert both status codes and JSON payloads.
- Cover adapter-specific logic (edge runtimes) with unit tests that mock `event.node`. Document limitations if adapters differ.
- Ensure plugins annotated with `.client`/`.server` have test coverage for each execution side.
- Keep snapshot tests limited to SSR HTML shells; prefer semantic assertions elsewhere.

References
- Base TDD — rules/generative/architecture/tdd/README.md
- Vue TDD — ../../language/vue/tdd.md
