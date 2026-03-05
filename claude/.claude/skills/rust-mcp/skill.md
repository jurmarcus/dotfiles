---
name: rust-mcp
description: "Scaffold or extend a Rust MCP server using rmcp. Use when the user says /rust-mcp, 'add mcp tool', 'add mcp resource', 'new mcp server', 'scaffold mcp', or wants to add tools/resources to an existing Rust MCP server. Covers both creating new servers and adding components to existing ones."
user_invocable: true
argument: "action and target (e.g., 'new my-server', 'tool search_foo', 'resource jisho://bar')"
---

# Rust MCP Server Skill

Scaffold new Rust MCP servers or add tools/resources to existing ones using the `rmcp` crate.

## Parse Arguments

The `$ARGUMENTS` determines the action:

| Pattern | Action |
|---------|--------|
| `new <name>` | Scaffold a new MCP server |
| `tool <name>` | Add a tool to the current MCP server |
| `resource <uri>` | Add a resource to the current MCP server |
| (empty) | Ask what to do |

---

## Action: New Server

### Step 1: Scaffold

If inside the jisho monorepo (`~/CODE/jisho/`), scaffold under `mcp/`:

1. Create `mcp/<name>/` directory structure:
   ```
   mcp/<name>/
   ├── Cargo.toml
   ├── src/
   │   ├── main.rs
   │   ├── server.rs
   │   └── tools.rs
   └── CLAUDE.md
   ```

2. Add the crate to the workspace `Cargo.toml` members list.

3. Use this Cargo.toml:
   ```toml
   [package]
   name = "<name>"
   version.workspace = true
   edition.workspace = true

   [[bin]]
   name = "<name>"
   path = "src/main.rs"

   [dependencies]
   rmcp = { version = "0.13", features = ["server", "transport-io", "macros"] }
   tokio.workspace = true
   tracing.workspace = true
   tracing-subscriber.workspace = true
   serde.workspace = true
   serde_json.workspace = true
   anyhow = "1.0"
   ```

If outside the monorepo, tell the user to run `rs-init-mcp <name>` which uses the shell template.

### Step 2: Server structure

Follow the canonical rmcp pattern. The **three critical macros** are:

```rust
use rmcp::{
    ServerHandler,
    handler::server::router::tool::ToolRouter,  // MUST be router::tool, NOT server::tool
    handler::server::wrapper::Parameters,
    model::{Implementation, ServerCapabilities, ServerInfo},
    tool, tool_handler, tool_router,
};
```

Server struct:
```rust
#[derive(Clone)]
pub struct MyServer {
    #[allow(dead_code)]
    tool_router: ToolRouter<Self>,
}

#[tool_router]
impl MyServer {
    pub fn new() -> Self {
        Self { tool_router: Self::tool_router() }
    }

    #[tool]
    async fn my_tool(&self, params: Parameters<MyInput>) -> Result<String, String> {
        // ...
    }
}
```

ServerHandler — **`#[tool_handler]` is mandatory**:
```rust
#[tool_handler]  // <-- WITHOUT THIS, TOOLS WON'T BE DISCOVERED
#[allow(clippy::manual_async_fn)]
impl ServerHandler for MyServer {
    fn get_info(&self) -> ServerInfo { ... }
}
```

### Step 3: Verify

Run `cargo build -p <name>` to verify it compiles.

---

## Action: Add Tool

### Step 1: Identify the server

Find the MCP server in the current directory or the nearest `server.rs` with `#[tool_router]`.

### Step 2: Create the input struct

Add to `tools.rs` (or `tools/mod.rs`):

```rust
#[derive(Debug, Deserialize, schemars::JsonSchema)]
pub struct <ToolName>Input {
    /// Description of the parameter
    pub param: String,

    /// Optional parameter with default
    pub limit: Option<i64>,
}
```

Rules:
- Use `schemars::JsonSchema` for schema generation
- Document every field with `///` — these become the tool's parameter descriptions
- Use `Option<T>` for optional parameters
- Import: `use rmcp::schemars;`

### Step 3: Add the tool method

In `server.rs`, add inside the `#[tool_router] impl`:

```rust
/// Tool description (becomes the MCP tool description).
/// Use multiple lines for detailed help.
#[tool]
async fn <tool_name>(
    &self,
    params: Parameters<<ToolName>Input>,
) -> Result<String, String> {
    self.<tool_name>_impl(params).await
}
```

### Step 4: Add the implementation

In a separate impl block (or in `tools/*.rs`):

```rust
impl MyServer {
    async fn <tool_name>_impl(
        &self,
        Parameters(input): Parameters<<ToolName>Input>,
    ) -> Result<String, String> {
        let limit = input.limit.unwrap_or(10);
        // Implementation here
        Ok(format!("Result: ..."))
    }
}
```

### Step 5: Verify

Run `cargo build -p <crate-name>` to verify it compiles.

---

## Action: Add Resource

### Step 1: Add the URI pattern

In `resources/mod.rs`, add a variant to `ResourceRequest`:

```rust
pub enum ResourceRequest {
    // existing...
    NewThing(String),
}
```

Add parsing in `parse_resource_uri()`:

```rust
if let Some(id) = uri.strip_prefix("jisho://thing/") {
    return Some(ResourceRequest::NewThing(id.to_string()));
}
```

### Step 2: Add the handler

In `server.rs`, add a handler method:

```rust
async fn handle_new_thing(&self, id: &str) -> String {
    // fetch data, format as markdown
}
```

### Step 3: Wire into read_resource

Add dispatch in the `read_resource` method:

```rust
ResourceRequest::NewThing(id) => self.handle_new_thing(&id).await,
```

### Step 4: Add resource template

In `list_resource_templates`, add:

```rust
RawResourceTemplate {
    uri_template: "jisho://thing/{id}".to_string(),
    name: "thing_lookup".to_string(),
    title: Some("Thing Lookup".to_string()),
    description: Some("Look up a thing by ID".to_string()),
    mime_type: Some("text/markdown".to_string()),
    icons: None,
}.no_annotation(),
```

---

## Common Pitfalls

| Mistake | Fix |
|---------|-----|
| `handler::server::tool::ToolRouter` | Use `handler::server::router::tool::ToolRouter` |
| Missing `#[tool_handler]` on ServerHandler | Add it — tools won't be discovered without it |
| Missing `"macros"` in rmcp features | Add `"macros"` to Cargo.toml features |
| `schemars` not found | Use `rmcp::schemars` (re-exported) |
| Tool params not destructured | Use `Parameters(input)` pattern |

## Important Notes

- Always return `Result<String, String>` from tool methods — rmcp requires this
- Tool descriptions come from the `///` doc comment on the `#[tool]` method
- Parameter descriptions come from `///` doc comments on input struct fields
- The `#[tool_router]` impl block must contain `pub fn new()` that calls `Self::tool_router()`
- Resources use `text/markdown` mime type — format output as markdown
