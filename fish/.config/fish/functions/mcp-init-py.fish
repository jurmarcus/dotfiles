# Initialize MCP server with Python
function mcp-init-py
    set name (test -n "$argv[1]"; and echo $argv[1]; or echo "mcp-server")
    set module_name (string replace -a "-" "_" $name)
    pyinit $name
    cd $name 2>/dev/null
    uv add mcp
    mkdir -p "src/$module_name"
    template $TEMPLATE_DIR/mcp-server.py NAME=$name > "src/$module_name/server.py"
    echo "Created MCP server: $name"
    echo "Run: uv run python -m $module_name.server"
end
