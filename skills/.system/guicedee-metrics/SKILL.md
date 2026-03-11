---
name: guicedee-metrics
description: "Application metrics for GuicedEE using Vert.x 5 Dropwizard Metrics and MicroProfile Metrics 5.1: @Counted, @Timed, @MetricMethod annotations, Guice AOP interceptors, Prometheus scrape endpoint, Graphite reporting, JMX exposure, @MetricsOptions configuration, environment variable overrides, and Vert.x built-in metrics (event bus, HTTP, pools). Use when adding application metrics, configuring Prometheus endpoints, creating custom counters/timers, or monitoring Vert.x internals."
metadata:
  short-description: Application metrics with Prometheus and Dropwizard inside GuicedEE
---

# GuicedEE Metrics

Production-ready application metrics using Vert.x 5 Dropwizard Metrics and the MicroProfile Metrics 5.1 API.

## Core Concept

Annotate your methods with standard `@Counted`, `@Timed`, and custom `@MetricMethod` — interceptors are bound through Guice AOP, metrics are collected into a shared `MetricRegistry`, and a Prometheus-compatible scrape endpoint is exposed on the Vert.x Web `Router` automatically.

## Required Flow

1. Add `com.guicedee:metrics` dependency.
2. Configure metrics with `@MetricsOptions`:
   ```java
   @MetricsOptions(
       enabled = true,
       jmxEnabled = true,
       baseName = "my-app",
       prometheus = @PrometheusOptions(enabled = true, endpoint = "/metrics")
   )
   public class MyAppConfig {}
   ```
3. Annotate methods:
   ```java
   @Counted(name = "orders-placed", tags = {"env=prod"})
   public void placeOrder(Order order) { ... }

   @Timed(name = "order-processing-time")
   public void processOrder(Order order) { ... }
   ```
4. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.metrics;
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
- Intercepted classes must be in packages opened to `com.google.guice`.
- The metrics module is registered automatically — no `provides` needed.
- Guice AOP requires non-final, non-private methods for interception.


