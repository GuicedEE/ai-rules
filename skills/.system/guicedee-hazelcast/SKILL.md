---
name: guicedee-hazelcast
description: "Annotation-driven Hazelcast integration for GuicedEE with Vert.x 5: @HazelcastServerOptions for embedded server configuration, @HazelcastClientOptions for client connections, automatic Vert.x cluster manager via HazelcastClusterConfigurator SPI, JCache (JSR-107) annotations (@CacheResult, @CachePut, @CacheRemove), IGuicedHazelcastServerConfig/IGuicedHazelcastClientConfig SPI hooks, distributed maps/queues/locks, multiple join strategies (Multicast, TCP, Kubernetes, None), environment variable overrides (HAZELCAST_*/HAZELCAST_CLIENT_*), and graceful shutdown. Use when adding Hazelcast clustering, configuring Vert.x clustered event-bus, using distributed data structures, or enabling JCache."
metadata:
  short-description: Annotation-driven Hazelcast clustering inside GuicedEE
---

# GuicedEE Hazelcast

Annotation-driven Hazelcast integration for GuicedEE using Vert.x 5 Hazelcast Cluster Manager.

## Core Concept

Declare server and client configuration with annotations — everything is discovered at startup via ClassGraph, wired through Guice, and automatically configures the Vert.x Hazelcast cluster manager for clustered event-bus and distributed data structures.

## Required Flow

1. Add `com.guicedee:hazelcast` dependency.
2. Define server configuration on a class or `package-info.java`:
   ```java
   @HazelcastServerOptions(
       clusterName = "my-cluster",
       startLocal = true,
       joinType = HazelcastServerOptions.JoinType.NONE
   )
   package com.example.cluster;
   ```
   Or for client mode:
   ```java
   @HazelcastClientOptions(
       clusterName = "my-cluster",
       addresses = "192.168.1.10:5701,192.168.1.11:5701"
   )
   package com.example.client;
   ```
3. Use distributed data structures:
   ```java
   public class MyService {
       @Inject
       private HazelcastInstance hz;

       public void doWork() {
           IMap<String, String> map = hz.getMap("my-map");
           map.put("key", "value");
       }
   }
   ```
4. Or access via static helpers:
   ```java
   HazelcastInstance hz = HazelcastPreStartup.getInstance();      // server
   HazelcastInstance hz = HazelcastClientPreStartup.getClientInstance(); // client
   ```
5. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.guicedinjection;
       requires com.guicedee.guicedhazelcast;
       exports my.app;
       opens my.app to com.google.guice;
   }
   ```

## Annotations

### `@HazelcastServerOptions`
Embedded server configuration: cluster name, instance name, port, port auto-increment, public address, interfaces, join type (MULTICAST/TCP/KUBERNETES/NONE), multicast settings, TCP members, Kubernetes DNS/namespace, lite member, startLocal, heartbeat, CP subsystem. Targets `TYPE` and `PACKAGE`.

### `@HazelcastClientOptions`
Client connection configuration: cluster name, instance name, addresses, connection timeout, heartbeat interval/timeout, invocation timeout, event threads, smart routing, reconnect mode (OFF/ON/ASYNC), backoff settings, labels. Targets `TYPE` and `PACKAGE`.

## Injectable Components

| Binding | Key | Description |
|---|---|---|
| `HazelcastInstance` | (default) | Client instance singleton (via `HazelcastClientProvider`) |
| `CachingProvider` | (default) | JCache caching provider singleton |
| `CacheManager` | (default) | JCache cache manager singleton |

## Static Access

| Class | Method | Description |
|---|---|---|
| `HazelcastPreStartup` | `getInstance()` | Embedded server instance (if `startLocal=true`) |
| `HazelcastPreStartup` | `getConfig()` | Server `Config` object |
| `HazelcastClientPreStartup` | `getClientInstance()` | Client instance |
| `HazelcastClientPreStartup` | `getConfig()` | Client `ClientConfig` object |

## Vert.x Cluster Integration

When the `com.guicedee.guicedhazelcast` module is on the module path, `HazelcastClusterConfigurator` is automatically discovered via `ServiceLoader<VertxConfigurator>`. It:
- Uses the existing Hazelcast instance if `startLocal=true`
- Falls back to creating a `HazelcastClusterManager` from the server config
- Triggers `VertXPreStartup` to use `buildClustered()` instead of `build()` for the Vert.x instance

This enables clustered event-bus, distributed maps, locks, and counters across Vert.x nodes automatically.

## SPI Extension Points

### `IGuicedHazelcastServerConfig`
Programmatic customization of Hazelcast server `Config`:
```java
public class MyServerConfig implements IGuicedHazelcastServerConfig<MyServerConfig> {
    @Override
    public Config buildConfig(Config config) {
        config.getMapConfig("my-map").setTimeToLiveSeconds(300);
        return config;
    }
}
```
Register: `provides IGuicedHazelcastServerConfig with MyServerConfig;`

### `IGuicedHazelcastClientConfig`
Programmatic customization of Hazelcast client `ClientConfig`:
```java
public class MyClientConfig implements IGuicedHazelcastClientConfig<MyClientConfig> {
    @Override
    public ClientConfig buildConfig(ClientConfig config) {
        config.getNetworkConfig().setRedoOperation(true);
        return config;
    }
}
```
Register: `provides IGuicedHazelcastClientConfig with MyClientConfig;`

## JCache Annotations

JCache annotations are wired via `CacheAnnotationsModule`:
```java
@CacheResult(cacheName = "users")
public User findUser(String userId) { /* ... */ }

