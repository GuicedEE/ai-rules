# Streamable HTTP Transport Rules - mcp.guicedee.com

Purpose: run the internet-facing MCP endpoint at `https://mcp.guicedee.com/mcp` using Vert.x 5.

## Endpoint and methods
- Expose MCP on `/mcp`.
- Support transport methods per Streamable HTTP:
  - `POST /mcp` for client-to-server JSON-RPC messages,
  - `GET /mcp` for optional SSE server-to-client streams,
  - `DELETE /mcp` for session termination when stateful mode is enabled.

## Handler implementation defaults
- Implement HTTP routing with concrete Vert.x web router/handler APIs and GuicedEE SPI wiring.
- Do not introduce interface-only transport facades when native Vert.x/GuicedEE contracts already fit.

## Content negotiation and response modes
- Accept `application/json` request bodies for `POST`.
- For responses, support:
  - `application/json` for immediate request responses,
  - `text/event-stream` for streamed responses and server-initiated messages.
- For accepted notifications with no body result, return `202 Accepted`.

## Session management
- Support `Mcp-Session-Id` for stateful session continuity.
- If stateful mode is enabled:
  - create session id during `initialize`,
  - return it as `Mcp-Session-Id`,
  - require it for subsequent session-bound requests,
  - release server state on `DELETE`.
- If stateless mode is enabled, disable session id requirements and keep handlers idempotent.
- Header names are case-insensitive; accept common variants such as `MCP-Session-Id`.

## Connection and stream behavior
- Keep SSE streams heartbeating to avoid idle proxy disconnects.
- Bound stream lifetimes and max concurrent streams per tenant.
- Handle client disconnects as cancellation signals for stream-bound work.

## Reverse proxy and edge compatibility
- Preserve `Authorization`, `Mcp-Session-Id`, and tracing headers through the edge.
- Configure upstream read/write timeouts to support long-running tool calls without premature termination.
- Enforce HTTPS only; redirect plaintext traffic to TLS entrypoints.

## Compliance constraints
- Do not mix protocol payloads with human-readable text in the same response body.
- Keep request routing deterministic regardless of load-balancer instance.
- Ensure protocol behavior remains identical across single-node and multi-node deployments.

See also: `./security-authz.rules.md`, `./deployment.rules.md`, `./testing-conformance.rules.md`.
