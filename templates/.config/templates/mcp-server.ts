import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server(
  { name: "{{NAME}}", version: "0.1.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler("tools/list", async () => ({
  tools: []
}));

server.setRequestHandler("tools/call", async (request) => {
  throw new Error(`Unknown tool: ${request.params.name}`);
});

const transport = new StdioServerTransport();
server.connect(transport);
