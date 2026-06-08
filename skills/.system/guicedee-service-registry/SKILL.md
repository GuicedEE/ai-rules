---
name: guicedee-service-registry
description: "Named service registry with health-aware resolution for GuicedEE. Register services by simple name, auto-construct URLs from cloud DNS suffix, monitor health status, resolve services via registry:name prefix or bare name in rest-client @Endpoint. Supports aliases, multiple external URLs, Kubernetes internal URLs, and per-service health paths. Use when registering named services, checking service health, resolving service URLs by name, or integrating with rest-client for service-to-service calls."
metadata:
  short-description: Named service registry with health-aware resolution
---

# GuicedEE Service Registry

Named service registry with health monitoring — register, discover, and resolve services by simple name.

## Core Concept

The service registry maintains a map of `name → URL + health status`. Services are registered via annotations, auto-constructed from cloud DNS suffix, or provided by SPI plugins. Periodic health checks keep status current. The rest-client module can resolve `registry:service-name` URLs or bare service names at call time.

## Required Flow

1. Add `com.guicedee:service-registry` dependency.
2. Add `requires com.guicedee.service.registry;` to `module-info.java`.
3. Declare services on `package-info.java`:
   ```java
   @ServiceRegistryOptions(healthCheckInterval = 30)
   @RegisteredService(name = "jwebmp-website",
       aliases = {"jwebmp", "jwebswing"},
       externalUrls = {"https://jwebmp.com", "https://jwebswing.com"},
       kubernetesUrl = "http://jwebmp-website.default.svc.cluster.local")
   @RegisteredService(name = "payment-api", url = "${PAYMENT_URL}", healthPath = "/status")
   @RegisteredService(name = "hello-service",
       url = "http://hello-service.myns.svc.cluster.local",
       healthPath = "/healthz")
   package com.myapp;
   ```
4. Use services by name:
   ```java
   String url = ServiceRegistry.url("jwebmp-website");
   String url = ServiceRegistry.url("jwebmp"); // alias resolution
   String ext = ServiceRegistry.externalUrl("jwebmp-website"); // → https://jwebmp.com
   List<String> exts = ServiceRegistry.externalUrls("jwebmp-website");
   String k8s = ServiceRegistry.kubernetesUrl("jwebmp-website");
   Optional<String> healthy = ServiceRegistry.healthyUrl("jwebmp-website");
   ```

## JPMS Module Name

`com.guicedee.service.registry`

## Lifecycle Hooks

| Hook | Sort Order | What It Does |
|---|---|---|
| `ServiceRegistryPreStartup` | `MIN+150` | Scans annotations, constructs URLs, self-registers, runs SPI providers |
| `ServiceRegistryPostStartup` | `MIN+700` | Starts Vert.x periodic health check timer |

## Key Classes

| Class | Package | Role |
|---|---|---|
| `ServiceRegistry` | `com.guicedee.service.registry` | Central static registry — `get()`, `url()`, `externalUrl()`, `externalUrls()`, `kubernetesUrl()`, `healthyUrl()`, `resolve()`, `register()`, `registerAlias()` |
| `ServiceEntry` | `com.guicedee.service.registry` | Record: name, url, externalUrls, kubernetesUrl, healthPath, status, lastChecked, metadata |
| `ServiceStatus` | `com.guicedee.service.registry` | Enum: UP, DOWN, UNKNOWN, DEGRADED |
| `ServiceRegistryOptions` | `com.guicedee.service.registry` | Annotation: healthCheckInterval, healthPath, registerSelf, useHttps, defaultPort |
| `RegisteredService` | `com.guicedee.service.registry` | Annotation: declares a known service (repeatable) — name, url, healthPath, aliases, externalUrls, externalUrl, kubernetesUrl |
| `IServiceRegistryProvider` | `com.guicedee.service.registry` | SPI for external catalogs (Azure API, Consul, static config) |

## URL Resolution Order

