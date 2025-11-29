# GuicedEE Cerial — Topic Index

Scope
- Serial port connectivity library (`com.guicedee.cerial`) that integrates GuicedInjection, Vert.x timers, and CRTP-fluent configuration for jSerialComm ports. This topic documents API usage, SPI contracts, data listeners, idle monitoring, nullness/logging, and CI/env expectations.

Quick links
- Parent topic — ../README.md
- Glossary — ./GLOSSARY.md
- Rules — ./rules/api.md, ./rules/lifecycle.md, ./rules/data-listeners.md, ./rules/idle-monitoring.md, ./rules/nullness-logging.md
- Examples — ./examples/examples.md
- Services & SPI Registration — ./services/services.md

Project details
- Artifact coordinates (Maven): `com.guicedee:guiced-cerial`
- JPMS module name: `com.guicedee.cerial`
- Repository path: /mnt/c/Java/DevSuite/GuicedEE/cerial
- Host docs (project root):
  - PACT — ../../../../PACT.md
  - RULES — ../../../../RULES.md
  - GUIDES — ../../../../GUIDES.md
  - IMPLEMENTATION — ../../../../IMPLEMENTATION.md
  - GLOSSARY — ../../../../GLOSSARY.md

Ecosystem cross-references
- GuicedEE Core & Client — ../README.md, ../client/README.md
- Vert.x 5 — ../../vertx/README.md
- Fluent API (CRTP) — ../fluent-api/README.md
- JSpecify — ../../jspecify/README.md
- Logging — ../logging/README.md
- CI/CD — ../../platform/ci-cd/providers/github-actions.md
- Env/secrets — ../../platform/secrets-config/env-variables.md

Expectations
- CRTP fluent API only; do not mix builder patterns on the same surface.
- Nullness follows JSpecify; treat unannotated values as non-null unless marked otherwise.
- Vert.x callbacks/listeners must stay non-blocking; avoid event-loop blocking in idle monitors and data handlers.
- Dual registration of SPIs (JPMS provides + META-INF/services) is required for discoverability and tests.

Modules and SPI (high-level)
- Module name: `com.guicedee.cerial`
- Key SPIs:
  - `com.guicedee.client.services.lifecycle.IGuiceModule` (CerialPortsBindings)
  - `com.guicedee.client.services.lifecycle.IGuicePreDestroy` (implemented by `CerialPortConnection`)
  - `com.guicedee.client.services.ICleanable` / lifecycle hooks as applicable for port teardown
  - `io.vertx.core.Vertx` obtained via `IGuiceContext` for timers/idle monitoring
  - Event/callback surface via `ComPortEvents` including `onConnectError`, `onComPortStatusUpdate`, and comPortRead/comPortWrite callbacks

Services registration
- Register providers in BOTH `META-INF/services` and `module-info.java` (`provides ... with ...`) to ensure JPMS and classpath users can discover Cerial bindings and listeners.
