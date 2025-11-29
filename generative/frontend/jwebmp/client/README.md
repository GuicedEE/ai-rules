# JWebMP Client — Topic Index

Scope
- Guidance for consumers of the JWebMP Client library (frontend-facing service/framework layer) to model components, render pages, and handle AJAX flows.

Quick links
- Parent topic — ../README.md
- GuicedEE platform — ../../backend/guicedee/README.md
- GuicedEE Client — ../../backend/guicedee/client/README.md
- Vert.x 5 bridge — ../../backend/guicedee/vertx/README.md
- Fluent API (CRTP) — ../../backend/fluent-api/README.md
- Java 25 LTS — ../../language/java/java-25.rules.md
- Logging defaults (Log4j2) — ../../backend/guicedee/README.md#logging
- Nullness (JSpecify) — ../../backend/jspecify/README.md

Modules
- Configuration & JPMS — configuration.rules.md
- Interception & AJAX pipeline — ajax-interception.rules.md
- Rendering & component model — rendering.rules.md
- Reactive integration (Vert.x 5 + Mutiny) — reactive-vertx.rules.md
- Logging defaults — logging.rules.md
- Nullness guidance — nullness-jspecify.rules.md
- Examples — examples/examples.md
- Glossary — GLOSSARY.md

Expectations
- CRTP fluent APIs only; avoid builder patterns in component surfaces.
- Use the provided binders/interceptors via ServiceLoader; avoid global state.
- Prefer Mutiny for reactive flows; avoid blocking on event-loop threads.
- Apply JSpecify annotations when extending or integrating with the API; treat unannotated params as non-null unless stated otherwise.
