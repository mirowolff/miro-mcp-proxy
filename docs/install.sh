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

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  📦 Miro MCP Proxy Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if running in a pipe (non-interactive)
if [ ! -t 0 ]; then
    echo -e "${YELLOW}⚠ Interactive mode required${NC}"
    echo ""
    echo "This installer needs to prompt for your credentials."
    echo "Please download and run it directly instead:"
    echo ""
    echo -e "${BLUE}  curl -fsSL https://mirowolff.github.io/miro-mcp-proxy/install.sh -o install.sh${NC}"
    echo -e "${BLUE}  bash install.sh${NC}"
    echo ""
    exit 1
fi

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
echo -e "Generate your token at: ${BLUE}https://miro.design/mcp/token${NC}"
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
    # Update existing config with fallback chain: jq -> python -> sed -> manual
    BACKUP_PATH="${CONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_PATH" "$BACKUP_PATH"
    CONFIG_UPDATED=false

    # Try jq first (best option)
    if command -v jq &> /dev/null; then
        TMP_CONFIG=$(mktemp)
        if jq --arg proxy_path "$PROXY_PATH" \
           --arg token "$MIRO_TOKEN" \
           --arg email "$MIRO_EMAIL" \
           '.mcpServers["Miro DS MCP"] = {
               "command": "bash",
               "args": [$proxy_path],
               "env": {
                   "MIRO_ACCESS_TOKEN": $token,
                   "MIRO_USER_EMAIL": $email
               }
           }' "$CONFIG_PATH" > "$TMP_CONFIG" 2>/dev/null; then
            mv "$TMP_CONFIG" "$CONFIG_PATH"
            CONFIG_UPDATED=true
            echo -e "${GREEN}✓${NC} Updated existing configuration (using jq)"
        fi
    fi

    # Try python if jq failed or not available
    if [ "$CONFIG_UPDATED" = false ] && (command -v python3 &> /dev/null || command -v /usr/bin/python3 &> /dev/null); then
        PYTHON_CMD=$(command -v python3 || echo "/usr/bin/python3")
        if $PYTHON_CMD << EOF 2>/dev/null
import json
import sys

config_path = "$CONFIG_PATH"
proxy_path = "$PROXY_PATH"
token = "$MIRO_TOKEN"
email = "$MIRO_EMAIL"

try:
    with open(config_path, 'r') as f:
        config = json.load(f)

    if 'mcpServers' not in config:
        config['mcpServers'] = {}

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

    sys.exit(0)
except:
    sys.exit(1)
EOF
        then
            CONFIG_UPDATED=true
            echo -e "${GREEN}✓${NC} Updated existing configuration (using python)"
        fi
    fi

    # Try sed as last resort before manual
    if [ "$CONFIG_UPDATED" = false ]; then
        # Check if mcpServers key exists
        if grep -q '"mcpServers"' "$CONFIG_PATH"; then
            # mcpServers exists, add our server to it
            # Find the closing brace of mcpServers and insert before it
            TMP_CONFIG=$(mktemp)
            sed -E '/^[[:space:]]*"mcpServers"[[:space:]]*:[[:space:]]*\{/,/^[[:space:]]*\}/{
                /^[[:space:]]*\}/ i\
    "Miro DS MCP": {\
      "command": "bash",\
      "args": ["'"$PROXY_PATH"'"],\
      "env": {\
        "MIRO_ACCESS_TOKEN": "'"$MIRO_TOKEN"'",\
        "MIRO_USER_EMAIL": "'"$MIRO_EMAIL"'"\
      }\
    },
            }' "$CONFIG_PATH" > "$TMP_CONFIG"

            # Remove trailing comma before closing brace if it exists
            sed -i.tmp 's/,\([[:space:]]*\)\}/\1}/' "$TMP_CONFIG"
            rm -f "$TMP_CONFIG.tmp"

            if [ -s "$TMP_CONFIG" ]; then
                mv "$TMP_CONFIG" "$CONFIG_PATH"
                CONFIG_UPDATED=true
                echo -e "${GREEN}✓${NC} Updated existing configuration (using sed)"
            fi
        fi
    fi

    # Show status
    if [ "$CONFIG_UPDATED" = true ]; then
        echo -e "${YELLOW}ℹ${NC} Backup created at: $BACKUP_PATH"
    else
        echo -e "${YELLOW}⚠${NC} Could not automatically update config"
        echo -e "${YELLOW}ℹ${NC} Backup created at: $BACKUP_PATH"
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
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅ Installation Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Restart Claude Desktop"
echo "2. The Miro Design System MCP will be available"
echo ""
echo -e "${YELLOW}Proxy location:${NC} $PROXY_PATH"
echo -e "${YELLOW}Config location:${NC} $CONFIG_PATH"
echo ""
