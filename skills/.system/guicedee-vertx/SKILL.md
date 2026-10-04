---
name: guicedee-vertx
description: "Build GuicedEE Vert.x event-bus consumers, publishers, codecs, verticles, clustering, and reactive runtime extensions."
---

# GuicedEE Vert.x

Wire Vert.x 5 into the GuicedEE lifecycle with zero manual bootstrap.

## Core Concept

Production Vert.x starts through the GuicedEE lifecycle SPI; use the injected instance. Explicit instances are appropriate in isolated runtime fixtures:

```
IGuiceContext.instance().inject()
 └─ VertXPreStartup   (IGuicePreStartup)  → creates Vertx, scans events, registers codecs
     └─ VerticleBuilder                    → deploys verticles from @Verticle annotations
         └─ VertxConsumersStartup          → deploys one EventConsumerVerticle per address
 └─ VertXModule        (IGuiceModule)      → binds Vertx, consumers, publishers into Guice
 └─ VertXPostStartup   (IGuicePreDestroy)  → closes Vertx on shutdown
```

Bootstrap with:

```java
IGuiceContext.registerModuleForScanning.add("my.app");
IGuiceContext.instance().inject();
```

## Required Flow

1. Add `com.guicedee:vertx` dependency.
2. Configure `module-info.java`:
   - `requires com.guicedee.vertx;`
   - `opens` consumer/publisher packages to `com.google.guice` and `com.guicedee.vertx`
   - `opens` DTO packages to `tools.jackson.databind`
3. Declare consumers with `@VertxEventDefinition` on methods (preferred) or classes.
4. Inject publishers via `@Inject @Named("address") VertxEventPublisher<T>`.
5. Optionally configure runtime via `@VertX`, `@EventBusOptions`, `@MetricsOptions`, `@FileSystemOptions`, `@AddressResolverOptions` on `package-info.java` (preferred) or any class.
6. Optionally implement SPI hooks (`VertxConfigurator`, `ClusterVertxConfigurator`, `VerticleStartup`) and dual-register in `module-info.java` + `META-INF/services/`.

## Consumers — Quick Reference

### Method-based (preferred)

```java
public class OrderConsumers {
    @VertxEventDefinition(value = "order.created",
            options = @VertxEventOptions(worker = true))
    public String handleOrder(Message<OrderRequest> message) {
        return "Accepted: " + message.body().id();
    }
}
```

- One `EventConsumerVerticle` deployed per address.
- `Message<T>` parameter gives raw access; any POJO parameter is Jackson-deserialized.
- Return `void`, a value, `Uni<T>`, or `Future<T>`.
- Set `worker = true` for blocking IO/DB work.

### Class-based (legacy)

```java
@VertxEventDefinition("user.login")
public class LoginConsumer {
    public void consume(Message<LoginRequest> message) { message.reply("OK"); }
}
```

## Publishers — Quick Reference

```java
@Inject @Named("order.created")
private VertxEventPublisher<OrderRequest> publisher;

publisher.request(order);      // request/reply → Future<R>
publisher.send(order);         // point-to-point fire-and-forget (throttled)
publisher.publish(order);      // broadcast to all consumers (throttled)
publisher.publishLocal(order); // local-only broadcast
```

`request()` is immediate; `send()`/`publish()` are throttled (default 50 ms FIFO drain).

## Non-Negotiable Constraints

- In production, use the injected `Vertx` from `VertXModule`; isolated tests must own and close their explicit instances.
- At most **one** `@VertX` annotation per application.
- Consumer/publisher packages must `opens` to `com.google.guice` and `com.guicedee.vertx`.
- DTO packages must `opens` to `tools.jackson.databind`.
- JSON is **Jackson 3** (`tools.jackson.databind`/`tools.jackson.core`); only annotations stay on `com.fasterxml.jackson.annotation` (2.x). Vert.x JSON (`Json.encode`/`decode`, `JsonObject.mapTo`/`mapFrom`, event-bus payloads) is routed through the shared `DefaultObjectMapper` via the registered `io.vertx.core.spi.JsonFactory` (`GuicedVertxJsonFactory`).
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- Use `worker = true` for any blocking or IO-bound consumer.
- `package-info.java` is preferred for package-level annotations; classes work too.
- Do not share packages between main and test source sets.

## Clustering and socket continuity

- An incidental Hazelcast dependency does not activate clustering. Resolve `VERTX_CLUSTER_ENABLED`, intentional server configuration, and `ClusterVertxConfigurator.enabled()` before calling `buildClustered()`. Disabled mode must start an ordinary Vert.x instance without creating a member or client.
- `VertxConfigurator.options(VertxOptions)` customizes the one shared options object. Apply all options hooks before attaching that object to the builder once; then compose `builder(VertxBuilder)` hooks. Preserve metrics, event-bus bind/advertised endpoints, and pool sizes together.
- Startup ordering is metrics `MIN_VALUE + 36`, prepared Hazelcast server configuration `+37`, then Vert.x `+38`. Startup failure must propagate to GuicedEE and roll back partially owned resources.
- Shutdown uses `IGuicePreDestroy.shutdownSortOrder()`: await Vert.x close at `MAX_VALUE - 200` before owned Hazelcast resources at `MAX_VALUE - 100`. Do not call global Hazelcast shutdown APIs that affect unrelated instances.
- Commands from a socket execute on its owning node through a local consumer/request. Keep cluster `publish` for intended public broadcasts; changing a shared broadcast bridge to `send` breaks fan-out.
- Raw and STOMP sockets use `WebSocketBackpressure.close` for a two-second physical transport deadline when a peer stops reading. Preserve request capture before route wrappers; a WebSocket close-handshake timeout alone can wait indefinitely for a blocked close-frame flush.

Read [Clustering and WebSocket continuity](references/clustering-continuity.md) when implementing activation, private delivery, capability leases, readiness, reconnects, or multi-JVM acceptance. It distinguishes framework behavior from Core-specific policy and records the tested artifact workflow.

## References

- `references/consumers-publishers.md` — full consumer/publisher API, parameter/return tables, throttling config, environment variable overrides.
- `references/verticles-runtime.md` — `@Verticle` configuration, capabilities enum, runtime annotation details (`@VertX`, `@EventBusOptions`, etc.), SPI hooks, complete example project.
- `references/module-graph.md` — JPMS module graph and transitive dependencies.
