# AG Grid MCP config reference

Use this server block for AG Grid + Mermaid MCP:

```json
{
  "mcpServers": {
    "ag-mcp": {
      "command": "npx",
      "args": ["ag-mcp"]
    },
    "mcp-mermaid": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "mcp-mermaid"]
    }
  }
}
```

## Recommended workspace config targets
- `mcp.json`
- `.vscode/mcp.json`
- `.cursor/mcp.json`
- `.aiassistant/mcp.json`
- `.junie/mcp.json`

## Setup checklist
1. Ensure Node.js and `npx` are installed on the machine running the assistant.
2. Add the server block above to the target config files.
3. Restart the assistant/IDE after editing MCP config.
4. Run `detect_version` to confirm the server is reachable.

## Troubleshooting
- `npx: command not found`: install Node.js and restart the terminal/IDE.
- First run is slow: `npx` may download the package before starting the server.
- Wrong project version/framework in monorepos: run `set_version` explicitly.
