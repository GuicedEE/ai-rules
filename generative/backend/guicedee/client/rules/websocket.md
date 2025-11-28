# WebSocket Rules — GuicedEE Inject Client

Scope
- Defines how to implement and register WebSocket-related SPIs under package com.guicedee.client.services.websocket for host applications that integrate client-side message handling.

SPIs and Contracts
- IWebSocketMessageReceiver<R,J>
  - Purpose: Handle inbound messages identified by an action/name.
  - Contract:
    - Set<String> messageNames() — return unique action names handled by this receiver.
    - Uni<R> receiveMessage(WebSocketMessageReceiver<?> message) — handle message asynchronously; may throw SecurityException.
- IGuicedWebSocket
  - Purpose: Registry and helpers for message receivers, group management, and broadcasting.
  - Helpers/Constants:
    - addWebSocketMessageReceiver(IWebSocketMessageReceiver)
    - isWebSocketReceiverRegistered(String)
    - getMessagesListeners()
    - loadWebSocketReceivers()
    - EveryoneGroup constant for broadcast-to-all semantics
- IWebSocketAuthDataProvider<J>
  - Purpose: Provide authentication/bootstrap JavaScript and a unique provider name.
- IWebSocketPreConfiguration<J>
  - Purpose: Perform pre-use configuration before sockets are utilized.
- Hooks
  - GuicedWebSocketOnAddToGroup<J> — CompletableFuture<Boolean> onAddToGroup(String groupName)
  - GuicedWebSocketOnRemoveFromGroup<J> — CompletableFuture<Boolean> onRemoveFromGroup(String groupName)
  - GuicedWebSocketOnPublish<J> — boolean publish(String groupName, String message) throws Exception

Registration Policy (mandatory)
- Prefer ServiceLoader-based discovery for receivers; also support programmatic registration via IGuicedWebSocket.addWebSocketMessageReceiver(receiver).
- Dual registration rule applies for any SPIs implemented by JPMS modules: declare providers in META-INF/services AND module-info.java provides clauses. See ../services/services.md for file names and examples.

Naming and Collisions
- messageNames() values must be globally unique within the host process. Collisions will overwrite receivers in the registry map; avoid by namespacing (e.g., "tenantX.action").

Threading and Performance
- receiveMessage should be non-blocking and return promptly using Mutiny Uni composition. Avoid blocking calls; offload to worker threads where needed.

References
- Source package: com.guicedee.client.services.websocket
- Host implementation examples: see ../../../../src/main/java/com/guicedee/client/services/websocket/
- Topic index: ../README.md