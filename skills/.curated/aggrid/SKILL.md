---
name: aggrid
description: Use the AG Grid MCP server to implement, upgrade, and troubleshoot AG Grid in React, Angular, Vue, and vanilla JavaScript projects. Trigger when tasks mention AG Grid tables, column definitions, row models, renderers/editors, AG Grid version migrations, or AG Grid MCP setup files (mcp.json, .vscode/mcp.json, .cursor/mcp.json, .aiassistant/mcp.json, .junie/mcp.json).
---

# AG Grid MCP

Use AG Grid MCP to ground AG Grid changes in version-specific documentation and examples. For setup across workspace adapters, see `references/aggrid-mcp-config.md`.

## Required Flow (Do Not Skip)
1. Run `detect_version` first to infer the AG Grid version and framework from the workspace.
2. If detection is missing or wrong (monorepo, partial checkout, multiple apps), run `set_version` with explicit `version` and `framework`.
3. Use `search_docs` for the exact feature before writing or changing code.
4. For upgrades, run `list_versions`, then execute the `upgrade-grid` prompt flow from `references/aggrid-tools-and-prompts.md` one version step at a time.
5. Implement changes using project conventions, then validate with build/tests or targeted runtime checks.

## Implementation Rules
- Treat MCP output as authoritative for AG Grid APIs and behavior for the selected version.
- Prefer existing wrappers/components over introducing parallel grid abstractions.
- Keep AG Grid Community/Enterprise package usage consistent with the current project.
- Avoid guessing AG Grid APIs; verify with `search_docs` when uncertain.
- When changing column definitions, filters, editors, row model behavior, or state handling, include regression-safe validation.

## References
- `references/aggrid-mcp-config.md` - adapter-specific MCP setup and verification.
- `references/aggrid-tools-and-prompts.md` - AG Grid MCP tools and prompt patterns.
