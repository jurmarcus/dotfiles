from mcp.server import Server
from mcp.server.stdio import stdio_server

server = Server("{{NAME}}")

@server.list_tools()
async def list_tools():
    return []

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    raise ValueError(f"Unknown tool: {name}")

async def main():
    async with stdio_server() as (read, write):
        await server.run(read, write)

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