@CachePut(cacheName = "users")
public void updateUser(String userId, @CacheValue User user) { /* ... */ }

@CacheRemoveEntry(cacheName = "users")
public void evictUser(String userId) { /* ... */ }
```

## Environment Variable Overrides

Every annotation attribute can be overridden via system properties or environment variables:

### Server: `HAZELCAST_{PROPERTY}`
- `HAZELCAST_CLUSTER_NAME`, `HAZELCAST_INSTANCE_NAME`
- `HAZELCAST_PORT`, `HAZELCAST_PUBLIC_ADDRESS`
- `HAZELCAST_JOIN_TYPE`, `HAZELCAST_TCP_MEMBERS`
- `HAZELCAST_START_LOCAL`, `HAZELCAST_LITE_MEMBER`

### Client: `HAZELCAST_CLIENT_{PROPERTY}`
- `HAZELCAST_CLIENT_CLUSTER_NAME`, `HAZELCAST_CLIENT_ADDRESSES`
- `HAZELCAST_CLIENT_CONNECTION_TIMEOUT_MS`, `HAZELCAST_CLIENT_SMART_ROUTING`
- `HAZELCAST_CLIENT_RECONNECT_MODE`

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ HazelcastPreStartup (server annotation scanning, sort=MIN+70)
     ├─ Discovers @HazelcastServerOptions (classes and package-info.java)
     ├─ Wraps with environment variable resolution (HAZELCAST_*)
     ├─ Applies SPI hooks (IGuicedHazelcastServerConfig)
     └─ Starts embedded instance if startLocal=true
 └─ HazelcastClientPreStartup (client annotation scanning, sort=MIN+71)
     ├─ Discovers @HazelcastClientOptions
     ├─ Wraps with environment variable resolution (HAZELCAST_CLIENT_*)
     ├─ Applies SPI hooks (IGuicedHazelcastClientConfig)
     └─ Connects to remote cluster
 └─ HazelcastClusterConfigurator (VertxConfigurator SPI)
     └─ Configures Vert.x to use HazelcastClusterManager (triggers buildClustered())
 └─ HazelcastBinderGuice (Guice bindings)
     ├─ Binds HazelcastInstance singleton
     ├─ Binds CachingProvider and CacheManager (JCache)
     └─ Installs CacheAnnotationsModule
 └─ HazelcastPreDestroy (shutdown, sort=MAX-100)
     ├─ Shuts down client instance
     └─ Shuts down server instance
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.guicedhazelcast;`.
- Packages using injection must `opens` to `com.google.guice`.
- `@HazelcastServerOptions` and `@HazelcastClientOptions` can be placed on `package-info.java` (preferred) or any class.
- SPI implementations (`IGuicedHazelcastServerConfig`, `IGuicedHazelcastClientConfig`) must be registered in `module-info.java`.
- Only one `@HazelcastServerOptions` and one `@HazelcastClientOptions` annotation should exist per application.

