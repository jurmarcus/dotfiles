# MCP server development

function template --description "Simple mustache-style template"
    set file $argv[1]
    set -e argv[1]
    set content (cat $file)
    for arg in $argv
        set key (string split -m 1 = $arg)[1]
        set val (string split -m 1 = $arg)[2]
        set content (string replace -a "{{$key}}" $val $content)
    end
    echo $content
end

function mcp-init-py --description "Initialize MCP server with Python"
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

function mcp-init-ts --description "Initialize MCP server with TypeScript"
    set name (test -n "$argv[1]"; and echo $argv[1]; or echo "mcp-server")
    tsinit $name
    cd $name 2>/dev/null
    bun add @modelcontextprotocol/sdk
    template $TEMPLATE_DIR/mcp-server.ts NAME=$name > src/index.ts
    echo "Created MCP server: $name"
    echo "Run: bun run src/index.ts"
end
