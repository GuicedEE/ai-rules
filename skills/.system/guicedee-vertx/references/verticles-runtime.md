# Verticles & Runtime Configuration

Detailed reference for verticle deployment, runtime annotations, SPI hooks, and a complete example project.

## Verticle Configuration

Use `@Verticle` on a class or `package-info.java` to define deployment units. Each verticle gets its own set of consumers scoped by package prefix.

```java
@Verticle(
        value = "billing",
        workerPoolSize = 16,
        threadingModel = ThreadingModel.EVENT_LOOP,
        defaultInstances = 2,
        capabilities = {Verticle.Capabilities.Rest, Verticle.Capabilities.Persistence}
)
package my.app.billing;

import com.guicedee.vertx.spi.Verticle;
import io.vertx.core.ThreadingModel;
```

When no `@Verticle` is found, a default "everything" verticle is deployed that covers all packages.

### Capabilities enum

| Capability | Package prefix |
|---|---|
| `Rest` | `com.guicedee.guicedservlets.rest` |
| `RabbitMQ` | `com.guicedee.rabbit` |
| `Web` | `com.guicedee.vertx.web` |
| `Telemetry` | `com.guicedee.telemetry` |
| `MicroProfileConfig` | `com.guicedee.microprofile.config` |
| `OpenAPI` | `com.guicedee.guicedservlets.openapi` |
| `Swagger` | `com.guicedee.servlets.swaggerui` |
| `Hazelcast` | `com.guicedee.guicedhazelcast` |
| `Cerial` | `com.guicedee.cerial` |
| `Persistence` | `com.guicedee.guicedpersistence` |
| `Sockets` | `com.guicedee.vertx.websockets` |
| `WebServices` | `com.guicedee.guicedservlets.webservices` |

## Runtime Annotations

Apply at most **one** of each. `package-info.java` is preferred; classes work too.

### `@VertX` — Vert.x options

```java
@VertX(
    eventLoopPoolSize = 8,
    workerPoolSize = 32,
    haEnabled = true,
    quorumSize = 3,
    preferNativeTransport = true
)
package my.app;
import com.guicedee.vertx.spi.VertX;
```

All values overridable via `VERTX_EVENT_LOOP_POOL_SIZE`, `VERTX_WORKER_POOL_SIZE`, `VERTX_HA_ENABLED`, etc.

### `@EventBusOptions`

```java
@EventBusOptions(clusterPublicHost = "192.168.1.1", clusterPublicPort = 8080)
```

### `@MetricsOptions`

```java
@MetricsOptions(enabled = true)
```

### `@FileSystemOptions`

```java
@FileSystemOptions(classPathResolvingEnabled = true, fileCachingEnabled = true, fileCacheDir = "/cache")
```

### `@AddressResolverOptions`

```java
@AddressResolverOptions(servers = {"8.8.8.8", "1.1.1.1"}, rotateServers = true)
```

## SPI Extension Points

### `VertxConfigurator` — customize `VertxBuilder`

```java
public class MyVertxConfig implements VertxConfigurator {
    @Override
    public VertxBuilder builder(VertxBuilder builder) {
        return builder;
    }
}
```

Register in `module-info.java`:
```java
provides com.guicedee.vertx.spi.VertxConfigurator with my.app.MyVertxConfig;
```
And in `META-INF/services/com.guicedee.vertx.spi.VertxConfigurator`.

### `ClusterVertxConfigurator` — add a cluster manager

Extends `VertxConfigurator`. Implement `getClusterManager()`:

```java
public class HazelcastConfig implements ClusterVertxConfigurator {
    @Override
    public ClusterManager getClusterManager() {
        return new HazelcastClusterManager();
    }
}
```

Register under `com.guicedee.vertx.spi.VertxConfigurator`.

### `VerticleStartup` — custom verticle bootstrap

```java
public class MyStartup implements VerticleStartup<MyStartup> {
    @Override
    public void start(Promise<Void> startPromise, Vertx vertx,
                      AbstractVerticle verticle, String assignedPackage) {
        startPromise.complete();
    }

    @Override
    public Integer sortOrder() { return 100; }
}
```

Register under `com.guicedee.vertx.spi.VerticleStartup`.

## Complete Example Project

### Structure

```
my-app/
  src/main/java/
    module-info.java
    my/app/
      package-info.java
      AppMain.java
      events/
        OrderConsumers.java
        OrderService.java
      model/
        OrderRequest.java
```

### `module-info.java`

```java
module my.app {
    requires com.guicedee.vertx;
    requires com.guicedee.client;

    opens my.app to com.google.guice;
    opens my.app.events to com.google.guice, com.guicedee.vertx;
    opens my.app.model to com.fasterxml.jackson.databind;
}
```

### `package-info.java`

```java
@VertX(workerPoolSize = 32)
@EventBusOptions(preferNativeTransport = true)
package my.app;

import com.guicedee.vertx.spi.VertX;
import com.guicedee.vertx.spi.EventBusOptions;
```

### `AppMain.java`

```java
package my.app;

import com.guicedee.client.IGuiceContext;

public class AppMain {
    public static void main(String[] args) {
        IGuiceContext.registerModuleForScanning.add("my.app");
        IGuiceContext.instance().inject();
    }
}
```

### `OrderRequest.java`

```java
package my.app.model;
public record OrderRequest(String id, String product, int quantity) {}
```

### `OrderConsumers.java`

```java
package my.app.events;

import com.guicedee.vertx.VertxEventDefinition;
import com.guicedee.vertx.VertxEventOptions;
import io.vertx.core.eventbus.Message;

public class OrderConsumers {
    @VertxEventDefinition(value = "order.created",
            options = @VertxEventOptions(worker = true))
    public String handleOrder(Message<my.app.model.OrderRequest> message) {
        return "Accepted: " + message.body().id();
    }
}
```

### `OrderService.java`

```java
package my.app.events;

import com.guicedee.vertx.VertxEventPublisher;
import io.vertx.core.Future;
import jakarta.inject.Inject;
import jakarta.inject.Named;

public class OrderService {
    @Inject
    @Named("order.created")
    private VertxEventPublisher<my.app.model.OrderRequest> publisher;

    public Future<String> placeOrder(my.app.model.OrderRequest order) {
        return publisher.request(order);
    }
}
```

