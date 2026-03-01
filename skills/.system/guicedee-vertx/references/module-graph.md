# Module Graph

JPMS transitive dependencies for `com.guicedee.vertx`:

```
com.guicedee.vertx
 ├── com.guicedee.client              (SPI contracts)
 ├── com.guicedee.jsonrepresentation  (JSON codec support)
 ├── io.vertx.core                    (Vert.x 5 runtime)
 ├── io.vertx.mutiny                  (Mutiny bindings)
 ├── io.smallrye.mutiny               (reactive streams)
 ├── com.fasterxml.jackson.databind   (JSON mapping)
 ├── com.fasterxml.jackson.annotation
 ├── com.fasterxml.jackson.core
 ├── org.apache.logging.log4j         (logging)
 ├── jakarta.cdi                      (CDI annotations)
 └── lombok                           (static, compile-only)
```

The module `exports` two packages:

- `com.guicedee.vertx` — annotations (`@VertxEventDefinition`, `@VertxEventOptions`), `VertxEventPublisher`, `VertXModule`
- `com.guicedee.vertx.spi` — SPI interfaces, annotations, registry, codec, verticle builder

Both packages are `opens` to `com.google.guice` for injection.

## SPI Registrations (provided by this module)

| SPI | Implementation |
|---|---|
| `IGuicePreStartup` | `VertXPreStartup` |
| `IGuicePreDestroy` | `VertXPostStartup` |
| `IGuiceModule` | `VertXModule` |
| `IGuiceConfigurator` | `VertxClassScanConfig` |
| `VerticleStartup` | `VertxConsumersStartup` |

## SPI Consumed (user-implementable)

| SPI | Purpose |
|---|---|
| `VertxConfigurator` | Customize `VertxBuilder` at startup |
| `VerticleStartup` | Register custom verticle bootstrap logic |

