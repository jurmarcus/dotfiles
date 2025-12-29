# Initialize MCP server with TypeScript
function mcp-init-ts
    set name (test -n "$argv[1]"; and echo $argv[1]; or echo "mcp-server")
    tsinit $name
    cd $name 2>/dev/null
    bun add @modelcontextprotocol/sdk
    template $TEMPLATE_DIR/mcp-server.ts NAME=$name > src/index.ts
    echo "Created MCP server: $name"
    echo "Run: bun run src/index.ts"
end
