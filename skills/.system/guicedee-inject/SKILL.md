---
name: guicedee-inject
description: "Bootstrap or debug GuicedEE scanning, Guice injection, lifecycle hooks, module registration, logging, and job pools."
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
   - `opens` DTO packages to `tools.jackson.databind`
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
| `IGuicePreDestroy` | Shutdown and startup rollback — ascending `shutdownSortOrder()`, then class name | `void` |

All hooks extend `IDefaultService<J>` (CRTP). Startup uses `sortOrder()`; shutdown uses `shutdownSortOrder()` (defaulting to `sortOrder()`) with class-name tie-breaking. `IGuiceModule` additionally declares `enabled()` (default `true`). `IDefaultService`, startup, shutdown, and configurator hooks do not declare `enabled()`; gate their work inside the hook body.

## Startup failure and dependency teardown

Synchronous exceptions, failed asynchronous pre-startup futures, and startup timeouts abort injection and run ordered rollback for partially initialized resources. Do not log a failed cluster join and continue to advertise readiness. `GUICEDEE_STARTUP_TIMEOUT_SECONDS` controls pre-startup waiting (default 60 seconds).

Assign shutdown order independently of startup order when dependency direction reverses. For clustering, await the asynchronous Vert.x close at `MAX_VALUE - 200` before owned Hazelcast shutdown at `MAX_VALUE - 100`. Cleanup must tolerate absent or partly started resources. Test failed joins and occupied event-bus ports as well as normal destruction, checking threads, instances, and readiness state.

## Process startup and terminal shutdown

For executable application entry points, `GuiceApplication.run(Runnable preparation)` waits for both injection and `getLoadingFinished()`. It returns after successful startup. It owns process exit on failure, so do not call it from embedded libraries or in-process unit tests. Its startup deadline defaults to 300 seconds and its failed-startup cleanup deadline to 45 seconds (`GUICEDEE_FAILED_STARTUP_CLEANUP_SECONDS`). The lower-level pre-startup future wait in `GuiceContext` defaults to 60 seconds; both startup waits read `GUICEDEE_STARTUP_TIMEOUT_SECONDS` when explicitly configured.

`GuiceContext.destroy()` is terminal and idempotent. The first caller runs cleanup; concurrent callers await it and same-thread re-entry returns. Existing bindings remain available during cleanup, then the injector is cleared and new injection is rejected. Do not recreate the injector from a destroy hook or add application-specific process-kill workarounds. Use a fresh JVM for another full lifecycle.

Implementation anchors: `GuicedEE/inject/.../GuiceApplication.java`, `GuiceContext.java`, and `ShutdownLifecycleTest`.

## Logging setup

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
- Scanning is **off by default** and no built-in configurator enables it — call `IGuiceContext.instance().getConfig().setClasspathScanning(true).setAnnotationScanning(true).setMethodInfo(true).setFieldInfo(true)` (or `setServiceLoadWithClassPath(true)`) **before** `inject()`, or annotation discovery finds nothing. Tests that boot directly must do the same in `@BeforeAll`.
- All hooks extend `IDefaultService<J>` (CRTP). Startup uses `sortOrder()`; shutdown uses `shutdownSortOrder()` (defaulting to `sortOrder()`) with class-name tie-breaking. `IGuiceModule` additionally declares `enabled()` (default `true`). `IDefaultService`, startup, shutdown, and configurator hooks do not declare `enabled()`; gate their work inside the hook body.
- Resolve env vars/system properties **only** via `com.guicedee.client.Environment.getSystemPropertyOrEnvironment(name, default)` — never `System.getenv`/`System.getProperty` and never a hand-rolled `env(...)` helper. It layers system properties → env vars → `.env.local` → `.env` → default and resolves `${VAR:-default}` placeholders.

## References

- `references/classpath-scanning.md` — scanner SPI interfaces, `GuiceConfig` options, module/JAR/package filtering.
- `references/lifecycle-logging.md` — lifecycle hook details, `@InjectLogger` attributes, `LogUtils` API, `Log4JConfigurator` SPI, `JobService` full API.
