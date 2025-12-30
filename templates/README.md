# Templates

Shared templates for both zsh and fish shells.

## Files

```
templates/
└── .config/templates/
    ├── mcp-server.py    # Python MCP server template
    └── mcp-server.ts    # TypeScript MCP server template
```

## Usage

Templates use mustache-style `{{VAR}}` placeholders.

```bash
# From zsh or fish
py-init-mcp my-server   # Creates Python MCP server
ts-init-mcp my-server   # Creates TypeScript MCP server
```

## Template Variables

| Variable | Description |
|----------|-------------|
| `{{NAME}}` | Server/project name |

## Adding Templates

1. Create template file in `templates/.config/templates/`
2. Use `{{VAR}}` for substitution points
3. Re-stow: `stow -R templates`
4. Use via `template` function (defined in both shells)

## Why Shared?

Previously templates were duplicated in `zsh/.config/zsh/templates/` and `fish/.config/fish/templates/`. Now consolidated to single location used by both shells via `TEMPLATE_DIR=~/.config/templates`.
