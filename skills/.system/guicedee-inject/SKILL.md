---
name: guicedee-inject
description: "Bootstrap and manage the GuicedEE runtime engine: classpath scanning, Guice injector creation, lifecycle hooks, logging configuration, job pools, and module registration. Use when wiring up a GuicedEE application, configuring classpath scanning SPIs, setting up Log4j2 logging with LogUtils or @InjectLogger, managing JobService pools, implementing lifecycle hooks (IGuicePreStartup, IGuiceModule, IGuicePostStartup, IGuicePreDestroy), or troubleshooting the DI bootstrap sequence."
---

# GuicedEE Inject

The runtime engine that classpath-scans, creates the Guice injector, and manages the full startup/shutdown lifecycle.

## Core Concept

`GuiceContext` is a singleton that orchestrates everything. Call `inject()` once — it discovers SPIs, scans, builds the injector, and runs lifecycle hooks:

```
IGuiceConfigurator → ClassGraph scan → IGuicePreStartup → Injector created → IGuicePostStartup
                                                                                    ↓
                                                                          IGuicePreDestroy (shutdown)
```

## Required Flow

1. Add `com.guicedee:inject` dependency.
2. Register your module for scanning, then bootstrap:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   ```
3. Configure `module-info.java`:
   - `requires com.guicedee.guicedinjection;`
   - `opens` injection packages to `com.google.guice`
   - `opens` DTO packages to `com.fasterxml.jackson.databind`
   - `provides` every SPI implementation
4. Dual-register all SPIs in `module-info.java` and `META-INF/services/`.

## Providing Guice Modules

Implement `IGuiceModule` and register via SPI:

```java
public class AppModule extends AbstractModule implements IGuiceModule<AppModule> {
    @Override
    protected void configure() {
        bind(Greeter.class).to(DefaultGreeter.class);
    }
}
```

```java
// module-info.java
provides com.guicedee.client.services.lifecycle.IGuiceModule with my.app.AppModule;
```

## Lifecycle Hooks

| Hook | When it runs | Return |
|---|---|---|
| `IGuiceConfigurator` | First — configures `GuiceConfig` before scanning | `IGuiceConfig<?>` |
| `IGuicePreStartup` | After scan, before injector — grouped by `sortOrder()` | `List<Future<Boolean>>` |
| `IGuiceModule` | During injector creation — standard Guice module | — |
| `IGuicePostStartup` | After injector is ready — async, grouped by `sortOrder()` | `List<Uni<Boolean>>` |
| `IGuicePreDestroy` | On shutdown — cleanup resources | `void` |

All hooks extend `IDefaultService<J>` (CRTP); override `sortOrder()` to control execution order and `enabled()` to conditionally skip.

## Logging

### `LogUtils` — programmatic setup

```java
LogUtils.addHighlightedConsoleLogger();        // ANSI console (local dev)
LogUtils.addConsoleLogger(Level.INFO);         // plain console
LogUtils.addFileRollingLogger("app", "logs");  // rolling file (100 MB / daily)
Logger audit = LogUtils.getSpecificRollingLogger("audit", "logs/audit", null, false);
```

When `CLOUD` env var is set, layouts auto-switch to compact JSON.

### Log level control

Set via environment: `GUICEDEE_LOG_LEVEL`, `LOG_LEVEL`, `DEBUG=true`, or `TRACE=true`.
Programmatic: `GuiceContext.setDefaultLogLevel(Level.INFO)`.

## JobService

Virtual-thread-backed executor pools with graceful shutdown:

```java
JobService jobs = JobService.INSTANCE;
jobs.registerJob("import", 100);
jobs.addJob("import", () -> processFile(file));
jobs.registerPollingJob("heartbeat", () -> ping(), 0, 30, TimeUnit.SECONDS);
```

Pools auto-shutdown via `IGuicePreDestroy`.

## Non-Negotiable Constraints

- Never call `inject()` recursively during build — use `IGuicePostStartup` instead.
- At most one `GuiceContext` instance per JVM.
- Every SPI must be dual-registered (`module-info.java` + `META-INF/services/`).
- Injection packages must `opens` to `com.google.guice`.
- `IGuiceContext.registerModuleForScanning.add("my.module")` must be called before `instance()`.
- All lifecycle hooks must extend `IDefaultService<J>` (CRTP) and override `sortOrder()`.

## References

- `references/classpath-scanning.md` — scanner SPI interfaces, `GuiceConfig` options, module/JAR/package filtering.
- `references/lifecycle-logging.md` — lifecycle hook details, `@InjectLogger` attributes, `LogUtils` API, `Log4JConfigurator` SPI, `JobService` full API.

