# Reactive Integration (Vert.x 5 + Mutiny) — JWebMP Client

Scope
- Using Vert.x 5 event loops and Mutiny types with the JWebMP Client library for asynchronous flows (e.g., AJAX handling, background tasks).

Rules
- **Event-loop safety**: Avoid blocking calls on Vert.x event loops; offload blocking work to worker contexts when needed.
- **Mutiny first**: Use Mutiny (`Uni`, `Multi`) for async APIs; do not mix reactive types on the same surface without clear adapters.
- **Backpressure and ordering**: Maintain predictable ordering for UI updates emitted from reactive flows; document expectations in API contracts.
- **Error handling**: Propagate structured errors through Mutiny chains; avoid swallowing exceptions in interceptors or renderers.
- **Interop**: When bridging Vert.x futures, use Mutiny adapters; keep conversions localized to boundary layers.

See also
- Topic index — README.md
- Vert.x bridge — ../../backend/guicedee/vertx/README.md
- GuicedEE platform — ../../backend/guicedee/README.md
