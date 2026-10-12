---
name: guicedee-telemetry
description: "Instrument GuicedEE with OpenTelemetry spans, W3C context propagation, call scopes, Uni/Future lifecycles, HTTP boundaries, and OTLP export."
metadata:
  short-description: OpenTelemetry distributed tracing inside GuicedEE
---

# GuicedEE Telemetry

GuicedEE telemetry has two complementary APIs:

- `@Trace` and `@SpanAttribute` provide Guice AOP method tracing.
- `GuicedTelemetry` provides the explicit boundary API used by infrastructure modules and clients.

Use the explicit API whenever a trace crosses an asynchronous, network, messaging, discovery, or persistence boundary. A method interceptor alone cannot inject headers into an HTTP request or extract a remote parent from an incoming request.

## Consumer setup

Add the dependency and JPMS requirement:

```xml
<dependency>
  <groupId>com.guicedee</groupId>
  <artifactId>guiced-telemetry</artifactId>
</dependency>
```

```java
requires com.guicedee.telemetry;
```

The telemetry module registers its startup and Guice AOP services through `ServiceLoader`; consumers do not add a second `provides` entry. Traced application packages must be opened to `com.google.guice`.

## Configuration

```java
@TelemetryOptions(
    serviceName = "orders",
    serviceVersion = "1.0.0",
    deploymentEnvironment = "production",
    otlpEndpoint = "http://localhost:4318",
    exportLogs = false
)
public class OrdersTelemetryConfig {}
```

`otlpEndpoint` is a base endpoint. The configurator adds `/v1/traces` and `/v1/logs` when needed. Use `tracesEndpoint` and `logsEndpoint` for separate signal destinations. Tempo and Jaeger are normally trace-only, so set `exportLogs = false` unless logs are sent to an OTLP logs-capable collector. System properties and standard `OTEL_EXPORTER_OTLP_*` environment variables override annotation values.

## Explicit boundary API

`GuicedTelemetry` exposes `openTelemetry()`, `tracer(String)`, `currentSpan()`, `startSpan(String)`, `startClientSpan(String,String)`, `startServerSpan(String,String,MultiMap)`, `makeCurrent(Span)`, `inject(MultiMap)`, `inject(Map<String,String>)`, `extract(MultiMap)`, and `end(Span,Throwable)`. Both `withSpan` and `finish` accept Mutiny `Uni<T>` and Vert.x `Future<T>`.

For a custom HTTP client, create a `CLIENT` span per subscription, make it current while constructing the request, inject W3C headers, and close it from the asynchronous result. GuicedEE `RestClient` already does this; do not wrap it with another boundary span:

```java
return Uni.createFrom().deferred(() -> {
    Span span = GuicedTelemetry.startClientSpan("GET", url);
    try (Scope ignored = GuicedTelemetry.makeCurrent(span)) {
        GuicedTelemetry.inject(request.headers());
        return GuicedTelemetry.finish(span, sendRequest());
    } catch (RuntimeException | Error failure) {
        GuicedTelemetry.end(span, failure);
        throw failure;
    }
});
```

For a custom HTTP ingress with no existing server-span owner, extract the incoming parent and create a `SERVER` span. This example owns the resource operation's completion; a listener tracing the whole HTTP exchange should instead own completion at response end/close:

```java
Span span = GuicedTelemetry.startServerSpan(
    context.request().method().name(), route, context.request().headers());
try (Scope ignored = GuicedTelemetry.makeCurrent(span)) {
    return GuicedTelemetry.finish(span, invokeResource()); // invokeResource returns Uni<T>
} catch (RuntimeException | Error failure) {
    GuicedTelemetry.end(span, failure);
    throw failure;
}
```

`inject(MultiMap)` and `extract(MultiMap)` use the configured OpenTelemetry propagator. Do not copy trace IDs into application payloads, query parameters, cookies, or authentication claims. Use W3C `traceparent`/`tracestate` headers through the propagation API.

