# Lifecycle & Injection Rules — Cerial

Purpose
- Describe Guice/JPMS wiring for the Cerial module so port connections are discoverable and correctly scoped.

Requirements
- Module wiring: `CerialPortsBindings` implements `IGuiceModule` and registers each `CerialPortConnection` with `Names.named("<portNumber>")`. Keep bindings deterministic and singletons.
- Provider: `CerialPortConnectionProvider` constructs/configures instances before injection; ensure default configuration is applied consistently.
- JPMS/SPI: declare `provides com.guicedee.client.services.lifecycle.IGuiceModule with com.guicedee.cerial.implementations.CerialPortsBindings` in `module-info.java`. Avoid redundant `uses` entries already present in GuicedInjection.
- Dual registration: mirror providers in `META-INF/services/com.guicedee.client.services.lifecycle.IGuiceModule` for classpath/testing scenarios.
- Lifecycle hooks: `CerialPortConnection` implements `IGuicePreDestroy`; keep disconnect idempotent and safe for repeated calls.
- Vert.x access: obtain `Vertx` via `IGuiceContext` for timers and async operations; never block event loops inside bindings/providers.

Checklist
- [ ] `module-info.java` provides entry present
- [ ] `META-INF/services` file present for `IGuiceModule`
- [ ] Bindings use `Names.named` and scope singletons
- [ ] Provider applies defaults and validates configuration

See also
- API rules — ./api.md
- Idle monitoring — ./idle-monitoring.md
- Services registration — ../services/services.md
