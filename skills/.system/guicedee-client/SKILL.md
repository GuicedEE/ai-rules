---
name: guicedee-client
description: "GuicedEE client SPI contracts: IGuiceContext, lifecycle hook interfaces (IGuicePreStartup, IGuiceModule, IGuicePostStartup, IGuicePreDestroy, IGuiceConfigurator) — all extending IDefaultService for sort ordering, with module-specific enablement, CallScope and CallScopeProperties, IJsonRepresentation for Jackson serialization, and JPMS module setup. Use when programming against GuicedEE SPI contracts, understanding the lifecycle hook interfaces, implementing IDefaultService, using call scoping, or referencing the client API without the full runtime."
metadata:
  short-description: GuicedEE client SPI contracts and lifecycle interfaces
---

# GuicedEE Client

The client SPI library — defines the contracts that all GuicedEE modules program against without pulling in the full runtime.

## Core Concept

This library provides the interfaces and annotations for the GuicedEE lifecycle. Application code and library modules depend on `client` to register hooks, access the injector, and define scoping — without coupling to the runtime engine in `inject`.

## Required Flow

1. Add `com.guicedee:client` dependency.
2. Register your module for classpath scanning:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext context = IGuiceContext.instance();
   Injector injector = context.inject();
   ```
3. Register hooks with JPMS `provides`:
   ```java
   module my.app {
       requires com.guicedee.client;
       provides com.guicedee.client.services.lifecycle.IGuiceModule
           with my.app.AppModule;
   }
   ```

## Lifecycle Hook Interfaces

All hooks extend `IDefaultService<J>` (CRTP); override `sortOrder()` when a custom execution order is needed. `IGuiceModule` additionally declares `enabled()` (default `true`). `IDefaultService`, startup, shutdown, and configurator hooks do not declare `enabled()`; gate their work inside the hook body.

| Interface | When | Purpose |
|---|---|---|
| `IGuiceConfigurator<J>` | First | Configure `GuiceConfig` before scanning |
| `IGuicePreStartup<J>` | After scan, before injector | Pre-startup tasks, returns `List<Future<Boolean>>` |
| `IGuiceModule<J>` | During injector creation | Standard Guice `AbstractModule` |
| `IGuicePostStartup<J>` | After injector ready | Post-startup tasks, returns `List<Uni<Boolean>>` |
| `IGuicePreDestroy<J>` | On shutdown | Cleanup resources |

## Key Classes

| Class | Purpose |
|---|---|
| `IGuiceContext` | Singleton access to injector and context |
| `IDefaultService` | Base for all SPI hooks (CRTP) with `sortOrder()` (default `100`; some hooks override the default, e.g. `IGuicePostStartup` = `50`) |
| `Environment` | **Canonical** environment-variable / system-property resolver — always use this instead of `System.getenv`/`System.getProperty` |
| `CallScope` / `CallScopeProperties` | Request-scoped injection context |
| `IJsonRepresentation` | Jackson ObjectMapper configuration contract |

## Environment Variables — always use `Environment`

**Never** call `System.getenv(...)` / `System.getProperty(...)` directly, and **never** write a local `env(...)`/`getProperty(...)` helper. Resolve every environment variable and system property through `com.guicedee.client.Environment`:

```java
import com.guicedee.client.Environment;

// name, default — returns the resolved value (never null; empty string if no default)
String enterprise = Environment.getSystemPropertyOrEnvironment("AM_ENTERPRISE_NAME", "NE1 World");
boolean enabled   = Boolean.parseBoolean(
        Environment.getSystemPropertyOrEnvironment("AM_INSTALL_ENABLED", "true"));
```

`Environment.getSystemPropertyOrEnvironment(name, default)` resolves with this precedence (highest first):

1. System property (`-Dname=value`)
2. OS environment variable (`name`, then the upper-cased/underscored `NAME` variant)
3. `.env.local` file (local overrides, typically git-ignored)
4. `.env` file (shared defaults, may be committed)
5. the provided default (with `${...}` placeholders resolved)

Other helpers: `Environment.getProperty(name, default)` (lighter system-property/env only), `Environment.resolvePlaceholders(value)` for `${VAR:-default}` strings, and `Environment.reloadDotEnv()` for tests. All string config attributes therefore support `${ENV_VAR}` placeholders for free.

## Non-Negotiable Constraints

- Module must `requires com.guicedee.client;`.
- All SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- `sortOrder()` controls execution order — lower runs first. `IGuiceModule.enabled()` controls module enablement; other hooks gate work inside their method.
- Lifecycle hooks are grouped by `sortOrder()` — all futures in a group must complete before the next group.
- `IGuicePreStartup.onStartup()` returns `List<Future<Boolean>>` — uses **Vert.x `io.vertx.core.Future`**.
- `IGuicePostStartup.postLoad()` returns `List<Uni<Boolean>>` — uses **Mutiny `io.smallrye.mutiny.Uni`**.
- These are DIFFERENT types — do not confuse them.
- Resolve env vars/system properties **only** through `Environment.getSystemPropertyOrEnvironment(name, default)` — never `System.getenv`/`System.getProperty` and never a hand-rolled `env(...)` helper.

## Common JPMS Module Names

When adding `requires` directives, use the correct module names:

| Maven Artifact | JPMS Module Name |
|---|---|
| `io.vertx:vertx-core` | `io.vertx.core` |
| `io.vertx:vertx-web` | `io.vertx.web` |
| `io.vertx:vertx-web-client` | `io.vertx.web.client` |
| `io.vertx:vertx-service-resolver` | `io.vertx.serviceresolver` |
| `io.smallrye.reactive:mutiny` | `io.smallrye.mutiny` |
| `io.github.classgraph:classgraph` | `io.github.classgraph` |
| `com.google.inject:guice` | `com.google.guice` |