`finish(Span, Uni<T>)` owns completion for the returned `Uni`: it records failures and ends the span when the operation completes. Do not also end that span in the caller.

Use `withSpan(Span, Uni<T>)` when another component owns completion, such as a REST server response handler. It keeps the span current for the full reactive subscription so downstream REST clients create child spans. The response owner must end the server span exactly once.

## Existing automatic boundaries

- `rest-client`: every outbound request creates a `CLIENT` span, records method, URL, and response status, injects the current context, and closes the span with the returned `Uni`.
- `rest`: `OperationRegistry` creates the inbound `SERVER` span, makes it current through resource invocation, and owns completion at response end. Do not add a duplicate server span in the resource.

Raw Vert.x routes and isolated listeners do not acquire this REST behavior simply by depending on `web`. Inspect the owning listener before adding a span. If it already owns the `SERVER` span, route-level work should use an `INTERNAL` child.

For the Vert.x OpenTelemetry tracer, the NE1 Profile integration explicitly uses `builder.withTracer(new OpenTelemetryTracingFactory())` in a dual-registered `VertxConfigurator`. A discovered factory alone does not activate that path with the default tracing options. Keep the builder hook additive; `builder.with(new VertxOptions())` would discard prepared options. The tracer can own HTTP server/client spans, so check overlap with REST/RestClient instrumentation before combining them. In Profile, raw routes contribute internal children while the tracer owns the server span.

## Guidance for additional integrations

The following are integration patterns, not claims that every module is already instrumented:

- `service-registry` and `service-discovery`: wrap registry resolution, health checks, and remote discovery calls in `INTERNAL` or `CLIENT` spans. Record the logical service name and resolved target; do not record credentials or tokens.
- `persistence`: wrap session acquisition, transaction, query, and flush boundaries in `INTERNAL` spans. Record persistence unit, operation, and bounded query identity. Never record SQL parameters or entity payloads by default.
- messaging and websocket modules: extract context at ingress, make the consumer span current while dispatching, and inject context for outbound messages.

Boundary modules may use the facade directly. They must preserve the existing GuicedEE module graph and keep telemetry optional unless the module intentionally adopts a compile-time telemetry dependency. If optional integration is required, use a small SPI and `ServiceLoader` rather than reflection that hides module requirements.

## AOP tracing

```java
@Trace("orders.place")
public Uni<Order> place(@SpanAttribute("order.id") String orderId) { ... }
```

`@Trace` creates an `INTERNAL` span. Class-level `@Trace` traces eligible methods. Parameters and return values annotated with `@SpanAttribute` are recorded; complex values are serialized for diagnostics. AOP requires non-final, non-private methods and packages opened to Guice.

Nested AOP spans inherit the current OpenTelemetry context. The interceptor handles synchronous methods, `Uni`, and Vert.x `Future`, keeping asynchronous spans open until completion or failure and restoring the parent call-scope span afterward. Preserve that parent rather than clearing the trace binding during nested cleanup. GuicedEE `CallScoper` and its Mutiny integrations preserve scope state across Vert.x and `Uni` continuations; boundary code must still make the span current around the operation that creates asynchronous work.

## Testing contract

Use `@TelemetryOptions(useInMemoryExporters = true)` for tests. Assert span name and kind, parent/child relationship, propagated `traceparent`, semantic attributes, completion on success/failure/asynchronous completion, and absence of credentials, cookies, SQL values, and unrestricted payloads.

Run focused module tests from the module directory. Do not use Maven `clean` as part of telemetry validation, and inspect Surefire reports when a module configures failure ignoring.

## Non-negotiable rules

- Keep one owner for every span's lifecycle.
- Use standard OpenTelemetry context propagation at every process boundary.
- Treat `CallScoper` as JVM-local scope support; it is not distributed propagation by itself.
- Use stable semantic attributes and bounded cardinality.
- Do not record authorization credentials, cookies, request bodies, SQL values, or unrestricted exception payloads.
- Preserve JPMS exports, opens, service descriptors, and the existing GuicedEE dependency direction.
