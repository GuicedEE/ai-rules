# Interception & AJAX Pipeline — JWebMP Client

Scope
- How consumers register and use AJAX/Data/Site interceptors, validate inputs, and shape responses.

Rules
- **Call scope**: `AjaxCall` and `AjaxResponse` are call-scoped; avoid singletons/static caches for request data.
- **ServiceLoader discovery**: Register interceptors via ServiceLoader (and JPMS `provides` if applicable). Keep ordering deterministic; allow short-circuit when an interceptor finalizes a response.
- **Validation**: Treat browser inputs as untrusted. Validate/sanitize before touching component trees or serialization; reject malformed payloads early.
- **Response shaping**: Event services fill `AjaxResponse`; interceptors may augment but should avoid side effects beyond the call.
- **Logging**: Use Log4j2 per GuicedEE defaults; redact PII/secrets.
- **Testing guidance**: Test interceptor chains and serialization; use Mutiny test utilities if reactive wrappers are present.

See also
- Topic index — README.md
- Integration & JPMS — configuration.rules.md
- GuicedEE Client — ../../backend/guicedee/client/README.md
