# Miro MCP Proxy

MCP SSE to stdio proxy for Miro Design System. This proxy bridges the Miro Design System SSE (Server-Sent Events) MCP server to Claude Desktop's stdio transport protocol.

## Quick Installation

Copy and paste this command into your terminal:

```bash
curl -fsSL https://mirowolff.github.io/miro-mcp-proxy/install.sh | bash
```

The installer will:
1. Download the proxy script to `~/.miro-mcp-proxy.sh`
2. Prompt you for your Miro access token and email
3. Automatically configure Claude Desktop
4. Be ready to use after restarting Claude Desktop

**Generate your access token at**: [https://miro.design/mcp/token](https://miro.design/mcp/token)

## Manual Installation

If you prefer to install manually:

1. Download the script: [miro-mcp-proxy](https://raw.githubusercontent.com/mirowolff/miro-mcp-proxy/main/miro-mcp-proxy)
2. Generate your access token at [https://miro.design/mcp/token](https://miro.design/mcp/token)
3. Add this configuration to your Claude Desktop config:

**macOS config path**: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
  "mcpServers": {
    "Miro DS MCP": {
      "command": "bash",
      "args": ["/path/to/miro-mcp-proxy"],
      "env": {
        "MIRO_ACCESS_TOKEN": "your-token-here",
        "MIRO_USER_EMAIL": "your-email@example.com"
      }
    }
  }
```

Replace:
- `/path/to/miro-mcp-proxy` with the actual path where you saved the file
- `your-token-here` with your Miro access token
- `your-email@example.com` with your Miro user email

## License

MIT
