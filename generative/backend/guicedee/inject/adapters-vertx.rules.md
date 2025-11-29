# Adapters — Vert.x (Optional) — GuicedEE Inject

Scope
- Guidance for using the GuicedEE Vert.x adapter with GuicedEE Inject while keeping the core library independent of Vert.x.

Rules
- Optional dependency: include Vert.x adapter artifacts only when hosting reactive services; core Inject must not require Vert.x at compile time.
- Module separation: keep Vert.x modules/binders in adapter packages; do not register Vert.x types in core scanners by default.
- Event loops vs blocking: avoid blocking operations on Vert.x event-loop threads; use worker executors or virtual threads for blocking flows.
- Context propagation: pass Vert.x Context or request-scoped data explicitly; do not rely on thread-local state when running on event loops.
- Configuration: align adapter configuration with Vert.x 5 rules — rules/generative/backend/vertx/README.md.
- Shutdown: ensure Vert.x adapters close event bus clients and worker pools during PreDestroy hooks; coordinate with job service shutdown to avoid dangling threads.

Examples plan
- Provide host-side examples that show: adding adapter coordinates, registering adapter binders via SPI, and wiring Vert.x event bus producers/consumers via Guice.
- Reference architecture diagrams for optional adapters: docs/architecture/c4-container.md, docs/architecture/c4-component-inject.md.
