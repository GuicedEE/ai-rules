---
name: guicedee-service-registry
description: "Register GuicedEE services by name, resolve their URLs and aliases, and configure health-aware service discovery."
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

`ServiceEntry.healthUrl()` uses explicit `healthUrl` metadata when present; otherwise it normalizes the service URL and health path.

## Self-Registration

When `registerSelf = true` (default) and `runtime-autoconfigure` is on classpath:
- Uses `RuntimeAutoConfigurePreStartup.current()` to get serviceName, hostname, port
- Registers self with status UP and metadata `{self: "true"}`
- Self entries are skipped during health checks

## Discovery and instance ownership

The registry is JVM-local state. Self-registration adds this process to its own registry; it does not publish a network catalogue or enumerate peers. DNS-suffix construction forms a URL for an already known name. Declare known peers with `@RegisteredService`, or use `IServiceRegistryProvider` to read the deployment's authoritative catalogue.

The separate `service-discovery` module resolves configured services through `@ServiceResolverOptions` or its provider SPI. Adding the dependency activates lifecycle discovery of that configuration; it does not supply the names, network configuration, or an automatically replicated registry. Check resolver configuration before assuming another process is discoverable.

Use `registerInstance`, `unregisterInstance`, and `updateInstanceStatus` for revision-specific entries. `healthyInstances` and `latestHealthyInstance` expose candidates; `ServiceEntry.isHealthy()` includes both `UP` and `DEGRADED`. Choose an explicit policy when a caller requires strictly `UP`. Registration and service health do not establish application identity, user consent, or authorization.

## Health Checks

- Periodic HTTP GET to `ServiceEntry.healthUrl()`; self entries are skipped.
- Interval defaults to 30 seconds and timeout to 5000 ms. Repeated failures back off up to 32 intervals.
- TLS verification is enabled (`trustAll=false`, `verifyHost=true`); redirects are disabled.
- Evaluation uses the expected status/content type and, for JSON health responses, MicroProfile health status/checks. Inspect `ServiceRegistryPostStartup` when diagnosing unexpected `UNKNOWN`/`DEGRADED` results rather than equating all successful HTTP responses with readiness.
- `@RegisteredService(healthUrl="...")` supports a separate health listener. It must be an absolute HTTP(S) URL with a host, valid port, and no credentials, query, or fragment. The public service URL remains the request destination.
- The optional downstream readiness integration is controlled by `HEALTH_DOWNSTREAM_ENABLED`. An absent registry or empty catalogue is reported as up; it does not prove that required peers exist or that cluster quorum is ready.

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
| `service-discovery` | `com.guicedee:service-discovery` (`com.guicedee.vertx.servicediscovery`) | Configured Vert.x service resolution via `@ServiceResolverOptions` / `IServiceResolverProvider`; configuration is loaded through lifecycle hooks |

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
| `healthUrl` | `""` | Explicit absolute health listener URL |
| `expectedStatusCode` | `200` | Expected health response status |
| `expectedContentType` | `"application/json"` | Health response evaluation mode |
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

Also register the provider in `META-INF/services/com.guicedee.service.registry.IServiceRegistryProvider` for classpath launches. Keep one owner for the peer catalogue and avoid duplicating discovery mechanisms with conflicting entries.

## Non-Negotiable Constraints

- Module name: `com.guicedee.service.registry`
- `IGuicePreStartup.onStartup()` returns `List<Future<Boolean>>` (Vert.x Future)
- `IGuicePostStartup.postLoad()` returns `List<Uni<Boolean>>` (Mutiny Uni)
- Vert.x WebClient module name is `io.vertx.web.client`
- Vert.x Web module name is `io.vertx.web`
- Sort order must be after `RuntimeAutoConfigurePreStartup` (MIN+50) and after `VertXPreStartup`
- All services stored lowercase/trimmed
- `resolveEnvPlaceholders` is public for cross-package access

