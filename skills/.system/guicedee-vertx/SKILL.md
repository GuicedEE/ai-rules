---
name: guicedee-vertx
description: "Build reactive services using Vert.x 5 inside the GuicedEE DI lifecycle: event-bus consumers, publishers, verticle deployment, codecs, throttling, clustering, SPI hooks, and JPMS module setup. Use when adding Vert.x event-bus messaging, deploying verticles, wiring reactive endpoints with Guice injection, configuring Vert.x runtime options, or implementing custom codecs and cluster managers."
---

# GuicedEE Vert.x

Wire Vert.x 5 into the GuicedEE lifecycle with zero manual bootstrap.

## Core Concept

Vert.x starts automatically via SPI — never create `Vertx` manually:

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
   - `opens` DTO packages to `com.fasterxml.jackson.databind`
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

- Never create `Vertx` manually — use the injected instance from `VertXModule`.
- At most **one** `@VertX` annotation per application.
- Consumer/publisher packages must `opens` to `com.google.guice` and `com.guicedee.vertx`.
- DTO packages must `opens` to `com.fasterxml.jackson.databind`.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- Use `worker = true` for any blocking or IO-bound consumer.
- `package-info.java` is preferred for package-level annotations; classes work too.
- Do not share packages between main and test source sets.

## References

- `references/consumers-publishers.md` — full consumer/publisher API, parameter/return tables, throttling config, environment variable overrides.
- `references/verticles-runtime.md` — `@Verticle` configuration, capabilities enum, runtime annotation details (`@VertX`, `@EventBusOptions`, etc.), SPI hooks, complete example project.
- `references/module-graph.md` — JPMS module graph and transitive dependencies.
