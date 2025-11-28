# Glossary — GuicedEE Inject Client

- GuicedEE Core — The foundational DI and lifecycle framework consumed by this client library. Provides startup/shutdown SPI contracts and service bootstrapping.
- Inject Client — The client library that integrates with GuicedEE Core, offering SPIs and helpers for applications and modules.
- JSpecify — org.jspecify:jspecify annotations used to express nullness contracts. Treat parameters/results as non-null by default unless annotated @Nullable. Use @NullMarked at package level where feasible.
- Mutiny — io.smallrye.reactive:mutiny reactive types: Uni (single async item) and Multi (stream of async items). Prefer non-blocking composition; avoid blocking on event loops.
- CRTP — Curiously Recurring Template Pattern. The standard for fluent APIs in GuicedEE. Do not mix with builder for the same API surface.
- SPI — Service Provider Interface. Notable SPIs (client library):
  - Lifecycle: IGuicePreStartup, IGuicePostStartup, IGuicePreDestroy, IGuiceModule, IGuiceConfigurator, IOnCallScopeEnter, IOnCallScopeExit.
  - WebSocket: IWebSocketMessageReceiver, IGuicedWebSocket, IWebSocketAuthDataProvider, IWebSocketPreConfiguration, GuicedWebSocketOnAddToGroup, GuicedWebSocketOnRemoveFromGroup, GuicedWebSocketOnPublish.

Cross-links to host project glossary
- Project glossary (source of truth for terms used in this repository): ../../../../GLOSSARY.md
