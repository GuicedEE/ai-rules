---
name: guicedee-client
description: "GuicedEE client SPI contracts: IGuiceContext, lifecycle hook interfaces (IGuicePreStartup, IGuiceModule, IGuicePostStartup, IGuicePreDestroy, IGuiceConfigurator) — all extending IDefaultService for sort ordering and enablement, CallScope and CallScopeProperties, IJsonRepresentation for Jackson serialization, and JPMS module setup. Use when programming against GuicedEE SPI contracts, understanding the lifecycle hook interfaces, implementing IDefaultService, using call scoping, or referencing the client API without the full runtime."
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

All hooks extend `IDefaultService<J>` (CRTP) — override `sortOrder()` to control execution order and `enabled()` to conditionally skip.

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
| `IDefaultService` | Base for all SPI hooks (CRTP) with `sortOrder()` and `enabled()` |
| `CallScope` / `CallScopeProperties` | Request-scoped injection context |
| `IJsonRepresentation` | Jackson ObjectMapper configuration contract |

## Non-Negotiable Constraints

- Module must `requires com.guicedee.client;`.
- All SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- `sortOrder()` controls execution order — lower runs first.
- Lifecycle hooks are grouped by `sortOrder()` — all futures in a group must complete before the next group.
- `IGuicePreStartup.onStartup()` returns `List<Future<Boolean>>` — uses **Vert.x `io.vertx.core.Future`**.
- `IGuicePostStartup.postLoad()` returns `List<Uni<Boolean>>` — uses **Mutiny `io.smallrye.mutiny.Uni`**.
- These are DIFFERENT types — do not confuse them.

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
