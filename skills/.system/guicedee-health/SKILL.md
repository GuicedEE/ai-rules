---
name: guicedee-health
description: "MicroProfile Health integration for GuicedEE with Vert.x 5: @Liveness, @Readiness, @Startup annotations, automatic health check discovery via ClassGraph, JSON health endpoints (/health, /health/live, /health/ready, /health/started), @HealthOptions configuration, environment variable overrides, and Guice-managed check instances. Use when adding health checks, configuring health endpoints, or implementing liveness/readiness probes."
metadata:
  short-description: MicroProfile Health checks with auto-discovery inside GuicedEE
---

# GuicedEE Health

Seamless MicroProfile Health integration for GuicedEE using Vert.x 5 Health Checks.

## Core Concept

Annotate your classes with standard `@Liveness`, `@Readiness`, and `@Startup` — health checks are discovered at startup via ClassGraph, registered with Vert.x `HealthChecks`, and exposed as JSON endpoints on the Vert.x Web `Router` automatically.

## Required Flow

1. Add `com.guicedee:health` dependency (pulls in `web` transitively).
2. Implement a health check:
   ```java
   @Liveness
   public class DatabaseLiveness implements HealthCheck {
       @Override
       public HealthCheckResponse call() {
           return HealthCheckResponse.named("DatabaseLiveness")
                   .up()
                   .withData("connection", "stable")
                   .build();
       }
   }
   ```
3. Configure `module-info.java`:
   ```java
   module my.app {
       requires com.guicedee.health;
   }
   ```
4. Bootstrap GuicedEE — health endpoints are registered automatically:
   ```java
   IGuiceContext.registerModuleForScanning.add("my.app");
   IGuiceContext.instance().inject();
   // GET /health        → aggregated status
   // GET /health/live   → liveness checks only
   // GET /health/ready  → readiness checks only
   // GET /health/started → startup checks only
   ```

No JPMS `provides` declaration is needed for health check classes — they are discovered via classpath scanning.

## Health Check Types

### `@Liveness`
Application is running correctly. Failing → restart the application.

### `@Readiness`
Application is ready for traffic. Failing → remove from load balancer temporarily.

### `@Startup`
Application has finished initialization. Prevents liveness probes during long startups.

### Multiple annotations
A check can carry multiple annotations — registered with each corresponding endpoint:

```java
@Liveness
@Readiness
public class CriticalServiceCheck implements HealthCheck { ... }
```

## Configuration

### `@HealthOptions` annotation
Place on any class or package to customize endpoint paths:

```java
@HealthOptions(
    enabled = true,
    path = "/health",
    livenessPath = "/health/live",
    readinessPath = "/health/ready",
    startupPath = "/health/started"
)
public class MyAppConfig {}
```

### Environment variable overrides
`HEALTH_ENABLED`, `HEALTH_PATH`, `HEALTH_LIVENESS_PATH`, `HEALTH_READINESS_PATH`, `HEALTH_STARTUP_PATH`

## Startup Flow

```
IGuiceContext.instance().inject()
 └─ HealthPreStartup (scans for HealthCheck implementations)
 └─ HealthModule (binds HealthChecks instances)
 └─ HealthPreStartup.postLoad() (registers checks with Vert.x)
 └─ HealthRouterConfigurator (mounts endpoints on Router)
```

## Non-Negotiable Constraints

- Module must `requires com.guicedee.health;`.
- Health check classes are discovered via classpath scanning — no `provides` needed.
- `@Inject` works inside health checks (Guice-managed).
- Each check has a 2-second timeout to prevent hanging endpoints.


