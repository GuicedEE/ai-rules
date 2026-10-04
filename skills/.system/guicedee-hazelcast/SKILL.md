---
name: guicedee-hazelcast
description: "Configure GuicedEE Hazelcast clustering, distributed data structures, Vert.x cluster managers, and JCache."
metadata:
  short-description: Annotation-driven Hazelcast clustering inside GuicedEE
---

# GuicedEE Hazelcast

Annotation-driven Hazelcast integration for GuicedEE using Vert.x 5 Hazelcast Cluster Manager.

## Core Concept

Declare intentional server or client configuration with annotations or configuration SPIs. GuicedEE discovers it through ClassGraph, prepares it before Vert.x starts, and owns its lifecycle. Adding the dependency alone starts neither a cluster member nor a client.

## Required Flow

1. Add `com.guicedee:hazelcast` dependency.
2. Define server configuration on a class or `package-info.java`:
   ```java
   @HazelcastServerOptions(
       clusterName = "my-cluster",
       startLocal = true,
       clustered = true,
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
Embedded server configuration: cluster name, instance name, port, port auto-increment, public address, interfaces, join type (MULTICAST/TCP/KUBERNETES/NONE), multicast settings, TCP members, Kubernetes DNS/namespace, lite member, startLocal, clustered, heartbeat, CP subsystem. Targets `TYPE` and `PACKAGE`.

### `@HazelcastClientOptions`
Client connection configuration: cluster name, instance name, addresses, connection timeout, heartbeat interval/timeout, invocation timeout, event threads, smart routing, reconnect mode (OFF/ON/ASYNC), backoff settings, labels. Targets `TYPE` and `PACKAGE`.

## Injectable Components

| Binding | Key | Description |
|---|---|---|
| `HazelcastInstance` | (default) | Running lifecycle-owned client, otherwise owned member; injection never creates another instance |
| `CachingProvider` | (default) | JCache caching provider singleton |
| `CacheManager` | (default) | JCache cache manager singleton |

## Static Access

| Class | Method | Description |
|---|---|---|
| `HazelcastPreStartup` | `getInstance()` | Embedded server instance (if `startLocal=true`) |
| `HazelcastPreStartup` | `getConfig()` | Prepared server `Config`; preparation itself does not join a cluster |
| `HazelcastClusterConfigurator` | `member()` | Running owned member, including a member created by the Vert.x cluster manager |
| `HazelcastClientPreStartup` | `getClientInstance()` | Client instance |
| `HazelcastClientPreStartup` | `getConfig()` | Client `ClientConfig` object |

## Vert.x Cluster Integration

`HazelcastClusterConfigurator` is discovered under `VertxConfigurator`, but its `enabled()` controls whether Vert.x requests a manager:

- Explicit `VERTX_CLUSTER_ENABLED=true` or `false` overrides activation; malformed values fail startup.
- Without that override, a server annotation uses `clustered()` (default `true`). Without an annotation, intentional `startLocal` or a server configuration SPI preserves activation. A dependency with no intentional configuration remains unclustered.
- `startLocal=true, clustered=false` supports an owned embedded cache member without clustering the Vert.x event bus. Disabling the event-bus cluster does not cancel an explicitly requested cache member.
- Reuse the prepared `Config` and any already owned member. Do not construct a default `HazelcastClusterManager()` that can select a different configuration or create an extra member.
- `HAZELCAST_CLIENT_ENABLED` independently gates client startup; absent an override, only intentional client annotations or configuration SPIs start it.

Choose the cluster name, join method, membership bind/advertised address and Vert.x event-bus bind/advertised address explicitly for the deployment. These are separate network endpoints. Unconfigured preparation disables multicast and auto-detection.

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

## Owned JCache and distributed state

All `CachingProvider.getCacheManager` overloads must resolve against the lifecycle-owned instance. Bind the annotation implementation's `DefaultCacheResolverFactory` to that same `CacheManager`; its default static provider lookup can otherwise start another Hazelcast instance. Avoid opportunistic `Caching.getCachingProvider().getCacheManager()` calls.

Keep socket objects, handlers, and node-local queues out of distributed maps. Store only bounded serializable lease metadata. Use a single atomic operation for global capacity checks and ticket redemption; separate get/check/put operations across several maps can oversubscribe or redeem twice. Backup, TTL, topology and partition behavior are application decisions. Hazelcast membership quorum is subject to failure-detection delay and does not establish instantaneous CP partition safety.

## Environment Variable Overrides

Most annotation attributes have system-property or environment overrides. Activation is special: use `VERTX_CLUSTER_ENABLED` for the server annotation's `clustered` flag and `HAZELCAST_CLIENT_ENABLED` for the independent client gate:

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

```text
IGuiceContext.instance().inject()
 ├─ MetricsPreStartup                       (MIN_VALUE + 36)
 ├─ HazelcastPreStartup                     (MIN_VALUE + 37)
 │   ├─ Discover annotation and prepare Config once; apply server SPIs
 │   └─ Start an embedded member only when startLocal requests it
 ├─ VertXPreStartup                         (MIN_VALUE + 38)
 │   └─ Compose shared options; enabled manager selects clustered build
 ├─ HazelcastClientPreStartup               (MIN_VALUE + 71)
 │   └─ Start a client only when intentionally enabled
 ├─ HazelcastBinderGuice
 │   └─ Bind owned instance, CachingProvider, CacheManager, annotation resolver
 └─ Ordered shutdown
     ├─ Vert.x close awaited                (MAX_VALUE - 200)
     └─ Owned client and member shutdown    (MAX_VALUE - 100)
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.guicedhazelcast;`.
- Packages using injection must `opens` to `com.google.guice`.
- `@HazelcastServerOptions` and `@HazelcastClientOptions` can be placed on `package-info.java` (preferred) or any class.
- SPI implementations (`IGuicedHazelcastServerConfig`, `IGuicedHazelcastClientConfig`) must be dual-registered in `module-info.java` and `META-INF/services/`.
- Only one `@HazelcastServerOptions` and one `@HazelcastClientOptions` annotation should exist per application.

