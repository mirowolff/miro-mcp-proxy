# Miro MCP Proxy

MCP SSE to stdio proxy for Miro Design System. This proxy bridges the Miro Design System SSE (Server-Sent Events) MCP server to Claude Desktop's stdio transport protocol.

## What is MCP?

[Model Context Protocol (MCP)](https://modelcontextprotocol.io) is an open protocol that standardizes how applications provide context to LLMs. This proxy enables Claude Desktop to communicate with the Miro Design System MCP server.

## Features

- Converts SSE streams to stdio for Claude Desktop compatibility
- Handles JSON-RPC message queuing and processing
- Supports both command-line arguments and environment variables for configuration
- Graceful error handling and connection management

## Prerequisites

No prerequisites - the bash script uses tools built into macOS.

## Installation

### Simple Installation (Copy & Paste)

1. Download the script from GitHub: [miro-mcp-proxy](https://raw.githubusercontent.com/mirowolff/miro-mcp-proxy/main/miro-mcp-proxy)
2. Right-click → "Save As..." and save it anywhere on your computer (e.g., `~/miro-mcp-proxy`)
3. That's it! No need to set permissions - we'll use `bash` to run it

Or copy the script content directly from the repo and save it as a file.

## Usage

### Command-line Options

```bash
miro-mcp-proxy [options]

Options:
  --url <url>              MCP server URL (default: https://miro.design/api/mcp)
  --token <token>          Authorization token (required)
  --email <email>          User email (required)
  --help, -h              Show help message
```

### Environment Variables

The bash script automatically loads a `.env` file if present in the same directory. Alternatively, you can set environment variables manually:

- `MCP_SERVER_URL` - MCP server URL
- `MIRO_ACCESS_TOKEN` - Authorization token (Bearer)
- `MIRO_USER_EMAIL` - User email

Example `.env` file:
```bash
MIRO_ACCESS_TOKEN="your-token"
MIRO_USER_EMAIL="you@example.com"
```

### Examples

Using .env file (recommended):
```bash
# Create .env file with credentials
echo 'MIRO_ACCESS_TOKEN="your-token"' > .env
echo 'MIRO_USER_EMAIL="you@example.com"' >> .env

# Run the script (credentials loaded automatically)
./miro-mcp-proxy
```

Using command-line arguments:
```bash
./miro-mcp-proxy --token "your-token" --email "you@example.com"
```

Using environment variables:
```bash
export MIRO_ACCESS_TOKEN="your-token"
export MIRO_USER_EMAIL="you@example.com"
./miro-mcp-proxy
```

Custom server URL:
```bash
./miro-mcp-proxy --url "https://custom.miro.server/api/mcp" --token "your-token" --email "you@example.com"
```

## Configuration with Claude Desktop

Add this configuration to your Claude Desktop config file:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

Using environment variables (recommended):
```json
{
  "mcpServers": {
    "miro": {
      "command": "bash",
      "args": ["/path/to/miro-mcp-proxy"],
      "env": {
        "MIRO_ACCESS_TOKEN": "your-token",
        "MIRO_USER_EMAIL": "you@example.com"
      }
    }
  }
}
```

Or using command-line arguments:

```json
{
  "mcpServers": {
    "miro": {
      "command": "bash",
      "args": ["/path/to/miro-mcp-proxy", "--token", "your-token", "--email", "you@example.com"]
    }
  }
}
```

Replace `/path/to/miro-mcp-proxy` with the actual path where you saved the script (e.g., `/Users/yourname/miro-mcp-proxy`).

## How It Works

1. The proxy reads JSON-RPC messages from stdin (from Claude Desktop)
2. Messages are queued and processed sequentially
3. Each message is forwarded to the Miro Design System MCP server via HTTP POST
4. SSE responses from the server are parsed and written to stdout
5. Claude Desktop receives the responses and processes them

## Development

### Project Structure

- `miro-mcp-proxy` - Bash script implementation
- `miro-mcp-proxy.ts` - TypeScript reference implementation (for developers)

The bash script requires no compilation and works out of the box.

## Troubleshooting

### Error: Authorization token is required
Ensure you've provided the token via `--token` flag or `MIRO_ACCESS_TOKEN` environment variable.

### Error: User email is required
Ensure you've provided the email via `--email` flag or `MIRO_USER_EMAIL` environment variable.

### Connection issues
Verify that the MCP server URL is accessible and your credentials are valid.

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
