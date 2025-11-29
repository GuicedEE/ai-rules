# Lifecycle Integration — GuicedEE Vert.x Web

Startup and shutdown lifecycle of GuicedEE Vert.x Web, including SPI configurator discovery and application ordering.

## Startup Sequence

When `VertxWebServerPostStartup` (an `IGuicePostStartup` provider) executes:

```
1. Read environment variables (HTTP_ENABLED, HTTPS_ENABLED, etc.)
2. Create HttpServerOptions
3. Apply VertxHttpServerOptionsConfigurator chain
4. Create HTTP/HTTPS servers
5. Apply VertxHttpServerConfigurator chain
6. Create and configure Router
7. Apply VertxRouterConfigurator chain
8. Attach Router to servers
9. Start listening on configured ports
```

## SPI Configurator Discovery

Implementations are discovered via `ServiceLoader` in **undefined order**:

```java
// Options configurators
ServiceLoader<VertxHttpServerOptionsConfigurator> opts = ServiceLoader.load(...);
for (var cfg : opts) {
    options = IGuiceContext.get(cfg.getClass()).builder(options);
}

// Server configurators
ServiceLoader<VertxHttpServerConfigurator> servers = ServiceLoader.load(...);
for (var cfg : servers) {
    server = IGuiceContext.get(cfg.getClass()).builder(server);
}

// Router configurators
ServiceLoader<VertxRouterConfigurator> routers = ServiceLoader.load(...);
for (var cfg : routers) {
    router = IGuiceContext.get(cfg.getClass()).builder(router);
}
```

## Dependency Injection in Configurators

Configurators are instantiated via GuiceEE's injector:

```java
public class ApiRoutesConfigurator implements VertxRouterConfigurator
{
    @Inject
    private UserService userService;  // Injected by GuiceEE

    @Override
    public Router builder(Router router)
    {
        router.get("/api/users").handler(ctx -> {
            List<User> users = userService.getAll();
            ctx.response().end(Json.encode(users));
        });
        return router;
    }
}
```

## Ordering & Idempotency

### Order is Undefined

Do NOT assume execution order across multiple configurators. Design each to be **idempotent**:

```java
// GOOD: Each configurator is independent
public class ApiRoutesConfigurator implements VertxRouterConfigurator {
    @Override
    public Router builder(Router router) {
        router.get("/api/users").handler(...);
        return router;
    }
}

// GOOD: Each configurator is independent
public class AdminRoutesConfigurator implements VertxRouterConfigurator {
    @Override
    public Router builder(Router router) {
        router.get("/api/admin/users").handler(...);
        return router;
    }
}
```

### If Order Matters: Use Composite Pattern

```java
public class CompositeRoutesConfigurator implements VertxRouterConfigurator
{
    @Inject
    private ApiRoutesConfigurator apiRoutes;
    
    @Inject
    private AdminRoutesConfigurator adminRoutes;

    @Override
    public Router builder(Router router)
    {
        // Explicit order
        apiRoutes.builder(router);
        adminRoutes.builder(router);
        return router;
    }
}
```

Register only the composite in `module-info.java`:

```java
provides com.guicedee.vertx.web.spi.VertxRouterConfigurator
    with com.example.web.CompositeRoutesConfigurator;
```

## Reading Environment at Runtime

```java
public class DynamicPortConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Inject
    private Environment env;

    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        int port = env.getInteger("HTTP_PORT", 8080);
        return options.setPort(port);
    }
}
```

## Error Handling During Startup

If a configurator throws an exception, startup fails:

```java
public class ValidatingConfigurator implements VertxRouterConfigurator
{
    @Inject
    private Config config;

    @Override
    public Router builder(Router router)
    {
        if (config.getRequiredSetting() == null) {
            throw new IllegalStateException("Required setting not configured");
        }
        return router;
    }
}
```

**Best practice:** Fail fast with clear error messages.

## Shutdown Sequence

GuiceEE automatically closes Vert.x and all servers during shutdown. No custom cleanup needed.

## Performance Considerations

### Lazy Initialization

```java
public class LazyServiceConfigurator implements VertxRouterConfigurator
{
    @Inject
    private Provider<ExpensiveService> serviceProvider;

    @Override
    public Router builder(Router router)
    {
        router.get("/expensive").handler(ctx -> {
            ExpensiveService service = serviceProvider.get();  // Initialize on first use
            service.process();
        });
        return router;
    }
}
```

### Startup Blocking

All configurators run **synchronously**. Keep them fast; defer time-consuming work to first request or background tasks.

## See Also

- [spi-configurators.rules.md](spi-configurators.rules.md) — SPI interface contracts
- [module-info.rules.md](module-info.rules.md) — JPMS module discovery
- [server-configuration.rules.md](server-configuration.rules.md) — HTTP/HTTPS setup
