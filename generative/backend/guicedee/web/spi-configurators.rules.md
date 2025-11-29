# SPI Interfaces & Registration — GuicedEE Vert.x Web

This module defines three functional SPI interfaces for extending and customizing the HTTP/HTTPS server, server options, and router during GuiceEE startup.

## SPI Interfaces Overview

GuicedEE Vert.x Web provides three main extension points:

1. **VertxHttpServerOptionsConfigurator** — Customize `HttpServerOptions` before server creation
2. **VertxHttpServerConfigurator** — Customize the `HttpServer` instance after creation (e.g., WebSocket handlers)
3. **VertxRouterConfigurator** — Customize the `Router` before it's attached as the request handler

All follow a **builder pattern** (fluent): accept an instance, modify it, return it.

## VertxHttpServerOptionsConfigurator

```java
package com.guicedee.vertx.web.spi;

import io.vertx.core.http.HttpServerOptions;

@FunctionalInterface
public interface VertxHttpServerOptionsConfigurator
{
    HttpServerOptions builder(HttpServerOptions options);
}
```

**Purpose:** Tune HttpServerOptions (compression, timeouts, max sizes, TLS) before the server is created.

**Example:**

```java
public class CustomOptionsConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        return options
            .setCompressionLevel(6)
            .setMaxHeaderSize(32768)
            .setLogActivity(true);
    }
}
```

## VertxHttpServerConfigurator

```java
package com.guicedee.vertx.web.spi;

import io.vertx.core.http.HttpServer;

@FunctionalInterface
public interface VertxHttpServerConfigurator
{
    HttpServer builder(HttpServer server);
}
```

**Purpose:** Configure the live HttpServer instance (attach WebSocket handlers, custom middleware, request interceptors).

**Example:**

```java
public class WebSocketConfigurator implements VertxHttpServerConfigurator
{
    @Override
    public HttpServer builder(HttpServer server)
    {
        server.webSocketHandler(ws -> {
            ws.textMessageHandler(msg -> ws.writeTextMessage("Echo: " + msg));
        });
        return server;
    }
}
```

## VertxRouterConfigurator

```java
package com.guicedee.vertx.web.spi;

import io.vertx.ext.web.Router;

@FunctionalInterface
public interface VertxRouterConfigurator
{
    Router builder(Router router);
}
```

**Purpose:** Register routes, handlers, and middleware on the shared Router.

**Example:**

```java
public class ApiRoutesConfigurator implements VertxRouterConfigurator
{
    @Inject
    private UserService userService;

    @Override
    public Router builder(Router router)
    {
        router.get("/api/users").handler(ctx -> {
            List<User> users = userService.getAll();
            ctx.response()
               .putHeader("content-type", "application/json")
               .end(Json.encode(users));
        });
        return router;
    }
}
```

## Registering SPI Implementations

### Option 1: Java Module System (Recommended)

Declare `provides` in your module's `module-info.java`:

```java
module com.example.web {
    requires com.guicedee.vertx.web;
    requires transitive com.guicedee.vertx;

    provides com.guicedee.vertx.web.spi.VertxRouterConfigurator
        with com.example.web.routes.ApiRoutesConfigurator;

    provides com.guicedee.vertx.web.spi.VertxHttpServerConfigurator
        with com.example.web.server.WebSocketConfigurator;
}
```

**Benefits:**
- Explicit, version-controlled declarations
- Automatic discovery via `ServiceLoader`
- Respects JPMS visibility and module graph
- No runtime file scanning

### Option 2: META-INF/services

Create `META-INF/services/<interface-fully-qualified-name>` with one implementation class per line.

**File:** `META-INF/services/com.guicedee.vertx.web.spi.VertxRouterConfigurator`
```
com.example.web.routes.ApiRoutesConfigurator
```

**Benefits:**
- Compatible with non-modular JARs
- Fallback for legacy builds

**Note:** JPMS is preferred; use META-INF/services only when JPMS is not available.

## Discovery & Execution Order

`VertxWebServerPostStartup` discovers all implementations via `ServiceLoader`:

```
ServiceLoader<VertxHttpServerOptionsConfigurator> optionsConfigs = ServiceLoader.load(...);
for (var configurator : optionsConfigs) {
    options = IGuiceContext.get(configurator.getClass()).builder(options);
}

ServiceLoader<VertxHttpServerConfigurator> serverConfigs = ServiceLoader.load(...);
for (var configurator : serverConfigs) {
    server = IGuiceContext.get(configurator.getClass()).builder(server);
}

ServiceLoader<VertxRouterConfigurator> routerConfigs = ServiceLoader.load(...);
for (var configurator : routerConfigs) {
    router = IGuiceContext.get(configurator.getClass()).builder(router);
}
```

**Order Notes:**
- Options configurators run first (before server creation)
- Server configurators run after server creation (before port binding)
- Router configurators run last (router setup)
- Order across multiple implementations is determined by service loader (not guaranteed; assume unordered)

## Guidelines for Implementations

1. **Keep implementations focused.** One configurator per concern (routes, options, WebSocket, etc.)
2. **Use dependency injection.** Inject services via `@Inject` fields; GuiceEE will resolve them.
3. **Return the modified instance.** Always return the builder-passed instance (or a replacement if needed).
4. **Avoid side effects.** Configure only the passed object; don't modify global state.
5. **Handle nullness gracefully.** Apply JSpecify annotations; check for optional settings.
6. **Document expectations.** State in comments what options/routes you depend on from other configurators.

## Common Patterns

### Pattern: Conditional Configuration

```java
public class ConditionalRoutesConfigurator implements VertxRouterConfigurator
{
    @Inject
    private Environment env;

    @Override
    public Router builder(Router router)
    {
        if (env.isDebugEnabled()) {
            router.get("/debug/info").handler(ctx -> {
                ctx.response().end("Debug info...");
            });
        }
        return router;
    }
}
```

### Pattern: Composite Routes

```java
public class CompositeRouterConfigurator implements VertxRouterConfigurator
{
    @Inject
    private ApiRoutesConfigurator apiRoutes;
    
    @Inject
    private AdminRoutesConfigurator adminRoutes;

    @Override
    public Router builder(Router router)
    {
        apiRoutes.builder(router);
        adminRoutes.builder(router);
        return router;
    }
}
```

### Pattern: Options Enhancement

```java
public class PerformanceConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        return options
            .setTcpKeepAlive(true)
            .setTcpNoDelay(true)
            .setCompressionLevel(9);
    }
}
```

## See Also

- [server-configuration.rules.md](server-configuration.rules.md) — HTTP/HTTPS setup and env variables
- [router-configuration.rules.md](router-configuration.rules.md) — Router & request handling
- [module-info.rules.md](module-info.rules.md) — JPMS module configuration
- [lifecycle.rules.md](lifecycle.rules.md) — Startup sequence and integration
- [GLOSSARY.md](GLOSSARY.md) — Terminology (VertxRouterConfigurator, etc.)