1. If `@RegisteredService(url = "...")` is provided → use it (supports `${ENV_VAR}` placeholders)
2. If url is empty, auto-construct from DNS suffix:
   - Check `CONTAINER_APP_ENV_DNS_SUFFIX` env var (Azure Container Apps)
   - Check `runtime-autoconfigure` extras.dnsSuffix (if on classpath)
   - Check `SERVICE_REGISTRY_DNS_SUFFIX` env var (manual fallback)
   - URL = `https://{name}.{dnsSuffix}`
3. If no DNS suffix available → warning logged, service skipped

## Aliases & External URLs

- `aliases = {"jwebmp", "jwebswing"}` — all resolve to the same service entry
- `externalUrls = {"https://jwebmp.com", "https://jwebswing.com"}` — public custom domains
- `externalUrl = "https://guicedee.com"` — single external URL shorthand
- `kubernetesUrl = "http://svc.ns.svc.cluster.local"` — K8s internal cluster URL
- `ServiceRegistry.externalUrl("name")` returns first external URL or falls back to internal
- `ServiceRegistry.kubernetesUrl("name")` returns K8s URL or falls back to internal

## Per-Service Health Paths

Each `@RegisteredService` can specify its own `healthPath`:
```java
@RegisteredService(name = "legacy-app", healthPath = "/status")
@RegisteredService(name = "k8s-service", healthPath = "/healthz")
@RegisteredService(name = "standard-service")  // uses registry default "/health/ready"
```

`ServiceEntry.healthUrl()` concatenates `url + healthPath` to get the full health check URL.

## Self-Registration

When `registerSelf = true` (default) and `runtime-autoconfigure` is on classpath:
- Uses `RuntimeAutoConfigurePreStartup.current()` to get serviceName, hostname, port
- Registers self with status UP and metadata `{self: "true"}`
- Self entries are skipped during health checks

## Automatic Discovery (preferred — do not hand-roll)

GuicedEE discovers peers **automatically**; do **not** maintain a hand-written peer
list or build a custom `IServiceRegistryProvider` just to enumerate known services.
Three built-in mechanisms cooperate:

1. **Self-registration** (`registerSelf = true` + `runtime-autoconfigure`) — every
   service advertises its own identity/host/port at startup. No peer declares another.
2. **DNS-suffix URL construction** — when a name has no explicit URL, the registry
   builds `https://{name}.{dnsSuffix}` from the first available of
   `CONTAINER_APP_ENV_DNS_SUFFIX` (Azure Container Apps), `runtime-autoconfigure`
   `dnsSuffix`, or `SERVICE_REGISTRY_DNS_SUFFIX` (manual fallback).
3. **`service-discovery` module** (`com.guicedee.vertx.servicediscovery`) — a Vert.x
   service resolver (Kubernetes / SRV aware) that resolves service names to live
   addresses at call time. Add the dependency + `requires
   com.guicedee.vertx.servicediscovery`; it self-activates via lifecycle SPIs (no
   wiring). This is the "automatic discovery" backbone for clustered/K8s deployments.

```java
// Idiomatic: declare ONLY options; rely on self-registration + discovery for peers.
@ServiceRegistryOptions(healthCheckInterval = 30, registerSelf = true, useHttps = true)
package com.myapp;
```

> **When to still use `@RegisteredService`.** Only for genuinely *external* / third-party
> endpoints that cannot self-register (a legacy API, a public site). Never to list your
> own platform's GuicedEE services — those self-register and are discovered.

> **Local-dev caveat.** With no cloud platform and no DNS suffix, `runtime-autoconfigure`
> cannot resolve a public URL, so the self entry may carry an empty URL and a periodic
> health check can show it `DOWN`. This is expected for plain local runs — real discovery
> happens in the target environment. Set `SERVICE_REGISTRY_DNS_SUFFIX` locally if you want
> name → URL construction, or run the cluster (K8s/compose) where the resolver applies.

## Health Checks

- Periodic HTTP GET to `{url}{healthPath}` using Vert.x WebClient
- 2xx/3xx → UP, 503 → DEGRADED, other → DOWN, connection failure → DOWN
- Configurable interval (default 30s) and timeout (default 5000ms)
- `trustAll = true` by default (for dev clusters)

