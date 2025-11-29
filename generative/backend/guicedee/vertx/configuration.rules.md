# Configuration & SPIs

Configure Vert.x through SPI hooks instead of ad-hoc code. Keep settings in env/system properties per secrets-config guidance.

- Configurators:
  - Implement `VertxConfigurator` (or specialized types) to adjust address resolver, event bus, metrics, or file system options before Vert.x boots.
  - Register configurators via SPI so `VertXPreStartup` can apply them deterministically.
- Options classes:
  - `AddressResolverOptions`, `EventBusOptions`, `MetricsOptions`, `FileSystemOptions` live under `com.guicedee.vertx.spi`.
  - Set only required fields; prefer sane defaults from Vert.x 5.
- Environment:
  - Read from env vars or system properties; never embed secrets. Follow `rules/generative/platform/secrets-config/env-variables.md`.
  - Document required variables in README/IMPLEMENTATION.md.
- Post-startup adjustments:
  - Use `VertXPostStartup` hooks for configurators that need DI or must run after verticle deployment.
  - Avoid mutating options after event bus is active unless Vert.x explicitly allows it.
- Metrics/logging:
  - Align metrics exporters with platform guidance; ensure logging categories are deterministic and avoid payload dumps.
- Compatibility:
  - Stay on Vert.x 5 APIs; flag any Vert.x 4 usage as legacy in guides.

See also: ./lifecycle.rules.md, ./verticles.rules.md, generative/platform/observability/README.md (if metrics exporters are added).
