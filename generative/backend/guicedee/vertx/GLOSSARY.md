# GLOSSARY — Guiced Vert.x Bridge (Topic-First)

Use these canonical terms for GuicedEE ↔ Vert.x integration. Host projects should link here and only copy enforced prompt-alignment names.

- **VertxEventDefinition / VertxEventOptions**: Annotations describing event bus addresses and delivery options discovered during pre-startup scans. Use to bind both consumers and publishers.
- **VertxEventRegistry**: Registry that collects annotated definitions, generates type keys, and feeds Guice bindings plus codec registration.
- **VertxEventPublisher<T>**: Generic CRTP-style publisher wrapper injected by `@Named(address)`; supports `publish` and `send` with delivery options.
- **VertXPreStartup**: GuicedEE lifecycle hook that boots Vert.x, applies configurators, scans annotations, registers codecs, and installs `VertXModule`.
- **VertXPostStartup**: Lifecycle hook that deploys verticles, runs configurators, and sets the static `VertX` accessor for late callers.
- **VertXModule**: Guice PrivateModule exposing the Vert.x singleton, consumer bindings, and publisher factories keyed by registry metadata.
- **CodecRegistry / DynamicCodec**: Utilities to create/register codecs per payload type while preventing duplicate codec names.
- **VertxConfigurator**: SPI entrypoints (address resolver, event bus, metrics, file system) that tune Vert.x options before startup completes.
- **VerticleStartup / VerticleBuilder**: SPI to construct and deploy verticles after the injector is ready; honors CRTP fluent configuration.
- **VertX static accessor**: Singleton holder for the Vert.x instance set during post-startup; use sparingly and prefer DI.

LLM interpretation guidance
- Default to CRTP chaining for fluent APIs; do not introduce Builder semantics.
- Assume Vert.x 5 API surface; avoid Vert.x 4 terminology unless documenting compatibility.
- Treat registry and codec naming as deterministic; avoid generating random identifiers.
