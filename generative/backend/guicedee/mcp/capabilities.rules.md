# Capability Rules - Tools, Resources, Prompts, and Completions

Purpose: define a comprehensive MCP capability surface for GuicedEE servers.

## Capability registration model
- Build capability registries at startup from DI-managed providers.
- Keep provider registration deterministic and conflict-checked by name.
- Emit startup failures when duplicate names or invalid schemas are detected.

## Provider implementation defaults
- Register capabilities via concrete provider implementations discovered through DI/SPI.
- Reuse existing library capability/provider abstractions where available.
- Do not create parallel local interfaces for tools/resources/prompts/completions when existing contracts already satisfy the requirement.

## Tools capability
- Expose `tools/list` and `tools/call`.
- Publish `notifications/tools/list_changed` when the tool catalog changes.
- For each tool:
  - define `name`, `description`, and `inputSchema`,
  - define `outputSchema` when outputs are structured,
  - include MCP tool annotations where relevant (`readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`).
- Enforce strict input validation before tool execution.

## Resources capability
- Expose `resources/list` and `resources/read`.
- Support `resources/templates/list` for parameterized resource URIs.
- Publish resource events:
  - `notifications/resources/list_changed`,
  - `notifications/resources/updated`.
- Keep resource handlers side-effect free by default; writes belong in tools.

## Prompts capability
- Expose `prompts/list` and `prompts/get`.
- Publish `notifications/prompts/list_changed` when prompt catalogs change.
- Validate prompt arguments with explicit schema contracts before template rendering.

## Completions capability
- Expose `completion/complete` for prompt and resource-template argument completion.
- Keep completion handlers fast and bounded; use deadlines and capped result counts.
- Return deterministic rankings where possible to improve client UX consistency.

## Optional advanced utilities
- Enable utilities like roots, elicitation, and sampling only when required by product scope.
- Guard advanced utilities behind explicit feature flags and capability declarations.
- Add dedicated authorization checks for each advanced utility path.

## Schema and contract governance
- Prefer explicit JSON Schema `additionalProperties: false` for strict contracts.
- Keep schemas versioned and backward-safe within a protocol revision.
- Treat schema changes as API changes and gate with compatibility tests.

See also: `./protocol-baseline.rules.md`, `./security-authz.rules.md`, `./testing-conformance.rules.md`.
