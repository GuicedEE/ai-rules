# Testing and Conformance Rules - GuicedEE MCP Server

Purpose: define the minimum verification bar for protocol correctness and production safety.

## Protocol conformance tests
- Validate handshake flow:
  - `initialize` success and negotiated revision,
  - `notifications/initialized` gating,
  - rejection of pre-handshake capability calls.
- Validate JSON-RPC behavior:
  - parse errors, invalid requests, method-not-found, invalid params, internal errors,
  - single and batch request handling,
  - request id preservation.
- Validate utility flows (`ping`, cancellation, progress signaling when supported).

## Capability tests
- Tools:
  - `tools/list` stability and schema validity,
  - `tools/call` success/failure paths, timeout and cancellation behavior.
- Resources:
  - `resources/list`, `resources/templates/list`, `resources/read`,
  - list-changed and updated notifications.
- Prompts and completions:
  - `prompts/list`, `prompts/get`, `completion/complete`,
  - argument validation and deterministic ordering checks.

## Transport tests
- Stdio:
  - framing correctness, stderr/stdout separation, graceful shutdown.
- Streamable HTTP:
  - `POST` request/response behavior,
  - SSE stream behavior for `GET`,
  - session lifecycle with `Mcp-Session-Id`,
  - `DELETE` session termination behavior when stateful mode is active.

## Security tests
- Authn/authz pass and fail paths for every capability.
- Tenant isolation tests ensuring no cross-tenant data leakage.
- Rate-limit and abuse-control behavior under attack-like traffic.
- Secret redaction checks for logs and error payloads.

## Load and resilience tests
- Run sustained load at expected and peak concurrency.
- Inject downstream faults and verify graceful degradation.
- Verify event-loop utilization remains within safe bounds under load.

## Architecture conformance tests
- Add static/review checks that reject interface-only scaffolding where selected GuicedEE/Vert.x/MCP libraries already provide concrete contracts.
- Verify capability and transport implementations bind to concrete library APIs/SPI contracts unless an explicit extension-point exception is documented.

## CI gate policy
- Block merges/releases on failing conformance, security, or load gates.
- Publish test artifacts and trend metrics for regression tracking.

See also: `./protocol-baseline.rules.md`, `./capabilities.rules.md`, `./deployment.rules.md`, `../../../platform/testing/README.md`.
