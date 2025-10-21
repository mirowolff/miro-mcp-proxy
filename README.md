# Miro MCP Proxy

MCP SSE to stdio proxy for Miro Design System. This proxy bridges the Miro Design System SSE (Server-Sent Events) MCP server to Claude Desktop's stdio transport protocol.

## Installation

1. Download the script: [miro-mcp-proxy.txt](https://raw.githubusercontent.com/mirowolff/miro-mcp-proxy/main/miro-mcp-proxy) (Optional: Rename from `.txt` to `.sh` extension)
   - Right-click → "Save As..." and save it anywhere on your computer
2. Generate your access token at [https://miro.design/mcp/token](https://miro.design/mcp/token)
3. Add this configuration to your Claude Desktop config:

**macOS config path**: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
  "mcpServers": {
    "Miro DS MCP": {
      "command": "bash",
      "args": ["/Users/yourname/Downloads/miro-mcp-proxy.txt"],
      "env": {
        "MIRO_ACCESS_TOKEN": "your-token-here",
        "MIRO_USER_EMAIL": "your-email@example.com"
      }
    }
  }
```

Replace:
- `/Users/yourname/Downloads/miro-mcp-proxy.txt` with the actual path where you saved the file (To find your username: open Finder and look for the house icon in the sidebar)
- `your-token-here` with your Miro access token
- `your-email@example.com` with your Miro user email

## License

MIT
