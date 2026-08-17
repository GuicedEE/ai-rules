---
name: guicedee-metrics
description: "Application metrics for GuicedEE using Vert.x 5 Dropwizard Metrics and MicroProfile Metrics 5.1: @Counted, @Timed, @MetricMethod annotations, Guice AOP interceptors, Prometheus scrape endpoint, Graphite reporting, JMX exposure, @MetricsOptions configuration, environment variable overrides, and Vert.x built-in metrics (event bus, HTTP, pools). Use when adding application metrics, configuring Prometheus endpoints, creating custom counters/timers, or monitoring Vert.x internals."
metadata:
  short-description: Application metrics with Prometheus and Dropwizard inside GuicedEE
---

# GuicedEE Metrics

Production-ready application metrics using Vert.x 5 Dropwizard Metrics and the MicroProfile Metrics 5.1 API.

## Core Concept

Annotate your methods with standard `@Counted`, `@Timed`, and custom `@MetricMethod` — interceptors are bound through Guice AOP, metrics are collected into a shared `MetricRegistry`, and a Prometheus-compatible scrape endpoint is exposed on the Vert.x Web `RouterConfig` automatically.

## Required Flow

1. Add `com.guicedee:metrics` dependency.
2. Configure metrics with `@MetricsOptions`:
   ```java
   @MetricsOptions(
       enabled = true,
       jmxEnabled = true,
       baseName = "my-app",
       prometheus = @MetricsOptions.PrometheusOptions(enabled = true, endpoint = "/metrics")
   )
   public class MyAppConfig {}
   ```
3. Annotate methods. `@Counted`/`@Timed` are the **MicroProfile Metrics** annotations from `org.eclipse.microprofile.metrics.annotation` (packaged in the `com.codahale.metrics` JPMS module, not `com.guicedee.metrics`):
   ```java
   import org.eclipse.microprofile.metrics.annotation.Counted;
   import org.eclipse.microprofile.metrics.annotation.Timed;

   // absolute = true → use the name verbatim (no declaring-class prefix)
   @Counted(name = "orders_placed_total", absolute = true, description = "Orders placed")
   @Timed(name = "order_processing_seconds", absolute = true, description = "Order processing time")
   public void placeOrder(Order order) { ... }
   ```
4. Configure `module-info.java`. The MicroProfile annotations require `com.codahale.metrics`:
   ```java
   module my.app {
       requires com.guicedee.metrics;   // configurators + Prometheus /metrics endpoint
       requires com.codahale.metrics;   // @Counted / @Timed annotations + MetricRegistry
       opens my.app.services to com.google.guice;
   }
   ```
5. Bootstrap GuicedEE — metrics start automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   // GET /metrics returns Prometheus exposition format
   ```

## Metric Annotations

### `@Counted`
Increments a monotonic counter each invocation. Place on method or class (applies to all methods).

### `@Timed`
Measures execution time with quantile snapshots (p50, p75, p95, p98, p99, p999).

### `@MetricMethod`
Custom GuicedEE annotation. Increments a named counter. If the method returns a numeric type, the counter value is returned instead.

## Configuration

### `@MetricsOptions` annotation

| Attribute | Purpose |
|---|---|
| `enabled` | Enable/disable metrics |
| `registryName` | Dropwizard registry name |
| `jmxEnabled` | Expose as JMX MBeans |
| `baseName` | Metric name prefix |
| `monitoredHttpServerUris` | URI patterns to monitor |
| `monitoredEventBusHandlers` | EventBus handler patterns |
| `graphite` | `@GraphiteOptions` for Graphite reporting |
| `prometheus` | `@PrometheusOptions` for Prometheus endpoint |

### Environment variable overrides
Every `@MetricsOptions` attribute can be overridden via system properties or environment variables.

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ MetricsPreStartup (scans for @MetricsOptions)
 └─ MetricsVertxConfigurator (configures DropwizardMetricsOptions on VertxBuilder)
 └─ MetricsModule (binds MetricRegistry, interceptors, reporters)
 └─ PrometheusMetricsConfigurator (registers GET /metrics handler)
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.metrics;`.
- To use `@Counted`/`@Timed`, also `requires com.codahale.metrics;` (that module supplies the MicroProfile annotations **and** the `MetricRegistry`).
- Intercepted classes must be in packages opened to `com.google.guice`.
- Interception only fires on **Guice-managed instances** (`IGuiceContext.get(...)` / injected) — calling `new MyResource()` bypasses the AOP interceptors.
- The metrics module is registered automatically — no `provides` needed.
- Guice AOP requires non-final, non-private methods for interception.

## Testing

The shared `MetricRegistry` is injectable, so metrics can be asserted directly without scraping `/metrics`. Boot the context, resolve the **Guice-managed** bean (so AOP fires), invoke it, then read the registry:

```java
@BeforeAll
static void boot() {
    IGuiceContext.registerModule("my.app");
    IGuiceContext.instance().inject();
}

@Test
void metricsAreRecorded() {
    MyResource resource = IGuiceContext.get(MyResource.class); // managed → interceptors fire
    for (int i = 0; i < 3; i++) resource.placeOrder(order);

    MetricRegistry registry = IGuiceContext.get(MetricRegistry.class);

    // Names carry suffixes/tags in the registry — match by substring
    Counter counter = registry.getCounters().entrySet().stream()
        .filter(e -> e.getKey().contains("orders_placed_total"))
        .map(Map.Entry::getValue).findFirst().orElseThrow();
    assertTrue(counter.getCount() >= 3);

    Timer timer = registry.getTimers().entrySet().stream()
        .filter(e -> e.getKey().contains("order_processing_seconds"))
        .map(Map.Entry::getValue).findFirst().orElseThrow();
    assertTrue(timer.getCount() >= 3);
}
```

Test `module-info.java` needs `requires com.codahale.metrics;` (for `MetricRegistry`/`Counter`/`Timer`) and access to the metered class.


