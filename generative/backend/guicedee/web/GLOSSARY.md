# Glossary — GuicedEE Vert.x Web

This glossary defines terms specific to **GuicedEE Vert.x Web** (`com.guicedee.vertx.web`). For terms not listed here, defer to parent topic glossaries in this order:

1. [GuicedEE GLOSSARY](../GLOSSARY.md)
2. [GuicedEE Vert.x GLOSSARY](../vertx/GLOSSARY.md)
3. [Vert.x GLOSSARY](../../vertx/README.md)
4. [Fluent API GLOSSARY](../../fluent-api/GLOSSARY.md)
5. [Enterprise GLOSSARY](../../../../GLOSSARY.md)

---

## Term Definitions

### Bootstrap / Startup Flow

- **IGuicePostStartup**: GuiceEE lifecycle interface that fires post-bootstrap, used by `VertxWebServerPostStartup` to initialize HTTP/HTTPS servers.
- **VertxWebServerPostStartup**: Concrete provider of `IGuicePostStartup` that orchestrates Vert.x HttpServer creation, SPI configurator discovery, and router setup.
- **Startup Phase**: The post-bootstrap phase when `VertxWebServerPostStartup.postLoad()` executes, triggered by GuiceEE's `IGuiceContext.init()`.

### HTTP/HTTPS Server Configuration

- **HTTP_ENABLED**: Boolean environment variable (default: `true`) controlling whether an HTTP server is created on `HTTP_PORT`.
- **HTTP_PORT**: Integer environment variable (default: `8080`) specifying the port for the HTTP server.
- **HTTPS_ENABLED**: Boolean environment variable (default: `false`) controlling whether an HTTPS server is created on `HTTPS_PORT`.
- **HTTPS_PORT**: Integer environment variable (default: `8443`) specifying the port for the HTTPS server.
- **HTTPS_KEYSTORE**: Path to the JKS/PFX/P12 keystore file for TLS (file extension determines format auto-detection).
- **HTTPS_KEYSTORE_PASSWORD**: Password for the keystore; should not be committed; use GitHub Actions secrets or `.env` (excluded from VCS).
- **HttpServerOptions**: Vert.x immutable options object holding configuration (compression, TCP keep-alive, header size limits, etc.); customized via `VertxHttpServerOptionsConfigurator`.
- **HttpServer**: Vert.x HttpServer instance listening on a configured port; customized via `VertxHttpServerConfigurator`.

### SPI (Service Provider Interface)

- **VertxRouterConfigurator**: Functional SPI interface (`Router builder(Router)`) allowing modules to register routes and handlers on the shared router. Discovered via `ServiceLoader<VertxRouterConfigurator>` at startup.
- **VertxHttpServerConfigurator**: Functional SPI interface (`HttpServer builder(HttpServer)`) allowing modules to customize the HttpServer instance (e.g., attach WebSocket handlers). Discovered via `ServiceLoader<VertxHttpServerConfigurator>`.
- **VertxHttpServerOptionsConfigurator**: Functional SPI interface (`HttpServerOptions builder(HttpServerOptions)`) allowing modules to tune HttpServerOptions before server creation (compression level, max header size, etc.). Discovered via `ServiceLoader<VertxHttpServerOptionsConfigurator>`.
- **SPI Implementor Module**: Any downstream module declaring `provides com.guicedee.vertx.web.spi.<Interface> with <Implementation>` in its `module-info.java`; discovered and applied in order by GuiceEE's ServiceLoader integration.

### Routing & Request Handling

- **Router**: Vert.x Router instance (`io.vertx.ext.web.Router`) managing route registration and request matching; created in `VertxWebServerPostStartup` and customized via `VertxRouterConfigurator` implementations.
- **Route Handler**: A function implementing `Handler<RoutingContext>` that processes a matched HTTP request and sends a response.
- **RoutingContext**: Vert.x routing context encapsulating the `HttpServerRequest`, `HttpServerResponse`, and request/response data (body, params, headers, etc.).
- **BodyHandler**: Vert.x handler (`io.vertx.ext.web.handler.BodyHandler`) that automatically parses request bodies and stores file uploads; configured with `setUploadsDirectory("uploads")` and `setDeleteUploadedFilesOnEnd(true)` by default.
- **Uploads Directory**: Default directory (`uploads/`) where multipart file uploads are temporarily stored; cleaned after each request by BodyHandler.

### Integration with GuiceEE

- **IGuiceContext**: GuiceEE context providing `IGuiceContext.get(Class)` for retrieving injected instances. Used in `VertxWebServerPostStartup` to inject configurators.
- **Dependency Injection**: GuiceEE (`com.google.guice`) integration allowing `VertxRouterConfigurator`, `VertxHttpServerConfigurator`, and `VertxHttpServerOptionsConfigurator` implementations to declare `@Inject` fields for services.
- **JPMS Module Declaration**: The module `com.guicedee.vertx.web` exports `com.guicedee.vertx.web.spi` and declares `uses` of all three configurator SPI interfaces; downstream modules declare `provides` entries for their implementations.

### Building & Delivery

- **Maven Artifact**: `com.guicedee:guiced-vertx-web:VERSION` published with transitive dependencies on `guiced-vertx`, `io.vertx:vertx-web`, and `io.vertx:vertx-core`.
- **JPMS Module**: `com.guicedee.vertx.web` (module name in Java 25+ Module System).
- **Export Surface**: Only `com.guicedee.vertx.web.spi` is exported; internal implementation packages (`com.guicedee.vertx.web.spi.impl`, etc.) remain package-private.

---

## Prompt Language Alignment

When prompting about GuicedEE Vert.x Web:

- Use **"VertxRouterConfigurator"** instead of "route handler interface" or "router extension".
- Use **"VertxHttpServerConfigurator"** for WebSocket handlers or server-level customization.
- Use **"VertxHttpServerOptionsConfigurator"** for tuning compression, timeouts, or TLS.
- Use **"SPI Implementor Module"** to refer to a downstream module extending the web server.
- Use **"VertxWebServerPostStartup"** when describing the startup hook.
- Use **"uploads/ directory"** and **"BodyHandler"** consistently.
- Refer to **"environment variables"** (`HTTP_ENABLED`, etc.) instead of "config files" when discussing runtime tuning.
- Prefer **"JPMS module declaration"** over "manifest" when discussing `module-info.java`.

---

## Cross-References

- **CRTP in GuicedEE Vert.x Web:** Configurators implement fluent patterns returning `this` (cast to `(J)this` where `J` is the implementing class if subclassed) per [rules/generative/backend/fluent-api/crtp.rules.md](../../fluent-api/crtp.rules.md).
- **Nullness in SPI:** All SPI interface method parameters and return types should be annotated with JSpecify annotations per [rules/generative/backend/jspecify/README.md](../../jspecify/README.md).
- **Java 25 Language Features:** Follow [rules/generative/language/java/java-25.rules.md](../../../language/java/java-25.rules.md) for modern language usage in implementations.

---

**Last Updated:** November 2025  
**Scope:** GuicedEE Vert.x Web (`com.guicedee.vertx.web`)
