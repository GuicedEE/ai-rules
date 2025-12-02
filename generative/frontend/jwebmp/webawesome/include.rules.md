# WaInclude — WebAwesome (JWebMP Wrapper)

Wrapper for `wa-include` to fetch/render remote content. Aligns with ../../webawesome/include.rules.md.

Usage
- Add to clusters/stacks; set src, mode (CorsMode), credentials, and fallback via fluent setters.
- Avoid inline script injection; rely on component sanitization rules.

Patterns
- Keep CRTP chaining; no builders.
- Ensure CORS and caching behaviors are documented for host deployments.
