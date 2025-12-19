Add a new MCP tool to this server: $ARGUMENTS

Requirements:
1. Add the tool definition with proper JSON schema for parameters
2. Implement the tool handler with proper error handling
3. Add input validation
4. Return properly formatted MCP responses
5. Add appropriate logging

Follow the existing patterns in this codebase. If this is a Python MCP server, use the `@server.call_tool()` decorator. If TypeScript, use `server.setRequestHandler()`.
