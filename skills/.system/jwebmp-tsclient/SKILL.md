---
name: jwebmp-tsclient
description: "Define JWebMP TypeScript generation, npm dependencies, Angular annotations, and typed NgRestClient services from Java."
metadata:
  short-description: TypeScript code generation utilities
---

# JWebMP TypeScript Client

TypeScript client generation for JWebMP plugins.

## Core Features

- **TypeScript Generation** — Generate .ts from Java annotations
- **NPM Dependencies** — Declare dependencies via annotations
- **Component Generation** — Auto-generate Angular components
- **Service Generation** — Auto-generate Angular services

## Annotations

### @TsDependency

Declare npm runtime dependencies:

```java
@TsDependency(value = "@angular/core", version = "^20.0.0")
@TsDependency(value = "rxjs", version = "^7.8.0")
public class MyComponent { }
```

### @TsDevDependency

Declare npm dev dependencies:

```java
@TsDevDependency(value = "@types/node", version = "^20.0.0")
@TsDevDependency(value = "typescript", version = "^5.0.0")
public class MyPlugin { }
```

### @NgComponent

Mark class for Angular component generation:

```java
@NgComponent("my-component")
public class MyComponent implements INgComponent<MyComponent> {
    @Override
    public String render() {
        return "<div>My Component</div>";
    }
}
```

### @NgDataService

Mark class for Angular service generation:

```java
@NgDataService
public class MyService implements INgDataService<MyService> {
    @Override
    public Object getData(AjaxCall<?> call, AjaxResponse<?> response) {
        return fetchData();
    }
}
```

### @NgRestClient

Generate a fully typed, signal-based `@Injectable` Angular REST service from a
single Java class — the REST equivalent of `@NgGraphQL`. One annotated class
targets **one** endpoint (one HTTP method + URL). No handwritten TypeScript.

Package: `com.jwebmp.core.base.angular.client.annotations.angular`

```java
@NgRestClient(
    url = "/api/orders",
    method = NgRestClient.HttpMethod.POST,
    responseType = OrderResult.class,
    authType = NgRestClient.AuthType.BEARER,
    retryCount = 3,
    retryBackoff = true,        // exponential backoff between retries
    retryMaxDelayMs = 10_000,   // cap the backoff delay
    timeoutMs = 8_000)          // per-attempt request timeout
@NgRestClientHeader(name = "Content-Type", value = "application/json")
@NgRestClientQueryParam(name = "tenant", value = "acme")
public class OrderClient implements INgRestClient<OrderClient> {}
```

#### Attributes

| Attribute | Default | Purpose |
|---|---|---|
| `url()` | — (required) | Endpoint URL/path (relative or absolute) |
| `method()` | `GET` | HTTP method: `GET/POST/PUT/DELETE/PATCH` |
| `value()` | `""` | Friendly service name for generated class |
| `responseType()` | `INgDataType.class` (`any`) | Typed response body class |
| `responseArray()` | `false` | Response is an array of `responseType` |
| `singleton()` | `true` | `providedIn: 'root'` vs `'any'` |
| `fetchOnCreate()` | `false` | Auto-fire request on injection |
| `pollingEnabled()` | `false` | Re-fetch at a fixed interval |
| `pollingIntervalMs()` | `30000` | Polling interval |
| `cachingEnabled()` | `false` | Cache last successful response |
| `cacheTtlMs()` | `60000` | Cache TTL |
| `deduplication()` | `true` | Share in-flight requests |
| `deepMerge()` | `false` | Deep-merge responses into the signal |
| `retryCount()` | `0` | Retry attempts on failure |
| `retryDelayMs()` | `1000` | Delay between retries (base delay when backoff is on) |
| `retryBackoff()` | `false` | Exponential backoff: delay = `retryDelayMs * 2^(n-1)` |
| `retryMaxDelayMs()` | `0` | Cap for the backoff delay (`0` = no cap) |
| `timeoutMs()` | `0` | Per-attempt request timeout (`0` = disabled) |
| `authType()` | `NONE` | `NONE/BEARER/BASIC/CUSTOM` |
| `authTokenField()` | `localStorage.getItem('token')` | TS expression resolving the token |
| `authHeaderName()` | `Authorization` | Header name for `CUSTOM` auth |

