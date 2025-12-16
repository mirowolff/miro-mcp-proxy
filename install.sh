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
    # Update existing config
    # Check if jq is available
    if command -v jq &> /dev/null; then
        # Use jq to properly merge the configuration
        TMP_CONFIG=$(mktemp)
        jq --arg proxy_path "$PROXY_PATH" \
           --arg token "$MIRO_TOKEN" \
           --arg email "$MIRO_EMAIL" \
           '.mcpServers["Miro DS MCP"] = {
               "command": "bash",
               "args": [$proxy_path],
               "env": {
                   "MIRO_ACCESS_TOKEN": $token,
                   "MIRO_USER_EMAIL": $email
               }
           }' "$CONFIG_PATH" > "$TMP_CONFIG"
        mv "$TMP_CONFIG" "$CONFIG_PATH"
        echo -e "${GREEN}✓${NC} Updated existing configuration"
    else
        # Fallback: create backup and manual instructions
        BACKUP_PATH="${CONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$CONFIG_PATH" "$BACKUP_PATH"
        echo -e "${YELLOW}⚠${NC} jq not found. Created backup at:"
        echo "  $BACKUP_PATH"
        echo ""
        echo -e "${YELLOW}Please manually add this to your config:${NC}"
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
        exit 0
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
