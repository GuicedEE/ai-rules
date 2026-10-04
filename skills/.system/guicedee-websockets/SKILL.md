---
name: guicedee-websockets
description: "Implement GuicedEE WebSocket receivers, action routing, call-scoped connections, groups, and broadcasts."
metadata:
  short-description: WebSocket messaging with action-based routing inside GuicedEE
---

# GuicedEE WebSockets

Lightweight RFC 6455 WebSocket support for GuicedEE using Vert.x 5.

## Core Concept

Connections are call-scoped, messages are dispatched through an action-based receiver SPI, and group membership is managed via the Vert.x EventBus. Builds on top of `web` for HTTP server plumbing.

## Required Flow

1. Add `com.guicedee:websockets` dependency (pulls in `web` transitively).
2. Implement a message receiver:
   ```java
   public class ChatReceiver implements IWebSocketMessageReceiver<Void, ChatReceiver> {
       @Override
       public Set<String> messageNames() {
           return Set.of("chat");
       }

       @Override
       public Uni<Void> receiveMessage(WebSocketMessageReceiver<?> message) {
           String text = (String) message.getData().get("text");
           IGuicedWebSocket ws = IGuiceContext.get(IGuicedWebSocket.class);
           ws.broadcastMessage("chat:lobby", text);
           return Uni.createFrom().voidItem();
       }
   }
   ```
3. Register via JPMS:
   ```java
   module my.app {
       requires com.guicedee.vertx.sockets;
       provides com.guicedee.client.services.websocket.IWebSocketMessageReceiver
           with my.app.ChatReceiver;
   }
   ```
4. Bootstrap GuicedEE — WebSocket server starts automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   ```

## Message Protocol

Inbound messages are JSON with an `action` field for routing:

```json
{ "action": "chat", "data": { "text": "Hello, world!" } }
```

| Field | Type | Required | Purpose |
|---|---|---|---|
| `action` | `String` | ✅ | Routes to matching `IWebSocketMessageReceiver` |
| `data` | `Map<String, Object>` | ❌ | Arbitrary key/value payload |
| `broadcastGroup` | `String` | ❌ | Auto-set to connection's `RequestContextId` |
| `webSocketSessionId` | `String` | ❌ | Optional client-set session identifier |

## Group Management

Every connection is added to the `Everyone` group automatically.

```java
IGuicedWebSocket ws = IGuiceContext.get(IGuicedWebSocket.class);
ws.addToGroup("chat:lobby");
ws.removeFromGroup("chat:lobby");
ws.broadcastMessage("chat:lobby", "Hello everyone!");
ws.broadcastMessageSync("chat:lobby", "Immediate message");
```

## SPI Lifecycle Hooks

| SPI | Purpose |
|---|---|
| `GuicedWebSocketOnAddToGroup` | Intercept group join |
| `GuicedWebSocketOnRemoveFromGroup` | Intercept group leave |
| `GuicedWebSocketOnPublish` | Intercept broadcast |

## Connection Lifecycle

```
Client connects (ws://...)
 → CallScoper enters @CallScope
 → Connection added to "Everyone" group
 → Socket joins local membership; one EventBus consumer serves each group
 → textMessageHandler installed
   → JSON deserialized to WebSocketMessageReceiver
   → Action lookup → IWebSocketMessageReceiver.receiveMessage()
 → closeHandler removes from all groups
```

## Cluster groups and bounded cleanup

Group broadcast publishes to the existing group event-bus address so other nodes receive it. Keep one consumer per group and idempotent socket membership; a fallback that loops only over the current JVM's sockets loses cluster fan-out. The current registry caps groups per node and recipients per group at 4096, and group names at 256 characters.

Close and group removal clear membership, unregister empty-group consumers, and remove call-scope/socket context properties. Some Vert.x server sockets have no `textHandlerID`; use a server-generated UUID and explicit socket/context mapping rather than a null map key. Cleanup must be idempotent across normal close, exceptions, and overload.

The current raw-socket path sets a 64 KiB write queue and rejects outgoing payloads above 1 MiB measured in UTF-8 bytes. A full queue closes with status 1013 using `WebSocketBackpressure.close`, including the two-second transport deadline. Route-upgraded sockets need capture at the HTTP request handoff. Prove physical closure and empty registries with an actual TCP peer that stops reading; a mocked `writeQueueFull()` result proves only branch handling.

`RequestContextId`, browser GUID, and client session fields are correlation data. Authenticate and authorize each protected action from verified server context. Use explicit Vert.x/server constructors only in isolated fixtures with deterministic teardown; production uses injected lifecycle resources.

## Non-Negotiable Constraints

- Module must `requires com.guicedee.vertx.sockets;`.
- Message receiver packages must `opens` to `com.google.guice`.
- DTO packages must `opens` to `tools.jackson.databind`.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- `receiveMessage()` returns `Uni<Void>` for non-blocking composition.
