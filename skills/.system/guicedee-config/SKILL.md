---
name: guicedee-config
description: "Inject MicroProfile Config values in GuicedEE with SmallRye, custom sources/converters, profiles, and ConfigProperty."
metadata:
  short-description: MicroProfile Config with SmallRye Config inside GuicedEE
---

# GuicedEE Config

MicroProfile Config implementation for GuicedEE using SmallRye Config and Google Guice.

## Core Concept

Inject configuration values with `@ConfigProperty`, resolve from environment variables, system properties, and `META-INF/microprofile-config.properties` — all wired automatically through SPI discovery and Guice bindings.

## Required Flow

1. Add `com.guicedee.microprofile:config` dependency.
2. Add a `microprofile-config.properties` file:
   ```properties
   # src/main/resources/META-INF/microprofile-config.properties
   messaging.enabled=true
   messaging.bootstrap.servers=localhost:9092
   liveness.port=8081
   ```
3. Inject configuration values:
   ```java
   public class MessagingService {
       @ConfigProperty(name = "messaging.enabled", defaultValue = "true")
       boolean enabled;

       @ConfigProperty(name = "messaging.bootstrap.servers")
       String bootstrapServers;
   }
   ```
4. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.microprofile.config;
       opens my.app.services to com.google.guice;
   }
   ```

## Configuration Sources

| Source | Ordinal | Example |
|---|---|---|
| System properties | 400 | `-Dmessaging.enabled=true` |
| Environment variables | 300 | `MESSAGING_ENABLED=true` |
| `META-INF/microprofile-config.properties` | 100 (lowest) | `messaging.enabled=true` |

### Key mapping
Environment variable names follow MicroProfile Config rules:
- Dots and hyphens → underscores
- Uppercased
- e.g. `messaging.bootstrap.servers` → `MESSAGING_BOOTSTRAP_SERVERS`

### Profiles
SmallRye Config supports profile-specific properties using `%profile.` prefix:

```properties
db.url=jdbc:postgresql://prod-host:5432/mydb
%dev.db.url=jdbc:postgresql://localhost:5432/mydb
```

Activate with `smallrye.config.profile=dev`. Custom sources can override the default ordinals; inspect the resolved `ConfigValue` source when diagnosing precedence.

## Supported Injection Types

| Type | Binding |
|---|---|
| `String` | Direct value |
| `boolean` / `Boolean` | Parsed |
| `int` / `Integer` | Parsed |
| `long` / `Long` | Parsed |
| `double` / `Double` | Parsed |
| `float` / `Float` | Parsed |
| `Optional<T>` | Wrapped optional (all above types) |

Default values via `@ConfigProperty(defaultValue = "...")`.

## Programmatic Access

```java
@Inject
SmallRyeConfig config;

int port = config.getOptionalValue("liveness.port", Integer.class).orElse(8081);
```

## Custom Converters

Register `Converter<T>` implementations via `ServiceLoader` for application-specific types.

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ MicroProfileConfigContext (builds SmallRyeConfig on Vert.x worker thread)
     ├─ addDefaultSources() (env vars, system props, microprofile-config.properties)
     ├─ addDiscoveredSources() (ServiceLoader-discovered ConfigSource SPIs)
     └─ addDiscoveredConverters()
 └─ MicroProfileConfigBinder (scans @ConfigProperty fields, creates Guice bindings)
```

## Configuration diagnostics

`MicroProfileConfigContext` enriches configuration-load failures using `ConfigPropertiesValidator`: inspect the reported resource URL, line, column, malformed Unicode escape, or encoding before editing a different module's configuration. Every dependency can contribute `META-INF/microprofile-config.properties`.

MicroProfile/SmallRye configuration and `com.guicedee.client.Environment` are separate resolution paths. Do not assume a working-directory `.env.local` lookup from `Environment` automatically describes the MicroProfile source list. Use the owning API and inspect its resolved source.

## Module requirements

- Module must `requires com.guicedee.microprofile.config;`.
- Classes with `@ConfigProperty` fields must be in packages opened to `com.google.guice`.
- The config module is registered automatically — no `provides` needed.
- Config is built on a Vert.x worker thread to avoid blocking the event loop.



