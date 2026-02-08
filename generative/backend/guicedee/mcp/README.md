# GuicedEE MCP Server (Vert.x 5) - Rules Index

Use this topic to build a production MCP server with GuicedEE and Vert.x 5.
Primary hosted endpoint: `https://mcp.guicedee.com/mcp`.

This ruleset targets MCP protocol revision `2025-11-25` by default. If a client negotiates another revision, gate behavior through explicit compatibility paths and tests.

## Automatic routing and implementation defaults
- When MCP server work is requested, auto-load this topic index and the linked module files in this directory before generating code.
- If runtime skill discovery is incomplete, continue by loading these files directly; do not fall back to unguided/direct implementation.
- Implementation is library-first:
  - use concrete GuicedEE, Vert.x, and MCP library APIs/SPI contracts first,
  - avoid creating local abstraction interfaces that duplicate existing library contracts.
- Create new interfaces only when a required extension point is missing in selected libraries or when explicitly requested.

## Selected stacks and policies
- Java 25 LTS: `../../../language/java/java-25.rules.md`
- GuicedEE lifecycle and DI: `../README.md`, `../inject/README.md`
- Vert.x runtime and web server: `../../vertx/README.md`, `../vertx/README.md`, `../web/README.md`
- Security and secrets: `../../../platform/security-auth/README.md`, `../../../platform/secrets-config/env-variables.md`
- Observability and testing: `../../../platform/observability/README.md`, `../../../platform/testing/README.md`
- Document modularity and forward-only updates: `../../../../RULES.md#document-modularity-policy`, `../../../../RULES.md#6-forward-only-change-policy-no-backwards-compatibility`

## Topic modules
- Architecture and GuicedEE lifecycle: `./architecture-lifecycle.rules.md`
- Protocol baseline and handshake flow: `./protocol-baseline.rules.md`
- Capabilities (tools/resources/prompts/completions): `./capabilities.rules.md`
- Local stdio transport: `./transport-stdio.rules.md`
- Streamable HTTP transport for `mcp.guicedee.com`: `./transport-streamable-http.rules.md`
- Security and tenant isolation: `./security-authz.rules.md`
- Observability and runtime operations: `./observability-operations.rules.md`
- Deployment and release gates: `./deployment.rules.md`
- Testing and conformance: `./testing-conformance.rules.md`
- JPMS module-info and SPI wiring: `./module-info.rules.md`
- Glossary: `./GLOSSARY.md`

## Delivery stages
1. Protocol core: implement `initialize`, `notifications/initialized`, `ping`, and JSON-RPC error handling.
2. Capability surface: expose tools, resources, prompts, and completion with schema-first contracts.
3. Remote transport hardening: deploy Streamable HTTP with auth, origin checks, and rate controls.
4. Production readiness: run conformance suites, load tests, and rollout gates before broad release.

See also:
- GuicedEE topic index: `../README.md`
- Backend category index: `../../README.md`
- Vert.x topic index: `../../vertx/README.md`
