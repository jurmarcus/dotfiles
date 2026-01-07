# Neovim Configuration

Based on NvChad v2.5 framework with Lazy.nvim plugin management.

## Files

```
nvim/.config/nvim/
├── init.lua              # Entry point
├── lazy-lock.json        # Locked plugin versions
├── .stylua.toml          # Lua formatter config
└── lua/
    ├── chadrc.lua        # Theme: onedark
    ├── options.lua       # Editor options
    ├── autocmds.lua      # Auto commands
    ├── mappings.lua      # Key bindings
    ├── configs/
    │   ├── lazy.lua      # Lazy.nvim settings
    │   ├── lspconfig.lua # LSP: html, cssls
    │   └── conform.lua   # Formatting: stylua
    └── plugins/
        └── init.lua      # Plugin specs
```

## Key Settings

- **Theme**: catppuccin
- **Leader**: Space
- **LSP**: html, cssls
- **Formatter**: stylua (Lua)
- **Diff mode**: Custom highlights with dark text for readability

## Customization

### Add LSP server
Edit `lua/configs/lspconfig.lua`:
```lua
local servers = { "html", "cssls", "pyright" }
```

### Add formatter
Edit `lua/configs/conform.lua`:
```lua
formatters_by_ft = {
  lua = { "stylua" },
  python = { "ruff_format" },
}
```

### Add plugin
Edit `lua/plugins/init.lua`:
```lua
{
  "author/plugin-name",
  event = "VeryLazy",
  config = function()
    -- setup
  end,
},
```

## Commands

- `:Lazy` - Plugin manager UI
- `:Mason` - LSP/formatter installer
- `:LspInfo` - Check active LSP
- `:ConformInfo` - Check formatters
