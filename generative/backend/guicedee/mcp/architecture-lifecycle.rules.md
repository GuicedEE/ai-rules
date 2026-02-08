# Architecture and Lifecycle Rules - GuicedEE MCP Server

Purpose: define the runtime architecture and lifecycle mapping for a production MCP server built with GuicedEE on Vert.x 5.

## Runtime composition
- Keep a clear split between protocol, domain logic, and transport:
  - Protocol layer: JSON-RPC parsing, handshake state, capability routing, error mapping.
  - Capability layer: tool/resource/prompt/completion registries and handlers.
  - Transport layer: stdio adapter and Streamable HTTP adapter.
  - Platform layer: authn/authz, observability, rate limiting, and deployment guards.
- Route all handlers through DI-managed services; avoid static singletons except tightly scoped bootstrap accessors.

## Implementation policy (library-first)
- Prefer concrete library contracts from GuicedEE, Vert.x, and MCP SDK/runtime before introducing local abstraction layers.
- Do not scaffold interface-only protocol or transport wrappers when equivalent library classes/contracts already exist.
- Introduce local interfaces only for missing extension points or explicit product boundaries, and document the reason in code/docs.

## GuicedEE lifecycle mapping
- `IGuicePreStartup`:
  - Load and validate environment configuration.
  - Build Vert.x instance and shared worker pools.
  - Initialize registries for tools/resources/prompts before accepting requests.
- `IGuicePostStartup`:
  - Start enabled transports (`stdio`, `http`, or both).
  - Publish readiness state only after transport listeners are active.
- `IGuicePreDestroy`:
  - Stop accepting new requests.
  - Drain in-flight requests with timeout budgets.
  - Close SSE streams, HTTP listeners, worker pools, and Vert.x cleanly.

## Deployment topology
- Preferred topology for `mcp.guicedee.com`:
  - Edge: TLS termination + request filtering.
  - App tier: Vert.x Streamable HTTP server.
  - Optional local mode: stdio launch profile for development and CI.
- Keep capability registries in-process. External backing stores are optional and must not weaken tenant boundaries.

## Concurrency and blocking policy
- Never block Vert.x event-loop threads.
- Use worker executors or virtual threads for blocking IO and legacy integrations.
- Attach request deadlines and cancellation hooks to tool/resource execution paths.
- Bound parallelism per tenant and per method to avoid noisy-neighbor starvation.

## Failure and recovery
- Fail fast on invalid startup config; do not run partially initialized transports.
- Return protocol-compliant JSON-RPC errors for caller faults.
- Surface transient backend failures as retry-safe errors with structured metadata.
- Keep startup and shutdown idempotent across container restarts.

## Versioning policy
- Pin the default protocol target to `2025-11-25`.
- Keep compatibility adapters isolated by negotiated protocol revision.
- Do not silently downgrade behavior; log the negotiated revision for each session/request.

See also: `./protocol-baseline.rules.md`, `./transport-streamable-http.rules.md`, `./testing-conformance.rules.md`.
