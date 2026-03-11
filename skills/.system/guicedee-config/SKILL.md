---
name: guicedee-config
description: "MicroProfile Config implementation for GuicedEE using SmallRye Config and Guice: @ConfigProperty injection with type conversion, environment variable / system property / microprofile-config.properties sources, profile support, custom converters, programmatic SmallRyeConfig access, and JPMS setup. Use when injecting configuration values, managing config sources, adding custom converters, or using profile-specific properties."
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
| Environment variables | 300 (highest) | `MESSAGING_ENABLED=true` |
| System properties | 200 | `-Dmessaging.enabled=true` |
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

Activate with `mp.config.profile=dev`.

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

## Non-Negotiable Constraints

- Module must `requires com.guicedee.microprofile.config;`.
- Classes with `@ConfigProperty` fields must be in packages opened to `com.google.guice`.
- The config module is registered automatically — no `provides` needed.
- Config is built on a Vert.x worker thread to avoid blocking the event loop.



