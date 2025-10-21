#!/usr/bin/env bun
/**
 * MCP SSE to stdio proxy for Miro Design System
 * Bridges the Miro Design System SSE MCP server to Claude Desktop's stdio transport
 * 
 * Usage:
 *   miro-mcp-proxy [options]
 * 
 * Options:
 *   --url <url>              MCP server URL (default: https://miro.design/api/mcp)
 *   --token <token>          Authorization token
 *   --email <email>          User email
 *   --help                   Show this help message
 * 
 * Environment Variables:
 *   MCP_SERVER_URL          MCP server URL
 *   MIRO_ACCESS_TOKEN       Authorization token (Bearer)
 *   MIRO_USER_EMAIL         User email
 */

interface Config {
  url: string;
  token: string;
  email: string;
}

interface JSONRPCMessage {
  jsonrpc: string;
  method?: string;
  params?: any;
  id?: number | string;
  result?: any;
  error?: any;
}

function parseArgs(): Config {
  const args = process.argv.slice(2);
  
  // Parse command-line arguments
  let url = process.env.MCP_SERVER_URL || "https://miro.design/api/mcp";
  let token = process.env.MIRO_ACCESS_TOKEN || "";
  let email = process.env.MIRO_USER_EMAIL || "";

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    
    if (arg === "--help" || arg === "-h") {
      console.error(`
MCP SSE to stdio proxy for Miro Design System

Usage:
  miro-mcp-proxy [options]

Options:
  --url <url>              MCP server URL (default: https://miro.design/api/mcp)
  --token <token>          Authorization token
  --email <email>          User email
  --help, -h              Show this help message

Environment Variables:
  MCP_SERVER_URL          MCP server URL
  MIRO_ACCESS_TOKEN       Authorization token (Bearer)
  MIRO_USER_EMAIL         User email

Example:
  miro-mcp-proxy --token "your-token" --email "you@example.com"
  
  # Or using environment variables:
  export MIRO_ACCESS_TOKEN="your-token"
  export MIRO_USER_EMAIL="you@example.com"
  miro-mcp-proxy
`);
      process.exit(0);
    } else if (arg === "--url" && i + 1 < args.length) {
      url = args[++i];
    } else if (arg === "--token" && i + 1 < args.length) {
      token = args[++i];
    } else if (arg === "--email" && i + 1 < args.length) {
      email = args[++i];
    }
  }

  // Validate required parameters
  if (!token) {
    console.error("Error: Authorization token is required");
    console.error("Provide it via --token flag or MIRO_ACCESS_TOKEN environment variable");
    process.exit(1);
  }

  if (!email) {
    console.error("Error: User email is required");
    console.error("Provide it via --email flag or MIRO_USER_EMAIL environment variable");
    process.exit(1);
  }

  return { url, token, email };
}

class MCPSSEProxy {
  private config: Config;
  private messageQueue: JSONRPCMessage[] = [];
  private processing = false;

  constructor(config: Config) {
    this.config = config;
  }

  private getHeaders() {
    return {
      "Authorization": `Bearer ${this.config.token}`,
      "X-User-Email": this.config.email,
      "Content-Type": "application/json",
      "Accept": "application/json, text/event-stream",
    };
  }

  /**
   * Send a message and handle the SSE response stream
   */
  async sendMessage(message: JSONRPCMessage) {
    try {
      console.error(`Sending: ${message.method || 'response'} (id: ${message.id})`);

      const response = await fetch(this.config.url, {
        method: "POST",
        headers: this.getHeaders(),
        body: JSON.stringify(message),
      });

      if (!response.ok) {
        console.error(`HTTP error: ${response.status}`);
        const text = await response.text();
        console.error(`Response: ${text}`);
        return;
      }

      const contentType = response.headers.get("content-type") || "";
      
      if (contentType.includes("text/event-stream")) {
        // Handle SSE response
        await this.handleSSEResponse(response);
      } else if (contentType.includes("application/json")) {
        // Handle JSON response
        const data = await response.json();
        console.log(JSON.stringify(data));
      } else {
        console.error(`Unexpected content-type: ${contentType}`);
      }
    } catch (error: any) {
      console.error(`Error sending message: ${error.message}`);
    }
  }

  /**
   * Handle SSE response stream
   */
  async handleSSEResponse(response: Response) {
    if (!response.body) {
      console.error("No response body");
      return;
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = "";

    try {
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split("\n");
        buffer = lines.pop() || "";

        for (const line of lines) {
          const trimmed = line.trim();
          
          if (trimmed.startsWith("data:")) {
            const data = trimmed.substring(5).trim();
            if (data && data !== "[DONE]") {
              try {
                // Validate JSON and write to stdout
                JSON.parse(data);
                console.log(data);
              } catch (e) {
                console.error(`Invalid JSON in SSE: ${data}`);
              }
            }
          }
        }
      }
    } catch (error: any) {
      console.error(`SSE read error: ${error.message}`);
    }
  }

  /**
   * Read messages from stdin and queue them
   */
  async readStdin() {
    const stdin = Bun.stdin.stream();
    const reader = stdin.getReader();
    const decoder = new TextDecoder();
    let buffer = "";

    console.error(`Connected to: ${this.config.url}`);
    console.error(`User: ${this.config.email}`);
    console.error("Ready - waiting for messages...");

    try {
      while (true) {
        const { done, value } = await reader.read();
        
        if (done) {
          console.error("Stdin closed");
          break;
        }

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split("\n");
        buffer = lines.pop() || "";

        for (const line of lines) {
          const trimmed = line.trim();
          if (!trimmed) continue;

          try {
            const message: JSONRPCMessage = JSON.parse(trimmed);
            this.messageQueue.push(message);
            
            // Process queue if not already processing
            if (!this.processing) {
              this.processQueue();
            }
          } catch (error: any) {
            console.error(`Invalid JSON from stdin: ${error.message}`);
          }
        }
      }
    } catch (error: any) {
      console.error(`Error reading stdin: ${error.message}`);
    }
  }

  /**
   * Process queued messages sequentially
   */
  async processQueue() {
    this.processing = true;

    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift();
      if (message) {
        await this.sendMessage(message);
      }
    }

    this.processing = false;
  }

  async run() {
    await this.readStdin();
  }
}

// Main execution
const config = parseArgs();
const proxy = new MCPSSEProxy(config);

process.on("SIGINT", () => {
  console.error("Proxy stopped");
  process.exit(0);
});

process.on("SIGTERM", () => {
  console.error("Proxy terminating");
  process.exit(0);
});

proxy.run().catch((error) => {
  console.error(`Proxy error: ${error.message}`);
  process.exit(1);
});
