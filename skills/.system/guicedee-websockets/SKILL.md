---
name: guicedee-websockets
description: "RFC 6455 WebSocket support for GuicedEE using Vert.x 5: call-scoped connections, action-based message routing via IWebSocketMessageReceiver SPI, group management and broadcasting, WebSocketServerOptions, and lifecycle hooks. Use when adding WebSocket messaging, implementing real-time communication, managing WebSocket groups, or creating message receivers."
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
 → Per-connection EventBus consumer registered
 → textMessageHandler installed
   → JSON deserialized to WebSocketMessageReceiver
   → Action lookup → IWebSocketMessageReceiver.receiveMessage()
 → closeHandler removes from all groups
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.vertx.sockets;`.
- Message receiver packages must `opens` to `com.google.guice`.
- DTO packages must `opens` to `com.fasterxml.jackson.databind`.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- `receiveMessage()` returns `Uni<Void>` for non-blocking composition.


