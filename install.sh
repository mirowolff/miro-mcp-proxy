#!/usr/bin/env bash
# Miro MCP Proxy Installer
# Automatically installs and configures the Miro MCP Proxy for Claude Desktop

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Destination paths
PROXY_PATH="$HOME/.miro-mcp-proxy.sh"
CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Miro MCP Proxy Installer           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Download the proxy script
echo -e "${BLUE}→${NC} Downloading proxy script..."
if curl -fsSL https://raw.githubusercontent.com/mirowolff/miro-mcp-proxy/main/miro-mcp-proxy -o "$PROXY_PATH"; then
    echo -e "${GREEN}✓${NC} Downloaded successfully"
else
    echo -e "${RED}✗${NC} Failed to download proxy script"
    exit 1
fi

# Make it executable
chmod +x "$PROXY_PATH"
echo -e "${GREEN}✓${NC} Made executable"

# Prompt for credentials
echo ""
echo -e "${YELLOW}Configuration${NC}"
echo "Generate your token at: ${BLUE}https://miro.design/mcp/token${NC}"
echo ""
read -p "Enter your Miro access token: " MIRO_TOKEN
read -p "Enter your Miro email: " MIRO_EMAIL

if [[ -z "$MIRO_TOKEN" ]] || [[ -z "$MIRO_EMAIL" ]]; then
    echo -e "${RED}✗${NC} Token and email are required"
    exit 1
fi

# Create or update Claude Desktop config
echo ""
echo -e "${BLUE}→${NC} Configuring Claude Desktop..."

# Create config directory if it doesn't exist
mkdir -p "$(dirname "$CONFIG_PATH")"

# Check if config file exists
if [[ ! -f "$CONFIG_PATH" ]]; then
    # Create new config
    cat > "$CONFIG_PATH" << EOF
{
  "mcpServers": {
    "Miro DS MCP": {
      "command": "bash",
      "args": ["$PROXY_PATH"],
      "env": {
        "MIRO_ACCESS_TOKEN": "$MIRO_TOKEN",
        "MIRO_USER_EMAIL": "$MIRO_EMAIL"
      }
    }
  }
}
EOF
    echo -e "${GREEN}✓${NC} Created new configuration"
else
    # Update existing config using Python (available by default on macOS)
    BACKUP_PATH="${CONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_PATH" "$BACKUP_PATH"

    python3 << EOF
import json
import sys

config_path = "$CONFIG_PATH"
proxy_path = "$PROXY_PATH"
token = "$MIRO_TOKEN"
email = "$MIRO_EMAIL"

try:
    with open(config_path, 'r') as f:
        config = json.load(f)

    # Ensure mcpServers exists
    if 'mcpServers' not in config:
        config['mcpServers'] = {}

    # Add or update Miro DS MCP configuration
    config['mcpServers']['Miro DS MCP'] = {
        'command': 'bash',
        'args': [proxy_path],
        'env': {
            'MIRO_ACCESS_TOKEN': token,
            'MIRO_USER_EMAIL': email
        }
    }

    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)

    print("success")
except Exception as e:
    print(f"error: {e}", file=sys.stderr)
    sys.exit(1)
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Updated existing configuration"
        echo -e "${YELLOW}ℹ${NC} Backup created at: $BACKUP_PATH"
    else
        echo -e "${RED}✗${NC} Failed to update configuration"
        echo -e "${YELLOW}⚠${NC} Please manually add this to your config:"
        echo ""
        cat << EOF
  "mcpServers": {
    "Miro DS MCP": {
      "command": "bash",
      "args": ["$PROXY_PATH"],
      "env": {
        "MIRO_ACCESS_TOKEN": "$MIRO_TOKEN",
        "MIRO_USER_EMAIL": "$MIRO_EMAIL"
      }
    }
  }
EOF
        echo ""
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete! 🎉           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Restart Claude Desktop"
echo "2. The Miro Design System MCP will be available"
echo ""
echo -e "${YELLOW}Proxy location:${NC} $PROXY_PATH"
echo -e "${YELLOW}Config location:${NC} $CONFIG_PATH"
echo ""
