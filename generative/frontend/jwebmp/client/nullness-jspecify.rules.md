# Nullness (JSpecify) — JWebMP Client

Scope
- Applying JSpecify nullness annotations when consuming or extending JWebMP Client APIs.

Rules
- **Default stance**: Treat parameters and return types as non-null unless annotated; use `@Nullable`/`@NullMarked` where appropriate per JSpecify guidance.
- **API contracts**: Add annotations when creating or modifying public/protected APIs, especially on component setters, event services, and interception hooks.
- **Collections/optionals**: Annotate container element nullness explicitly; avoid ambiguous raw types.
- **Interoperability**: When integrating with third-party code lacking annotations, document nullness expectations in the API surface and adapt at boundaries.
- **Testing**: Include nullness-focused tests for critical APIs; ensure failures occur early with clear messages.

See also
- Topic index — README.md
- JSpecify topic — ../../backend/jspecify/README.md
