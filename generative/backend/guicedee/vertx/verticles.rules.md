# Verticles & Deployment

Deploy verticles through the provided SPI to keep lifecycle deterministic and compatible with GuicedEE injection.

- Use `VerticleStartup` to declare verticles to deploy; construct instances via `VerticleBuilder` so dependencies are injected before deployment.
- Deployment timing: happens in `VertXPostStartup` after Guice bindings and codec registration are complete.
- Keep verticles lightweight; offload heavy initialization to async start hooks inside the verticle.
- If clustering is required, ensure event bus options are configured via `VertxConfigurator` before startup; avoid modifying clustering at runtime.
- Apply CRTP on builder-style helpers and keep Vert.x futures as return types (Vert.x 5 APIs).
- Handle deployment futures: log failures with addresses/IDs and short context; avoid swallowing errors.
- Align verticle names/addresses with `@VertxEventDefinition` addresses when they operate together to reduce routing confusion.

See also: ./configuration.rules.md, ./lifecycle.rules.md, docs/architecture/sequence-startup.md.