## Integration with rest-client

The rest-client auto-resolves from service registry (no hard dependency):

```java
// Explicit registry: prefix
@Endpoint(url = "registry:jwebmp-website")
@Named("jwebmp") private RestClient<Void, Response> client;

// Bare service name (auto-detected if registered)
@Endpoint(url = "jwebmp-website")
@Named("jwebmp") private RestClient<Void, Response> client;

// Full URL (passes through unchanged)
@Endpoint(url = "https://api.example.com/v1")
@Named("example") private RestClient<Void, Response> client;
```

## Optional Dependencies

| Module | Maven artifact / module name | What It Adds |
|---|---|---|
| `runtime-autoconfigure` | `com.guicedee:runtime-autoconfigure` (`com.guicedee.runtime.autoconfigure`) | Self-registration + DNS suffix auto-detection across cloud platforms (AWS, Azure, GCP, K8s, Fly.io, Render, …) |
| `service-discovery` | `com.guicedee:service-discovery` (`com.guicedee.vertx.servicediscovery`) | **Automatic** Vert.x service resolution (Kubernetes / SRV aware) via the `IServiceResolverProvider` SPI; self-activates through lifecycle hooks |

## @ServiceRegistryOptions Attributes

| Property | Default | Purpose |
|---|---|---|
| `healthCheckInterval` | `30` | Seconds between checks (0 = disabled) |
| `healthPath` | `"/health/ready"` | Default health endpoint path |
| `registerSelf` | `true` | Auto-register using runtime-autoconfigure |
| `healthCheckTimeout` | `5000` | HTTP timeout in ms |
| `useHttps` | `true` | HTTPS for auto-constructed URLs |
| `defaultPort` | `0` | Port for auto-constructed URLs (0 = omit) |

## @RegisteredService Attributes

| Property | Default | Purpose |
|---|---|---|
| `name` | (required) | Simple logical service name |
| `url` | `""` | Full URL (empty = auto-construct from DNS suffix). Supports `${ENV_VAR}` |
| `healthPath` | `""` | Health path override (empty = use registry default) |
| `aliases` | `{}` | Alternative names that resolve to this service |
| `externalUrls` | `{}` | External/public URLs (custom domains). Supports `${ENV_VAR}` |
| `externalUrl` | `""` | Single external URL shorthand. Supports `${ENV_VAR}` |
| `kubernetesUrl` | `""` | Kubernetes internal cluster URL. Supports `${ENV_VAR}` |

## IServiceRegistryProvider SPI

```java
public class AzureCatalogProvider implements IServiceRegistryProvider<AzureCatalogProvider> {
    @Override
    public List<ServiceEntry> discover() {
        // Call Azure API, return container apps in environment
    }
    @Override
    public String providerId() { return "azure-catalog"; }
}
```

Register in `module-info.java`:
```java
provides IServiceRegistryProvider with AzureCatalogProvider;
```

> **Don't reach for this SPI to list your own services.** It exists to bridge a *real
> external catalog* (Azure Resource Graph, Consul, a CMDB). Implementing one that just
> reads a static/env-driven peer list (e.g. `NE1_REGISTRY_PEERS=name=url;…`) is an
> anti-pattern — it re-invents what self-registration + the `service-discovery` resolver +
> DNS-suffix construction already do automatically. Prefer those (see *Automatic
> Discovery*); use a custom provider only when integrating an authoritative external
> registry.

## Non-Negotiable Constraints

- Module name: `com.guicedee.service.registry`
- `IGuicePreStartup.onStartup()` returns `List<Future<Boolean>>` (Vert.x Future)
- `IGuicePostStartup.postLoad()` returns `List<Uni<Boolean>>` (Mutiny Uni)
- Vert.x WebClient module name is `io.vertx.web.client`
- Vert.x Web module name is `io.vertx.web`
- Sort order must be after `RuntimeAutoConfigurePreStartup` (MIN+50) and after `VertXPreStartup`
- All services stored lowercase/trimmed
- `resolveEnvPlaceholders` is public for cross-package access

