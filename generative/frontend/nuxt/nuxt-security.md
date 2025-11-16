# Nuxt Security & Runtime Hardening

Key safeguards
- Use `@nuxtjs/eslint-module` + security plugins to enforce linting of dangerous APIs.
- Sanitize all server-route inputs via validation libraries (zod/yup) and rely on Nitro helpers to set status codes.
- Configure CSP headers in `nuxt.config.ts` via `routeRules` or hosting platform settings; avoid `unsafe-inline` by using hashed styles/scripts.
- Lock down runtime config: keep secrets under `runtimeConfig` (server-only) and mirror only safe values under `runtimeConfig.public`.
- Use Nuxt's built-in CSRF protection for forms or implement tokens inside server routes.
- For authentication, integrate with OIDC/OAuth by storing tokens server-side and exposing session cookies with `httpOnly`, `secure`, `sameSite=strict`.
- Validate plugin execution contexts: mark `.client.ts` or `.server.ts` when APIs only exist in one environment to prevent bundle errors.

Observability
- Instrument server routes with logging/tracing per platform topic (e.g., OpenTelemetry) and redact PII before logging.
- Surface health endpoints via Nitro server routes or upstream infrastructure; document them in IMPLEMENTATION.md.

References
- Security/Auth provider rules — rules/generative/platform/security-auth/README.md
- Observability rules — rules/generative/platform/observability/README.md
