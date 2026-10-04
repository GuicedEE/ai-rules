# Module Graph

JPMS transitive dependencies for `com.guicedee.vertx`:

```
com.guicedee.vertx
 ├── com.guicedee.client              (SPI contracts)
 ├── com.guicedee.jsonrepresentation  (JSON codec support)
 ├── io.vertx.core                    (Vert.x 5 runtime)
 ├── io.vertx.mutiny                  (Mutiny bindings)
 ├── io.smallrye.mutiny               (reactive streams)
 ├── tools.jackson.databind   (JSON mapping)
 ├── com.fasterxml.jackson.annotation
 ├── tools.jackson.core
 ├── org.apache.logging.log4j         (logging)
 ├── jakarta.cdi                      (CDI annotations)
 └── lombok                           (static, compile-only)
```

Relevant exported packages include:

- `com.guicedee.vertx` — annotations (`@VertxEventDefinition`, `@VertxEventOptions`), `VertxEventPublisher`, `VertXModule`
- `com.guicedee.vertx.spi` — SPI interfaces, annotations, registry, codec, verticle builder

Both packages are `opens` to `com.google.guice` for injection.

The socket backpressure integration also declares direct (not transitive) `requires io.netty.transport;` and `requires io.netty.common;`. Verify those modules on the effective runtime module path.

## SPI Registrations (provided by this module)

| SPI | Implementation |
|---|---|
| `IGuicePreStartup` | `VertXPreStartup` |
| `IGuicePreDestroy` | `VertXPostStartup` |
| `IGuiceModule` | `VertXModule` |
| `IGuiceConfigurator` | `VertxClassScanConfig` |
| `VerticleStartup` | `VertxConsumersStartup` |
| `io.vertx.core.spi.JsonFactory` | `GuicedVertxJsonFactory` (routes all Vert.x JSON through the GuicedEE Jackson 3 mapper) |

## SPI Consumed (user-implementable)

| SPI | Purpose |
|---|---|
| `VertxConfigurator` | Compose shared `VertxOptions` first, then `VertxBuilder` hooks |
| `VerticleStartup` | Register custom verticle bootstrap logic |
