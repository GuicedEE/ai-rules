# Server & Options Configuration — GuicedEE Vert.x Web

This module covers HTTP/HTTPS server creation, environment-based configuration, and SSL/TLS setup.

## Environment Variables

GuicedEE Vert.x Web reads these environment variables (or system properties) at startup:

| Variable | Default | Purpose |
|----------|---------|---------|
| `HTTP_ENABLED` | `true` | Create HTTP server listening on `HTTP_PORT` |
| `HTTP_PORT` | `8080` | HTTP server listen port |
| `HTTPS_ENABLED` | `false` | Create HTTPS server listening on `HTTPS_PORT` |
| `HTTPS_PORT` | `8443` | HTTPS server listen port |
| `HTTPS_KEYSTORE` | (none) | Path to JKS/PFX/P12 keystore file (file extension determines type) |
| `HTTPS_KEYSTORE_PASSWORD` | (none) | Keystore password (do NOT commit; use GitHub Actions secrets) |

**Example `.env` file:**

```dotenv
HTTP_ENABLED=true
HTTP_PORT=8080
HTTPS_ENABLED=true
HTTPS_PORT=8443
HTTPS_KEYSTORE=./certs/keystore.jks
HTTPS_KEYSTORE_PASSWORD=changeit
```

## Default Configuration

By default (no custom configurators), HTTP/HTTPS servers are created with:

- **Compression:** Enabled at level 9
- **TCP:** Keep-alive enabled, no-delay enabled
- **Header size:** Max 65536 bytes
- **Chunk size:** Max 65536 bytes
- **Form attribute size:** Max 65536 bytes
- **Form fields:** Unlimited (-1)

These can be customized via `VertxHttpServerOptionsConfigurator`.

## SSL/TLS Configuration

### Supported Keystore Formats

**File extension determines auto-detection:**

- `.jks` → JKS (Java KeyStore)
- `.pfx`, `.p12`, `.p8` → PKCS#12

### JKS Configuration

```java
public class JksSecurityConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Inject
    private Environment env;

    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        String keystorePath = env.get("HTTPS_KEYSTORE");
        String keystorePassword = env.get("HTTPS_KEYSTORE_PASSWORD", "");

        if (keystorePath != null && keystorePath.endsWith(".jks")) {
            options.setSsl(true).setKeyCertOptions(
                new JksOptions()
                    .setPath(keystorePath)
                    .setPassword(keystorePassword)
            );
        }
        return options;
    }
}
```

### PKCS#12 Configuration

```java
public class Pkcs12SecurityConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Inject
    private Environment env;

    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        String keystorePath = env.get("HTTPS_KEYSTORE");
        String keystorePassword = env.get("HTTPS_KEYSTORE_PASSWORD", "");

        if (keystorePath != null && 
            (keystorePath.endsWith(".pfx") || keystorePath.endsWith(".p12"))) {
            options.setSsl(true).setKeyCertOptions(
                new PfxOptions()
                    .setPath(keystorePath)
                    .setPassword(keystorePassword)
            );
        }
        return options;
    }
}
```

## Server Creation Flow

The `VertxWebServerPostStartup` class orchestrates this sequence:

1. **Read environment variables** for port/TLS configuration
2. **Create HttpServerOptions**
3. **Apply all VertxHttpServerOptionsConfigurator implementations**
4. **Create HTTP and/or HTTPS server instances** based on `HTTP_ENABLED` / `HTTPS_ENABLED`
5. **Apply all VertxHttpServerConfigurator implementations** to each server
6. **Create and attach Router** (see router-configuration.rules.md)
7. **Start listening** on configured ports

## Custom Server Configuration Examples

### Enable Metrics & Logging

```java
public class MonitoringOptionsConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        return options
            .setMetricsEnabled(true)
            .setLogActivity(true)
            .setActivityLogDataFormat(HttpServerOptions.ACTIVITY_LOG_FORMAT_BYTES);
    }
}
```

### Tune Timeouts & Connection Limits

```java
public class PerformanceOptionsConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        return options
            .setIdleTimeout(60)
            .setIdleTimeoutUnit(TimeUnit.SECONDS)
            .setMaxInitialLineLength(8192)
            .setMaxHeaderSize(32768)
            .setMaxChunkSize(32768)
            .setMaxFormAttributeSize(32768)
            .setMaxFormFields(100);
    }
}
```

### Add Security Headers in Server Handler

```java
public class SecurityHeadersConfigurator implements VertxHttpServerConfigurator
{
    @Override
    public HttpServer builder(HttpServer server)
    {
        server.requestHandler(req -> {
            req.response()
               .putHeader("X-Content-Type-Options", "nosniff")
               .putHeader("X-Frame-Options", "DENY")
               .putHeader("X-XSS-Protection", "1; mode=block");
        });
        return server;
    }
}
```

## Binding to Specific Addresses

By default, servers bind to `0.0.0.0` (all interfaces). To bind to a specific address:

```java
public class SpecificAddressConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        return options.setHost("127.0.0.1"); // Localhost only
    }
}
```

## Protocol & Compression Configuration

### Enable/Disable Compression

```java
public class CompressionConfigurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        return options
            .setCompressionSupported(true)
            .setCompressionLevel(5); // 1-9
    }
}
```

### HTTP/2 Support (if Vert.x 5+ supports it)

```java
public class Http2Configurator implements VertxHttpServerOptionsConfigurator
{
    @Override
    public HttpServerOptions builder(HttpServerOptions options)
    {
        // Check Vert.x 5 API for HTTP/2 method names
        // Example (adjust to actual API):
        return options.setUseAlpn(true);
    }
}
```

## Secrets & Environment Best Practices

1. **Never commit secrets** — `HTTPS_KEYSTORE_PASSWORD` should NOT be in version control.
2. **Use GitHub Actions secrets** — Define `HTTPS_KEYSTORE_PASSWORD` as a repository secret.
3. **Load via `.env` or environment** — `VertxWebServerPostStartup` reads from `System.getProperty()` or `System.getenv()`.
4. **Document in `.env.example`** — Show the structure without actual secrets.

**Example GitHub Actions workflow:**

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set environment variables
        run: |
          echo "HTTPS_KEYSTORE_PASSWORD=${{ secrets.HTTPS_KEYSTORE_PASSWORD }}" >> $GITHUB_ENV
      - run: mvn -B verify
```

## See Also

- [spi-configurators.rules.md](spi-configurators.rules.md) — How to extend via VertxHttpServerOptionsConfigurator
- [router-configuration.rules.md](router-configuration.rules.md) — Router & BodyHandler setup
- [lifecycle.rules.md](lifecycle.rules.md) — Startup sequence
- [GLOSSARY.md](GLOSSARY.md) — Terminology (HTTP_ENABLED, HTTPS_KEYSTORE, etc.)
- `rules/generative/platform/secrets-config/env-variables.md` — Enterprise env variable patterns
