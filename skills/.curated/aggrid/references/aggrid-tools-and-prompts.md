# AG Grid MCP tools and prompt patterns

Quick reference for AG Grid MCP tools and prompt patterns when implementing or upgrading AG Grid.

## Core tools
- `detect_version`: Infers AG Grid version/framework from the current repo.
- `set_version`: Pins AG Grid `version` + `framework` when detection is incorrect or ambiguous.
- `search_docs`: Searches AG Grid docs/examples/API references for the selected version/framework.
- `list_versions`: Lists available AG Grid versions to plan upgrades/migrations.

## Built-in prompts
- `quick-start`: Creates a guided implementation plan for introducing AG Grid in the chosen framework.
- `upgrade-grid`: Produces version-by-version upgrade steps to move from current to target AG Grid version.

## Prompt patterns
- Feature implementation:
  - `Use AG Grid MCP and search_docs for React row grouping with custom group renderers in AG Grid v34.`
- Bug fixing:
  - `Detect AG Grid version, then search_docs for why setFilterModel is ignored after async rowData load.`
- Upgrades:
  - `Detect version, list_versions, then run upgrade-grid to migrate this Angular app to the latest AG Grid release.`
- Version pinning:
  - `Set version to 34.1.0 and framework to vue, then find the recommended API for server-side datasource refresh.`

## Recommended working order
1. `detect_version`
2. `set_version` (if needed)
3. `search_docs` for the exact feature/problem
4. Implement changes with repo conventions
5. Re-check with `search_docs` when APIs are uncertain
