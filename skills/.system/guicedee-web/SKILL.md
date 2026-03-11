---
name: guicedee-web
description: "Bootstrap reactive HTTP/HTTPS servers with Vert.x 5 inside GuicedEE: Router setup, BodyHandler configuration, TLS/HTTPS, SPI extension points (VertxRouterConfigurator, VertxHttpServerOptionsConfigurator, VertxHttpServerConfigurator), per-verticle sub-routers, and environment-driven configuration. Use when setting up the Vert.x web server, configuring HTTP/HTTPS, adding custom routes or middleware, or managing server options."
metadata:
  short-description: Reactive HTTP/HTTPS server bootstrap with Vert.x inside GuicedEE
---

# GuicedEE Web

Reactive HTTP/HTTPS server bootstrap for GuicedEE applications using Vert.x 5.

## Core Concept

Provides the `Router`, `HttpServer`, and `BodyHandler` plumbing that higher-level modules (`rest`, `websockets`, etc.) build on top of. Configuration is environment-driven; extension is SPI-driven. The server starts automatically via `IGuicePostStartup`.

## Required Flow

1. Add `com.guicedee:web` dependency.
2. Bootstrap GuicedEE — the web server starts automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   // HTTP server is now listening on port 8080 (default)
   ```
3. Add routes by implementing `VertxRouterConfigurator`:
   ```java
   public class MyRoutes implements VertxRouterConfigurator<MyRoutes> {
       @Override
       public Router builder(Router router) {
           router.get("/health").handler(ctx -> ctx.response().end("OK"));
           return router;
       }

       @Override
       public Integer sortOrder() { return 500; }
   }
   ```
4. Register via JPMS:
   ```java
   module my.app {
       requires com.guicedee.vertx.web;
       provides com.guicedee.vertx.web.spi.VertxRouterConfigurator
           with my.app.MyRoutes;
   }
   ```

## SPI Extension Points

All SPIs are discovered via `ServiceLoader`. Register with JPMS `provides...with` or `META-INF/services`.

| SPI | When it runs | Purpose |
|---|---|---|
| `VertxHttpServerOptionsConfigurator` | Before servers created | Customize `HttpServerOptions` (ports, TLS, compression) |
| `VertxHttpServerConfigurator` | After server creation | Configure `HttpServer` instance (WebSocket upgrade, connection hooks) |
| `VertxRouterConfigurator` | After body handler | Add routes, middleware, handlers to the `Router` |

## Configuration

All configuration is driven by system properties or environment variables:

| Variable | Default | Purpose |
|---|---|---|
| `HTTP_ENABLED` | `true` | Enable HTTP server |
| `HTTP_PORT` | `8080` | HTTP listen port |
| `HTTPS_ENABLED` | `false` | Enable HTTPS server |
| `HTTPS_PORT` | `443` | HTTPS listen port |
| `HTTPS_KEYSTORE` | — | Path to JKS or PKCS#12 keystore |
| `HTTPS_KEYSTORE_PASSWORD` | — | Keystore password |
| `VERTX_MAX_BODY_SIZE` | `524288000` (500 MB) | Maximum request body size |

## TLS/HTTPS

Keystore format is auto-detected by file extension:
- `.jks` → JKS
- `.pfx`, `.p12`, `.p8` → PKCS#12

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ IGuicePostStartup hooks
     └─ VertxWebServerPostStartup (sortOrder = MIN_VALUE + 500)
         ├─ Build HttpServerOptions (compression, keepalive, header limits)
         ├─ Apply VertxHttpServerOptionsConfigurator SPIs
         ├─ Create HTTP / HTTPS servers
         ├─ Apply VertxHttpServerConfigurator SPIs
         ├─ Create Router + BodyHandler
         ├─ Apply VertxRouterConfigurator SPIs (sorted)
         ├─ Mount per-verticle sub-routers
         ├─ Configure Jackson ObjectMapper via IJsonRepresentation
         └─ server.listen()
```

## Non-Negotiable Constraints

- Never create `HttpServer` manually — use the auto-started server from `VertxWebServerPostStartup`.
- Module must `requires com.guicedee.vertx.web;`.
- SPI implementations must be dual-registered (`module-info.java` + `META-INF/services/`).
- `VertxRouterConfigurator` implementations control ordering via `sortOrder()`.



