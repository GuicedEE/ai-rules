# Angular STOMP continuity

Verified bridge behavior on 2026-10-04. Read this when changing command ownership, private storage, protected policy, socket limits, or reconnects.

### WebSocket Bridge Flow

```text
Angular Client (STOMP)
 └─ ws://host/eventbus
     ├─ SEND /toBus/incoming → application policy → OwnerLocalCommandIngress
     │   ├─ Local-only request → socket owner's local consumer
     │   ├─ Deserialize and dispatch ajax/data/dataSend in WebSocket CallScope
     │   ├─ Reply → requesting connection's registered reply subscription
     │   ├─ SessionStorage → /toStomp/<guid>.SessionStorage on that connection
     │   └─ LocalStorage → /toStomp/<guid>.LocalStorage on that connection
     └─ SUBSCRIBE /toStomp/* ← intended broadcasts via StompEventBusPublisher
         └─ dataReturns still publishes per-key updates where intended
```

### Command ownership, storage, and policy

`OwnerLocalCommandIngress` admits at most 32 concurrent commands per connection, limits body size to 1 MiB, and uses a ten-second local request timeout. It rejects transactional commands and reply addresses absent from that connection's registered subscriptions. The server overwrites `stomp-session` with `connection.session()`; a client-supplied value is not authority.

Session/local storage use `/toStomp/<guid>.SessionStorage` and `/toStomp/<guid>.LocalStorage`. The owner delivers `jwebmp-sessionstorage` / `jwebmp-localstorage` response headers directly to the originating connection's matching subscription. Legacy internal callers still publish to GUID-scoped storage addresses. Neither guessing a GUID nor subscribing elsewhere grants access to another socket's command reply.

Implement and dual-register `StompServerHandlerConfigurator` to extend protected `subscribe`, `send`, `unsubscribe`, and `closed` behavior. A frame method returns `true` when handled, including denial; otherwise the composed defaults remain active. Preserve `configureAll` composition and cleanup. Configuration exceptions abort setup rather than silently removing authorization. Authenticate and authorize before protected ingress; a browser GUID is correlation data.

### Bounded sockets and reconnection

Current bridge limits are body 1 MiB, header length 8192, header count 32, ordinary subscriptions 128, transaction frames 32, and chunk size 16. `BoundedStompSocket` bounds outgoing UTF-8 payloads to 1 MiB and the write queue to 64 KiB, closing overloaded peers with 1013 and the shared two-second physical transport deadline.

STOMP cleanup must compose both `end` and `close` notifications and run once: Vert.x local graceful close can emit `close` without `end`, retaining subscriptions if only `end` is observed. Test an actual peer that stops reading and assert the transport, local consumers, and policy leases are released.

Change Java generator/bridge owners and regenerate; do not hand-edit generated Angular. On reconnect, restore ordinary subscriptions before flushing the bounded command queue, assign fresh server session/private channels, reacquire protected capabilities, and fetch an authoritative snapshot. Do not queue or replay session-bound secure tickets.

### Built-in Message Receivers

| Receiver | Action | Purpose |
|---|---|---|
| `WebSocketAjaxCallReceiver` | `ajax` | Deserializes AjaxCall, fires event, returns AjaxResponse |
| `WebSocketDataRequestCallReceiver` | `data` | Resolves INgDataService, calls getData() |
| `WebSocketDataSendCallReceiver` | `dataSend` | Resolves INgDataService, calls receiveData() |
| `WSAddToGroupMessageReceiver` | `AddToWebSocketGroup` | Adds session to WebSocket group |
| `WSRemoveFromWebsocketGroupMessageReceiver` | `RemoveFromWebSocketGroup` | Removes session from group |

### STOMP Configuration

| Setting | Value | Notes |
|---|---|---|
| WebSocket path | `/eventbus` | STOMP over WebSocket endpoint |
| Server heartbeat | `10000` ms | Server → client |
| Client heartbeat | `50000` ms | Client → server (lenient for background tabs) |
| Sub-protocols | `v10.stomp`, `v11.stomp`, `v12.stomp` | Advertised on HTTP upgrade |
| Idle timeout | `0` (disabled) | Relies on STOMP heartbeats |

### Data Service with WebSocket

```java
@NgDataService
public class LiveDataService implements INgDataService<LiveDataService> {
    @Inject
    private DataRepository repository;

    @Override
    public Object getData(AjaxCall<?> call, AjaxResponse<?> response) {
        String entityId = call.getParameters().get("id");
        return repository.findById(entityId);
    }

    @Override
    public void receiveData(AjaxCall<?> call, AjaxResponse<?> response) {
        String data = call.getParameters().get("data");
        repository.save(data);

        // Push update to all clients in group
        StompEventBusPublisher.publish(IGuiceContext.get(Vertx.class), "updates", data);
    }
}
```

