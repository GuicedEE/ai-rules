# Security and Authorization Rules - GuicedEE MCP Server

Purpose: protect MCP endpoints, tools, and data at internet scale.

## Authentication baseline
- Require authenticated access for `mcp.guicedee.com` in production.
- Support bearer-token authentication (OIDC/JWT) as the primary mode.
- Allow API keys only for tightly controlled service-to-service scenarios.
- Reject unauthenticated capability calls with explicit protocol errors.

## Authorization model
- Authorize per capability and per operation:
  - which tools a principal can call,
  - which resources a principal can read,
  - which prompts/completions are visible.
- Apply tenant-aware policy checks before registry dispatch.
- Deny by default when policy metadata is missing.

## Input and output safety
- Validate all tool/resource/prompt inputs with JSON Schema before execution.
- Enforce strict URI and template argument validation to prevent traversal and injection paths.
- Sanitize tool outputs before returning them to callers.
- Redact secrets, credentials, and internal topology in error payloads.

## HTTP transport hardening
- Validate `Origin` and `Host` headers to mitigate DNS rebinding risk.
- Enforce TLS and HSTS at the edge.
- Restrict CORS to trusted client origins.
- Apply rate limits by tenant, principal, and IP.

## Session and token handling
- Bind `Mcp-Session-Id` state to authenticated principal and tenant context.
- Expire inactive sessions with short, explicit TTL windows.
- Revalidate auth context on each request, even for active sessions.

## Secret management
- Load credentials from environment or secret stores, never from source-controlled files.
- Rotate signing keys and API credentials on a fixed schedule.
- Fail startup if required secrets are missing or malformed.

## Audit and incident response
- Emit security audit events for auth failures, authorization denials, and sensitive tool calls.
- Preserve request/session correlation ids in audit logs.
- Keep incident playbooks for token compromise, key rotation, and tenant isolation breaches.

See also: `../../../platform/security-auth/README.md`, `../../../platform/secrets-config/env-variables.md`, `./observability-operations.rules.md`.
