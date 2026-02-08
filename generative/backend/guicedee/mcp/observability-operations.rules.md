# Observability and Operations Rules - GuicedEE MCP Server

Purpose: make MCP runtime behavior measurable, debuggable, and operable in production.

## Structured logging
- Log in structured JSON with stable keys:
  - `requestId`, `sessionId`, `tenantId`, `principalId`, `method`, `durationMs`, `outcome`.
- Keep protocol payload logging opt-in and redact by default.
- Route all logs through stderr for stdio mode and centralized appenders for HTTP mode.
- Support runtime log-level control and map MCP `logging/setLevel` to server logger policy.

## Metrics
- Emit minimum metric set:
  - handshake success/failure counts,
  - request latency by method,
  - tool/resource/prompt error rates,
  - active sessions and SSE streams,
  - authn/authz denial counters,
  - rate-limit drops.
- Tag metrics with low-cardinality dimensions only.
- Publish health and readiness probes separate from MCP endpoints.

## Tracing
- Propagate W3C trace context (`traceparent`) from HTTP headers.
- Create spans for protocol decode, auth, policy check, handler execution, and response encode.
- Attach request id and method name to spans for cross-system correlation.

## Operational runbooks
- Define runbooks for:
  - handshake failures,
  - stream disconnect spikes,
  - elevated tool timeout rates,
  - auth outage scenarios.
- Include per-runbook rollback and temporary mitigation steps.

## SLOs and alerting
- Define service-level objectives for availability, p95 latency, and error budget.
- Alert on sustained breaches, not single spikes.
- Track deployment markers in telemetry to correlate regressions with releases.

See also: `../../../platform/observability/README.md`, `./deployment.rules.md`, `./testing-conformance.rules.md`.
