# GLOSSARY - GuicedEE MCP Server

Use these terms as canonical when generating MCP server code for GuicedEE + Vert.x 5.

- MCP: Model Context Protocol; a JSON-RPC based protocol for client-server context exchange.
- MCP protocol revision: The negotiated revision string exchanged during `initialize` (default target here: `2025-11-25`).
- Initialize handshake: Client sends `initialize`; server responds with negotiated version, server info, and capabilities; client then sends `notifications/initialized`.
- Capability negotiation: Explicit declaration of feature surfaces (tools, resources, prompts, logging, completions).
- Tool: An executable server action invoked through `tools/call`, described by JSON Schema.
- Resource: Read-only or parameterized content exposed by the server via `resources/list`, `resources/templates/list`, and `resources/read`.
- Prompt: A reusable prompt template fetched through `prompts/get`, optionally parameterized.
- Completion: Server-side argument/value suggestion exposed via `completion/complete`.
- Streamable HTTP: MCP HTTP transport where clients use `POST` for messages and optional `GET` for SSE streams.
- Stdio transport: Local process transport where newline-delimited JSON-RPC messages flow over stdin/stdout.
- Session ID header: `Mcp-Session-Id`; used by stateful Streamable HTTP servers for session continuity.
- JSON-RPC request id: Correlation key for request/response pairing; preserve across logs and traces.
- List changed notifications: Server events like `notifications/tools/list_changed`, `notifications/resources/list_changed`, and `notifications/prompts/list_changed`.
- Tenant boundary: Isolation rule ensuring one caller never receives another caller's resources, prompts, tool results, or session state.
- Library-first implementation: Build MCP server code against concrete GuicedEE/Vert.x/MCP library contracts before adding custom abstractions.
- Interface-only scaffolding (anti-pattern): Creating local interfaces that mirror existing library contracts without adding domain value or required extension points.
- Skill fallback routing: If runtime skill discovery is incomplete, continue by loading this topic's rule modules directly instead of switching to unguided implementation.

LLM interpretation guidance
- Default to non-blocking handlers on Vert.x event loops; offload blocking work to worker executors.
- Treat capability declarations as contracts; never expose methods without matching capability metadata.
- Keep all MCP payloads schema-validated before execution.
- Use structured, redact-safe logs and never emit secrets or raw credentials in protocol errors.
- Under fallback routing, keep the same library-first policy; do not downgrade to interface-first scaffolding.
