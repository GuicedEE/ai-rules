---
name: guicedee-telemetry
description: "OpenTelemetry distributed tracing for GuicedEE using Guice AOP and OTLP exporters: @Trace and @SpanAttribute annotations, automatic span creation, Uni-aware span lifecycle, call-scope span propagation, @TelemetryOptions configuration, OTLP HTTP export to Tempo/Jaeger, in-memory exporters for testing, Log4j2 OpenTelemetry appender, and environment variable overrides. Use when adding distributed tracing, configuring OpenTelemetry, or instrumenting methods with spans."
metadata:
  short-description: OpenTelemetry distributed tracing inside GuicedEE
---

# GuicedEE Telemetry

OpenTelemetry distributed tracing for GuicedEE using Guice AOP and OTLP exporters.

## Core Concept

Annotate your classes and methods with `@Trace` and `@SpanAttribute` — the framework builds an `OpenTelemetrySdk` at startup, binds a `TraceMethodInterceptor` via Guice AOP, and exports spans and logs to any OTLP-compatible backend (Tempo, Jaeger, etc.) automatically.

## Required Flow

1. Add `com.guicedee:guiced-telemetry` dependency.
2. Configure telemetry:
   ```java
   @TelemetryOptions(
       serviceName = "my-service",
       otlpEndpoint = "http://localhost:4318",
       serviceVersion = "1.0.0",
       deploymentEnvironment = "production"
   )
   public class MyAppConfig {}
   ```
3. Annotate methods to trace:
   ```java
   @Trace("place-order")
   public void placeOrder(@SpanAttribute("order.id") String orderId,
                          @SpanAttribute("order.amount") double amount) {
       // span is created automatically
   }

   @Trace
   @SpanAttribute("result")
   public String processPayment(String paymentId) {
       return "success"; // return value recorded as "result" attribute
   }
   ```
4. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.telemetry;
       opens my.app.services to com.google.guice;
   }
   ```
5. Bootstrap GuicedEE — tracing starts automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   ```

## Tracing Annotations

### `@Trace`
Creates an OpenTelemetry span around a method invocation.
- Custom name: `@Trace("fetch-users")`
- Default name: `ClassName.methodName`
- Class-level: traces all methods in the class

### `@SpanAttribute`
Records method parameters or return values as span attributes.
- Supported types: `String`, `Boolean`, `Long`, `Double`, `Integer`, `Float`
- Complex objects serialized to JSON via Jackson

### Uni support
When a `@Trace` method returns a Mutiny `Uni`, the span remains open until the `Uni` completes or fails.

### Span propagation
Parent spans are propagated through GuicedEE's `CallScoper`. Nested `@Trace` methods create child spans automatically.

## Configuration

### `@TelemetryOptions` annotation

| Attribute | Purpose |
|---|---|
| `enabled` | Enable/disable tracing |
| `serviceName` | OpenTelemetry service name |
| `otlpEndpoint` | OTLP HTTP exporter endpoint |
| `serviceVersion` | Service version resource attribute |
| `deploymentEnvironment` | Deployment environment attribute |
| `useInMemoryExporters` | In-memory exporters for unit testing |
| `configureLogs` | Enable Log4j2 OpenTelemetry appender |
| `maxBatchSize` | Batch span processor max batch size |

### Environment variable overrides
Every `@TelemetryOptions` attribute can be overridden via system properties or environment variables.

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ TelemetryPreStartup (scans for @TelemetryOptions)
     └─ OpenTelemetrySDKConfigurator.initialize()
         ├─ Build Resource (service.name, version, environment, host)
         ├─ Create OTLP HTTP exporters (spans + logs)
         ├─ Build SdkTracerProvider + SdkLoggerProvider
         ├─ Set GlobalOpenTelemetry
         └─ Register shutdown hook
 └─ TraceModule (binds TraceMethodInterceptor for @Trace)
```

## Testing

Use in-memory exporters for unit tests:

```java
@TelemetryOptions(useInMemoryExporters = true)
public class TestConfig {}
```

Access `InMemorySpanExporter` and `InMemoryLogRecordExporter` to assert on captured spans.

## Non-Negotiable Constraints

- Module must `requires com.guicedee.telemetry;`.
- Traced classes must be in packages opened to `com.google.guice`.
- Guice AOP requires non-final, non-private methods for interception.
- The telemetry module is registered automatically — no `provides` needed.
- A JVM shutdown hook flushes pending spans automatically.


