# Services & SPI Registration — Cerial

Purpose
- Ensure Cerial providers are discoverable via JPMS and classpath service loading.

Registrations
- JPMS provides (module-info.java):
  - `provides com.guicedee.client.services.lifecycle.IGuiceModule with com.guicedee.cerial.implementations.CerialPortsBindings;`
- META-INF/services:
  - `META-INF/services/com.guicedee.client.services.lifecycle.IGuiceModule` → `com.guicedee.cerial.implementations.CerialPortsBindings`
- If additional lifecycle/SPIs are introduced (e.g., idle monitor hooks), register them in both module-info and META-INF/services.

Guidelines
- Keep providers singleton-safe; validate defaults in providers before injection.
- Align JPMS exports with the API and implementation packages needed by consumers and SPI loaders.
- Tests should load providers without JPMS by leveraging the META-INF/services entries.

See also
- Lifecycle rules — ../rules/lifecycle.md
- Topic index — ../README.md
