# Consumers & Publishers

Detailed API reference for event-bus consumers and publishers in GuicedEE Vert.x.

## Consumer Details

### Method-based consumer

Annotate any method with `@VertxEventDefinition`. The containing class is classpath-scanned, bound as a Guice singleton, and a dedicated `EventConsumerVerticle` is deployed per address.

```java
public class OrderConsumers {

    @VertxEventDefinition(value = "order.created",
            options = @VertxEventOptions(worker = true, workerPool = "orders", workerPoolSize = 8))
    public String handleOrder(Message<OrderRequest> message) {
        return "Accepted: " + message.body().id();
    }

    @VertxEventDefinition("order.shipped")
    public Uni<Void> trackShipment(OrderShipped payload) {
        return Uni.createFrom().voidItem();
    }
}
```

#### Supported return types

| Return type | Behaviour |
|---|---|
| `void` | Fire-and-forget, no reply sent |
| `String`, POJO, primitive | Reply sent with the returned value |
| `Uni<T>` | Reply sent when the Uni completes |
| `Future<T>` | Reply sent when the Future completes |

#### Supported parameter types

| Parameter type | What you receive |
|---|---|
| `Message<T>` | Raw Vert.x `Message` — access headers, reply, fail |
| Any POJO | Jackson-deserialized body via `DynamicCodec` |

### Class-based consumer (legacy)

Annotate the class with `@VertxEventDefinition` and implement `consume(Message<T>)`:

```java
@VertxEventDefinition("user.login")
public class LoginConsumer {
    public void consume(Message<LoginRequest> message) {
        message.reply("OK");
    }
}
```

### `@VertxEventOptions` reference

| Attribute | Default | Purpose |
|---|---|---|
| `localOnly` | `false` | Register as local-only consumer (no cluster) |
| `autobind` | `true` | Auto-start on bootstrap; `false` = manual start |
| `consumerCount` | `1` | Number of consumer instances |
| `worker` | `false` | Dispatch to worker threads instead of event loop |
| `workerPool` | `""` | Named worker pool (empty = Vert.x default) |
| `workerPoolSize` | `0` | Worker pool size (0 = Vert.x default) |
| `instances` | `0` | Alias for `consumerCount`; overrides if > 0 |
| `maxBufferedMessages` | `0` | Backpressure buffer limit |
| `resumeAtMessages` | `0` | Resume threshold |
| `batchWindowMs` | `0` | Batch coalescing window (informational) |
| `batchMax` | `0` | Max batch size (informational) |
| `timeoutMs` | `0` | Send timeout override for request-reply |

### Processing model

- **One verticle per address** — `VertxConsumersStartup` deploys a dedicated `EventConsumerVerticle` for every discovered event address.
- **Scaling** — `instances > 1` deploys N consumer verticles with round-robin dispatch.
- **Worker execution** — `worker = true` dispatches off the event loop. Use for blocking IO/DB.
- **Local-only** — `localOnly = true` registers a local consumer; won't receive cluster messages.
- **Context isolation** — each message dispatches on a duplicated `ContextInternal` to isolate Hibernate Reactive sessions.
- **Autobind** — `autobind = false` skips automatic registration; start manually via injection.

## Publisher Details

Inject `VertxEventPublisher<T>` using `@Named` with the event address:

```java
public class OrderService {

    @Inject
    @Named("order.created")
    private VertxEventPublisher<OrderRequest> publisher;

    public Future<String> create(OrderRequest order) {
        return publisher.request(order);
    }

    public void notify(OrderRequest order) {
        publisher.send(order);
    }

    public void broadcast(OrderRequest order) {
        publisher.publish(order);
    }

    public void local(OrderRequest order) {
        publisher.publishLocal(order);
    }
}
```

### Full publisher API

| Method | Semantics |
|---|---|
| `request(T)` | Point-to-point, waits for reply (`Future<R>`) |
| `request(T, long timeoutMs)` | Same with explicit timeout |
| `request(T, DeliveryOptions)` | Same with delivery options |
| `request(T, Map headers, long timeoutMs)` | Same with headers |
| `send(T)` | Point-to-point fire-and-forget (throttled) |
| `send(T, DeliveryOptions)` | Same with options |
| `sendLocal(T)` | Local-only fire-and-forget |
| `publish(T)` | Broadcast to all consumers (throttled) |
| `publish(T, DeliveryOptions)` | Same with options |
| `publishLocal(T)` | Local-only broadcast |
| `publish(T, Map headers, boolean localOnly)` | Broadcast with headers |
| `send(T, Map headers, boolean localOnly)` | Send with headers |

### Throttling

`publish()` and fire-and-forget `send()` are enqueued in a FIFO queue and drained at a configurable rate. `request()` is always immediate.

| Environment variable | Default | Purpose |
|---|---|---|
| `VERTX_PUBLISH_THROTTLE_MS` | `50` | Global throttle period (0 = disabled) |
| `VERTX_PUBLISH_THROTTLE_MS_<ADDR>` | — | Per-address override |
| `VERTX_PUBLISH_QUEUE_WARN` | `1000` | Backlog warning threshold |
| `VERTX_PUBLISH_QUEUE_WARN_<ADDR>` | — | Per-address warning threshold |

> Address normalization: upper-case, replace `.` and `-` with `_` (e.g. `order.created` → `ORDER_CREATED`).

### Codecs

Custom types are serialized via `DynamicCodec` (Jackson-backed). Codecs are registered automatically at startup by `CodecRegistry.createAndRegisterCodecsForAllEventTypes(vertx)`.

Standard Vert.x types (`String`, `JsonObject`, `JsonArray`, `Buffer`, primitives, `byte[]`) do not need custom codecs.

Ensure DTO packages are opened to `com.fasterxml.jackson.databind`.

## Runtime Environment Variable Overrides

All `@VertxEventOptions` fields can be overridden globally via environment variables or system properties:

| Variable | Type | Purpose |
|---|---|---|
| `VERTX_EVENT_ADDRESS_<ADDR>` | string | Override the resolved address |
| `VERTX_EVENT_LOCAL_ONLY` | boolean | Force local-only consumers |
| `VERTX_EVENT_CONSUMER_COUNT` | int | Default consumer count |
| `VERTX_EVENT_WORKER` | boolean | Default worker mode |
| `VERTX_EVENT_WORKER_POOL` | string | Worker pool name |
| `VERTX_EVENT_WORKER_POOL_SIZE` | int | Worker pool size |
| `VERTX_EVENT_INSTANCES` | int | Verticle instances per address |
| `VERTX_EVENT_TIMEOUT_MS` | long | Consumer timeout |
| `VERTX_EVENT_BATCH_WINDOW_MS` | int | Batch window |
| `VERTX_EVENT_BATCH_MAX` | int | Max batch size |
| `VERTX_EVENT_MAX_BUFFERED_MESSAGES` | int | Backpressure buffer limit |
| `VERTX_EVENT_RESUME_AT_MESSAGES` | int | Resume threshold |

