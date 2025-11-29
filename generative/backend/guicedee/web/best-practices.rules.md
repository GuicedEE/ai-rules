# Troubleshooting & Best Practices — GuicedEE Vert.x Web

## Best Practices

1. **Use SPI Interfaces for Extension** — Extend via `VertxRouterConfigurator`, not by modifying core code
2. **Organize Routes by Functionality** — Separate configurators per domain (Users, Products, Admin)
3. **Use Dependency Injection** — Inject services into configurators via `@Inject`
4. **Handle Errors Properly** — Validate input and return meaningful error responses
5. **Use Asynchronous APIs** — Avoid blocking calls; use Futures/Promises
6. **Configure SSL/TLS Securely** — Use environment secrets, not hardcoded passwords
7. **Validate and Sanitize Input** — Check all user input before processing
8. **Set Proper Content-Type Headers** — Always specify response content-type
9. **Implement CORS When Needed** — Use `CorsHandler` for cross-origin requests
10. **Monitor Performance** — Enable metrics and logging via `VertxHttpServerOptionsConfigurator`

## Troubleshooting

### Server Won't Start

**Symptoms:** Application hangs or exits immediately.

**Causes:**
- Specified ports already in use
- Missing environment variables for HTTPS
- Configuration error in a configurator

**Solution:**
```bash
# Check port availability
netstat -an | grep 8080

# Try different port
export HTTP_PORT=8081

# Check logs for errors
```

### SSL/TLS Configuration Errors

**Symptoms:** "Cannot load keystore" or certificate errors.

**Causes:**
- Keystore file doesn't exist
- Wrong password
- File extension doesn't match type

**Solution:**
```bash
# Test keystore
keytool -list -v -keystore /path/to/keystore.jks

# Create test keystore
keytool -genkey -keyalg RSA -keystore keystore.jks -storepass changeit
```

### Route Not Matching

**Symptoms:** 404 for routes you think should exist.

**Causes:**
- Incorrect path pattern
- HTTP method mismatch
- Route registered in wrong order

**Solution:**
```java
// Debug: List all routes
router.getRoutes().forEach(route -> {
    System.out.println("Route: " + route.getPath());
});

// Check path syntax (use : not {})
router.get("/api/users/:id")  // Correct
```

### Request Body Not Available

**Symptoms:** `ctx.body()` is empty.

**Causes:**
- BodyHandler not configured
- BodyHandler applied after route handler

**Solution:**
```java
// CORRECT: BodyHandler on all routes FIRST
public Router builder(Router router) {
    router.route().handler(BodyHandler.create());
    router.post("/api/users").handler(ctx -> {
        User user = ctx.body().asPojo(User.class);
        // ...
    });
    return router;
}
```

### CORS Errors

**Symptoms:** Browser blocks cross-origin requests.

**Causes:**
- No CORS handler registered
- CORS handler configured for wrong origins

**Solution:**
```java
public class CorsConfigurator implements VertxRouterConfigurator {
    @Override
    public Router builder(Router router) {
        router.route().handler(CorsHandler.create("*")
            .allowedMethods(EnumSet.of(
                HttpMethod.GET, HttpMethod.POST, HttpMethod.PUT, HttpMethod.DELETE
            ))
            .allowedHeader("*"));
        return router;
    }
}
```

### Dependency Injection Not Working

**Symptoms:** `@Inject` fields are null.

**Causes:**
- Configurator not registered in `module-info.java`
- Service not available in GuiceEE context

**Solution:**
```java
// Verify module-info.java has provides entry
provides com.guicedee.vertx.web.spi.VertxRouterConfigurator
    with com.example.web.MyConfigurator;
```

## Debugging Tips

### Enable Debug Logging

```properties
log4j.logger.io.vertx=DEBUG
log4j.logger.com.guicedee=DEBUG
```

### Request/Response Logging

```java
router.route().handler(ctx -> {
    System.out.println("Request: " + ctx.request().method() + " " + ctx.request().path());
    ctx.addEndHandler(v -> {
        System.out.println("Response: " + ctx.response().getStatusCode());
    });
    ctx.next();
});
```

### Enable Vert.x Activity Logging

```java
public class DebugConfigurator implements VertxHttpServerOptionsConfigurator {
    @Override
    public HttpServerOptions builder(HttpServerOptions options) {
        return options.setLogActivity(true);
    }
}
```

## See Also

- [spi-configurators.rules.md](spi-configurators.rules.md) — SPI interfaces
- [router-configuration.rules.md](router-configuration.rules.md) — Routing patterns
- [server-configuration.rules.md](server-configuration.rules.md) — Server setup
- [lifecycle.rules.md](lifecycle.rules.md) — Startup sequence
