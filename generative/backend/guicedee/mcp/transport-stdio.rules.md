# Stdio Transport Rules - GuicedEE MCP Server

Purpose: provide a compliant local transport profile for development, CI, and desktop integrations.

## Message framing
- Exchange newline-delimited JSON-RPC messages over stdin/stdout.
- Write protocol payloads to stdout only.
- Write logs, diagnostics, and stack traces to stderr only.

## Handler implementation defaults
- Implement stdio IO loops with concrete Vert.x/Java stream primitives and GuicedEE lifecycle hooks.
- Avoid interface-only stdio abstraction layers when existing runtime contracts already cover framing and dispatch.

## Process lifecycle
- Start stdio listeners only after registries and capability routing are ready.
- Flush stdout on each message boundary to reduce client-side latency.
- On shutdown, stop reading stdin, drain in-flight requests, then exit gracefully.

## Reliability and limits
- Apply maximum message size limits and reject oversized payloads with protocol errors.
- Apply per-request execution deadlines and cancellation propagation.
- Keep bounded worker pools for blocking operations triggered from stdio requests.

## Security posture
- Treat stdio as trusted-local by default; do not assume network-level controls.
- Require explicit launch-time controls for any credentialed tools.
- Redact secrets from stderr logs and protocol error payloads.

## Test requirements
- Validate handshake, tool execution, and error paths in pure stdio integration tests.
- Include malformed JSON, partial-line, and cancellation test cases.

See also: `./protocol-baseline.rules.md`, `./testing-conformance.rules.md`.
