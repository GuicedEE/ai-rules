# JWebMP Angular — Hosting and Messaging (Vert.x 5, STOMP/WebSocket)

Scope
- Serves the built Angular 20 dist (generated source/config, externally built) via Vert.x 5.
- Bridges client messaging through STOMP over WebSocket to the Vert.x event bus.

Hosting rules
- Router binding: use GuicedEE/Vert.x modules to bind routes; SPA fallback should serve `index.html` for unknown paths.
- Static assets: serve dist root and `/assets`; prevent directory traversal; use real-file checks where applicable.
- Dist path resolution must come from configured webroot/dist (do not hardcode absolute paths).
- Heartbeats: server → client enabled (10s typical); client heartbeats may be disabled—document operational expectations.

Messaging rules
- Endpoint: WebSocket/STOMP at `/eventbus`; clients send to `/toBus/incoming` and receive on `/toStomp.*` or configured topics.
- Consumer: map inbound payloads to `WebSocketMessageReceiver` (session, broadcast group, action, data).
- Dispatch: route to `IGuicedWebSocket` listeners; listeners must validate action/payload and enforce authn/z (no built-in auth provided).
- Replies: return `AjaxResponse` with data, optional session/local storage updates; publish dynamic data only when necessary.
- Performance: avoid blocking operations on event loop; offload heavy work to worker threads if needed.

Security and safeguards
- Require application-layer authentication/authorization for WebSocket/STOMP endpoints.
- Validate payload structure and size; reject unknown actions.
- Monitor heartbeat timeouts and connection counts to mitigate DOS.

See also
- Overview — ./overview.rules.md
- Type generation — ./type-generation.rules.md
- GuicedEE Web/WebSocket — ../../../backend/guicedee/web/README.md, ../../../backend/guicedee/websockets/README.md
- Vert.x hosting — ../../../backend/guicedee/vertx/README.md, ../../../backend/vertx/README.md
- Logging — ../../../backend/logging/README.md
