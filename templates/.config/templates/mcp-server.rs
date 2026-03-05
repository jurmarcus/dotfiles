//! {{NAME}} MCP server.

use rmcp::{
    ServerHandler,
    handler::server::router::tool::ToolRouter,
    handler::server::wrapper::Parameters,
    model::{Implementation, ServerCapabilities, ServerInfo},
    tool, tool_handler, tool_router,
};
use rmcp::schemars;
use serde::Deserialize;

// ============================================================================
// Server
// ============================================================================

#[derive(Clone)]
pub struct Server {
    #[allow(dead_code)]
    tool_router: ToolRouter<Self>,
}

#[tool_router]
impl Server {
    pub fn new() -> Self {
        Self {
            tool_router: Self::tool_router(),
        }
    }

    /// Say hello.
    #[tool]
    async fn hello(
        &self,
        #[allow(unused)] params: Parameters<HelloInput>,
    ) -> Result<String, String> {
        let Parameters(input) = params;
        Ok(format!("Hello, {}!", input.name.as_deref().unwrap_or("world")))
    }
}

#[derive(Debug, Deserialize, schemars::JsonSchema)]
pub struct HelloInput {
    /// Name to greet
    pub name: Option<String>,
}

// ============================================================================
// Init
// ============================================================================

/// Initialize the server with warn-only health check.
pub async fn init_server() -> Server {
    let server = Server::new();
    // TODO: Add health check for your backend:
    // match server.client().health().await {
    //     Ok(_) => tracing::info!("Connected to backend"),
    //     Err(e) => tracing::warn!(
    //         "Backend unavailable: {e}. Tools will fail until backend is reachable."
    //     ),
    // }
    server
}

// ============================================================================
// ServerHandler
// ============================================================================

#[tool_handler]
impl ServerHandler for Server {
    fn get_info(&self) -> ServerInfo {
        ServerInfo {
            protocol_version: Default::default(),
            capabilities: ServerCapabilities::builder()
                .enable_tools()
                .build(),
            server_info: Implementation {
                name: "{{NAME}}".to_string(),
                title: Some("{{NAME}}".to_string()),
                version: "0.1.0".to_string(),
                icons: None,
                website_url: None,
            },
            instructions: None,
        }
    }
}

// ============================================================================
// Main
// ============================================================================

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .with_writer(std::io::stderr)
        .init();

    let server = init_server().await;

    let transport = rmcp::transport::stdio();
    let service = rmcp::ServiceExt::serve(server, transport).await?;
    service.waiting().await?;

    Ok(())
}
