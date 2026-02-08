# Protocol Baseline Rules - GuicedEE MCP Server

Purpose: enforce MCP protocol correctness before capability-specific behavior.

## Core protocol contract
- Use JSON-RPC 2.0 envelopes for all requests, responses, and notifications.
- Accept both single and batch requests; process batch items independently with per-item errors.
- Preserve caller request ids exactly in responses.
- Reject malformed JSON and invalid JSON-RPC structures with standards-compliant error objects.

## Handshake and initialization
- Require the MCP handshake sequence:
  1. Client request: `initialize`
  2. Server response: negotiated protocol revision, server info, and capabilities
  3. Client notification: `notifications/initialized`
- Reject capability method calls before the handshake is complete.
- Store negotiated revision in session/request context and use it when applying compatibility logic.

## Mandatory utility methods
- Implement `ping` for liveness checks.
- Handle cancellation notifications for long-running calls and propagate cancellation downstream.
- Support progress reporting where operations are long-running and callers request progress.

## Capability declaration integrity
- Ensure runtime method routing matches declared capabilities exactly.
- Do not expose hidden methods outside the declared capability set.
- Validate outgoing capability metadata at startup and fail boot if contracts are inconsistent.

## Error handling policy
- Use stable error classes:
  - caller validation errors (`Invalid params`, schema violations),
  - method routing errors (`Method not found`),
  - server execution errors (internal failures, downstream outages).
- Include machine-readable `data` fields in errors without leaking sensitive values.
- Correlate every error with request id, session id (if any), and tenant id in logs.

## Pagination and cursors
- For list-style methods, return deterministic ordering and opaque cursors.
- Cursors must be tamper-resistant and bounded by tenant/session scope.
- Expired or invalid cursors must return explicit caller errors.

## Forward-only compatibility
- Introduce protocol revisions through additive adapters and tests.
- Remove deprecated compatibility paths only when explicitly requested by product policy.

See also: `./capabilities.rules.md`, `./security-authz.rules.md`, `./testing-conformance.rules.md`.
