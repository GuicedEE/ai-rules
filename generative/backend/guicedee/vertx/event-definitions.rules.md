# Event Definitions & Options

Use `@VertxEventDefinition` and `@VertxEventOptions` to declare addresses and delivery behavior for both consumers and publishers.

- Placement:
  - Method-based consumers: annotate public methods; allowed returns: void, value, `Future<T>`, `CompletableFuture<T>`.
  - Interface-based consumers: annotate the implementing class (legacy path); prefer method annotations for clarity.
- Address guidance:
  - Use stable, lowercase, dot-separated addresses (e.g., `inventory.order.created`).
  - Avoid random IDs; registry uses address + payload type to derive Guice keys.
- Options (common):
  - `localOnly` limits handlers to the local event bus.
  - `autobind` controls automatic registration during startup; keep true for default flows.
  - `consumerCount` sets parallel handlers; align with verticle deployment strategy.
- Payload typing:
  - Method parameters may be the payload type or `Message<T>`; JSON payloads convert via Jackson (see ./codecs.rules.md).
  - Reply handling: `send` flows can return a value/Future/CompletableFuture; `publish` ignores replies.
- Annotation discovery happens during `VertXPreStartup`; avoid heavy logic inside annotated methods that would block scanning.
- CRTP alignment: when exposing fluent config helpers around events, return `(T)this`.

Example (method-based consumer)
```java
public class InventoryEvents {
    @VertxEventDefinition(
        value = "inventory.order.created",
        options = @VertxEventOptions(localOnly = true, consumerCount = 2)
    )
    public Future<String> onOrder(JsonObject body) {
        // validate & persist
        return Future.succeededFuture("acked");
    }
}
```

See also: ./lifecycle.rules.md, ./publishers.rules.md, ./codecs.rules.md, docs/architecture/sequence-publish-consume.md.
