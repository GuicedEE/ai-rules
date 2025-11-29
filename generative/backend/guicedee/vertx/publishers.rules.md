# Publishers (VertxEventPublisher)

Inject `VertxEventPublisher<T>` via `@Named(address)` bindings produced by `VertxEventRegistry`/`VertXModule`.

- Injection:
  - Annotate fields/ctors with `@Named("<address>")` matching `@VertxEventDefinition`.
  - Publishers are scoped to the injector; avoid static singletons.
- Operations:
  - `publish(T payload[, DeliveryOptions opts])` — fan-out, no reply expected.
  - `send(T payload[, DeliveryOptions opts])` — request/reply; returns `Future<T>` (use await/compose).
  - Delivery options: set headers/timeouts; prefer deterministic codec names (registry supplies defaults).
- Codec resolution:
  - Registry ensures codecs exist for payload types; avoid manually registering codecs for the same type.
  - If passing JsonObject payloads, align field names with consumer DTOs for automatic mapping.
- Reliability:
  - Handle `Future` failures (timeouts, codec issues) with structured logging; avoid swallowing errors.
  - Keep publishers lightweight; avoid injecting heavy resources unless required by business logic.
- CRTP alignment: when extending publisher helpers, chain fluent methods returning `(T)this` rather than introducing builders.

Example (send with reply)
```java
public class OrderPublisher {
    @Inject
    @Named("inventory.order.created")
    VertxEventPublisher<JsonObject> orders;

    public Future<String> createOrder(JsonObject payload) {
        return orders.send(payload)
            .map(reply -> "order-id:" + reply);
    }
}
```

See also: ./event-definitions.rules.md, ./codecs.rules.md, ./configuration.rules.md, docs/architecture/sequence-publish-consume.md.