> **Resilience pipeline order:** `timeout` is applied **before** `retry`, so each attempt
> is independently time-bounded and a timed-out attempt participates in the retry budget.
> With `retryBackoff = true` the delay grows exponentially per attempt
> (`retryDelayMs * 2^(retryCount-1)`), optionally capped by `retryMaxDelayMs`; otherwise a
> fixed `retryDelayMs` is used.

#### Companion annotations

Both are `@Repeatable` (container forms `@NgRestClientHeaders` / `@NgRestClientQueryParams`):

```java
@NgRestClientHeader(name = "Accept", value = "application/json")    // static header
@NgRestClientQueryParam(name = "format", value = "json")           // static query param
```

#### Generated TypeScript service

The `INgRestClient<J>` interface drives generation of an `@Injectable` that uses
Angular `HttpClient` and exposes reactive `signal()` state:

- Signals: `data`, `loading`, `error`, `success`, `polling`
- `execute(params?, extraHeaders?)` and — for POST/PUT/PATCH — `executeWithBody(body, params?, extraHeaders?)`
- `buildHttpRequest$()` / `buildHeaders()` (static + runtime headers, default + runtime query params, auth injection)
- `timeout` (per-attempt) and `retry` (fixed delay or exponential backoff via a `timer`-based delay function) wired into `buildHttpRequest$()`
- `handleResponse()` with optional deep-merge (id-keyed array merging)
- `startPolling()` / `stopPolling()`, `isCacheValid()` / `invalidateCache()`
- `reset()` and `ngOnDestroy()` cleanup via `DestroyRef` + `destroy$`
- Automatic Angular/RxJS imports and response-type import wiring

## Interfaces

### INgComponent

```java
public interface INgComponent<J extends INgComponent<J>> {
    String render();
    default void configure(IComponentHierarchyBase<?, ?> component) { }
}
```

### INgDataService

```java
public interface INgDataService<J extends INgDataService<J>> {
    Object getData(AjaxCall<?> call, AjaxResponse<?> response);
    default void receiveData(AjaxCall<?> call, AjaxResponse<?> response) { }
}
```

### INgDirective

```java
public interface INgDirective<J extends INgDirective<J>> {
    String getSelector();
    Map<String, String> getInputs();
    Map<String, String> getOutputs();
}
```

### INgRestClient

Drives `@NgRestClient` codegen — extends `IComponent<J>` and renders the typed
Angular REST service (signals, HTTP methods, polling, caching, retry/backoff, timeout, auth).

```java
public interface INgRestClient<J extends INgRestClient<J>> extends IComponent<J> {
    default NgRestClient getAnnotation() {
        return getClass().getAnnotation(NgRestClient.class);
    }
    // fields(), constructorBody(), methods() emit the @Injectable service
}
```

## TypeScript Generation

Plugin automatically generates:
- Component .ts files
- Service .ts files
- Module declarations
- package.json dependencies
- tsconfig.json

## JPMS Module

```java
module com.jwebmp.core.base.angular.client {
    requires transitive com.jwebmp.client;

    exports com.jwebmp.core.base.angular.client;
    exports com.jwebmp.core.base.angular.client.annotations;
    exports com.jwebmp.core.base.angular.client.services;
}
```

## Installation

```xml
<dependency>
  <groupId>com.jwebmp.plugins</groupId>
  <artifactId>tsclient</artifactId>
</dependency>
```

## References

- Module: `com.jwebmp.core.base.angular.client`
- Java: 25+
- TypeScript: 5.x
- License: Apache 2.0
