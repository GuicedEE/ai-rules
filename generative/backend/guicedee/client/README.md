# GuicedEE Inject Client — Topic Index

Scope
- This topic covers the GuicedEE Inject Client — the client library for GuicedEE Core. It documents usage rules, SPI contracts, nullness guidance (JSpecify), and reactive patterns (Mutiny) expected for consumers and extensions.

Quick links
- Parent topic — ../README.md
- Glossary — ./GLOSSARY.md
- Nullness & Reactive Rules — ./rules/nullness-reactive.md
 - Examples — ./examples/examples.md
 - Services & SPI Registration — ./services/services.md

Project details
- Artifact coordinates (Maven): com.guicedee:guice-inject-client:2.0.0-SNAPSHOT
- JPMS module name: com.guicedee.client
- Repository path: C:/Java/DevSuite/GuicedEE/client
- Host docs (project root):
  - PACT — ../../../../PACT.md
  - RULES — ../../../../RULES.md
  - GUIDES — ../../../../GUIDES.md
  - IMPLEMENTATION — ../../../../IMPLEMENTATION.md
  - GLOSSARY — ../../../../GLOSSARY.md

Ecosystem cross‑references
- JSpecify — ../../jspecify/README.md
- Vert.x 5 — ../../vertx/README.md

Expectations
- Fluent APIs follow CRTP; do not mix with builder pattern in the same API surface.
- Nullness annotations come from org.jspecify:jspecify. Treat unannotated parameters as non-null by default unless the rules specify otherwise.
- Reactive return types should use Mutiny (io.smallrye.mutiny.Uni/Multi) for asynchronous flows. Avoid blocking operations on event loops.

Modules and SPI (high‑level)
- Module name: com.guicedee.client (client library)
- Key SPIs (examples):
  - com.guicedee.client.services.lifecycle.IGuicePreStartup
  - com.guicedee.client.services.lifecycle.IGuicePostStartup
  - com.guicedee.client.services.lifecycle.IGuicePreDestroy
  - com.guicedee.client.services.lifecycle.IGuiceModule
  - com.guicedee.client.services.lifecycle.IGuiceConfigurator
  - com.guicedee.client.services.lifecycle.IOnCallScopeEnter
  - com.guicedee.client.services.lifecycle.IOnCallScopeExit
  - com.guicedee.client.services.websocket.IWebSocketMessageReceiver
  - com.guicedee.client.services.websocket.IGuicedWebSocket
  - com.guicedee.client.services.websocket.IWebSocketAuthDataProvider
  - com.guicedee.client.services.websocket.IWebSocketPreConfiguration

Services registration
- Mandatory dual registration: declare providers in BOTH META-INF/services and via JPMS provides clauses in module-info.java (required for tests and when modules/automatic modules are on the path).
- See Services & SPI Registration for filenames, JPMS snippets, and coordinates.
