# Scaffold MCP Server

> New MCP server for the jisho ecosystem with proper integration | Model: default | Agents: 0

---

Create a new MCP server called [SERVER_NAME] that [PURPOSE_DESCRIPTION].

## Scaffold

**Python MCP** (preferred for data/API servers):
```bash
py-init-mcp [server-name]
```

**TypeScript MCP** (preferred for browser/UI integration):
```bash
ts-init-mcp [server-name]
```

This creates the project from the template in ~/.config/templates/.

## Server Structure

```
[server-name]/
├── CLAUDE.md              # Server-specific instructions
├── justfile               # build, test, lint, run, dev recipes
├── pyproject.toml         # or package.json for TS
├── src/
│   └── [server_name]/
│       ├── __init__.py
│       ├── server.py      # MCP server definition, tool/resource registration
│       ├── tools.py       # Tool implementations
│       └── resources.py   # Resource implementations
└── tests/
```

## Integration Points

### Register in Claude Code

Add to `~/.claude/settings.json` under `mcpServers`:

```json
"[server-name]": {
  "command": "uv",
  "args": ["run", "--directory", "/path/to/[server-name]", "python", "-m", "[server_name]"],
  "env": {}
}
```

### Connect to existing jisho services

If this server needs data from other services:
- **jisho-dictionary**: SQLite database on methylene-studio, access via `JISHO_DB_PATH`
- **jisho-acquisition**: User vocab state, access via MCP resource URIs (jisho://user/vocab/*)
- **jisho-voice**: TTS synthesis on methylene-studio:50000
- **jisho-youtube**: Video recommendations via GraphQL on methylene-studio

Use direnv `.envrc` for environment-specific URLs:
```bash
# On methylene-studio (local)
export JISHO_DB_PATH="/path/to/local/db"

# On methylene-macbook (remote via Tailscale)
export JISHO_REMOTE_HOST="methylene-studio"
export JISHO_DB_URL="http://${JISHO_REMOTE_HOST}:PORT"
```

## Design Principles

- **Resources for reads**: Use MCP resources (URI-based) for data lookups and queries
- **Tools for actions**: Use MCP tools for operations with side effects (create, update, delete, synthesize)
- **Prompts for templates**: Use MCP prompts for reusable interaction patterns
- **Batch operations**: If a tool might be called N times, add a batch variant (e.g., `batch_lookup_vocab`)
- **Health check**: Always include a health/status tool for debugging connectivity

## Justfile recipes

```just
default:
    @just --list

run:
    uv run python -m [server_name]

dev:
    uv run python -m [server_name] --dev

test:
    uv run pytest

lint:
    uvx ruff check src/ tests/

fmt:
    uvx ruff format src/ tests/

check:
    uvx ty check src/
```

---

## Notes

- **py-init-mcp / ts-init-mcp**: Your custom templates in ~/.config/templates/ already handle boilerplate. Use them instead of scaffolding manually.
- **Server structure convention**: server.py for registration, tools.py for implementations, resources.py for data — keeps files focused and findable.
- **direnv for multi-machine**: The same MCP server code runs on both machines; only the env vars differ. Never hardcode hostnames.
- **Batch variants**: Learned from jisho-dictionary — `batch_lookup_vocab` is dramatically faster than N individual lookups. Design for batch from the start.
- **Health check tool**: Indispensable for debugging "is the MCP server even running?" issues across the Tailscale network.
