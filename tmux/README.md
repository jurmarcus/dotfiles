# Tmux Configuration

Terminal multiplexer with Ctrl+B prefix (default) and Catppuccin Frappe theme.

## Files

```
tmux/.config/tmux/
└── tmux.conf    # Main config
```

## Key Bindings

### Prefix: `Ctrl+B`

After pressing `Ctrl+B`, use these keys:

#### Panes
| Key | Action |
|-----|--------|
| `-` | Split down |
| `\|` / `\` | Split right |
| `x` | Close pane |
| `h/j/k/l` | Focus pane (vim-style) |
| `H/J/K/L` | Resize pane |

#### Windows
| Key | Action |
|-----|--------|
| `c` | New window |
| `X` | Close window |
| `Ctrl+h` | Previous window |
| `Ctrl+l` | Next window |
| `0-9` | Go to window |

#### Session
| Key | Action |
|-----|--------|
| `d` | Detach |
| `w` | Session/window picker |
| `r` | Reload config |

#### Copy Mode
| Key | Action |
|-----|--------|
| `[` | Enter copy mode |
| `v` | Begin selection (in copy mode) |
| `y` | Copy to clipboard (in copy mode) |
| `Escape` | Exit copy mode |

## Shell Commands

These are defined in zsh/fish configs:

| Command | Action |
|---------|--------|
| `tls` | List sessions |
| `tcd <session>` | Attach to session |
| `tssh` | Attach/create ssh session |
| `tk <session>` | Kill session |
| `tka` | Kill all sessions |
| `tclaude` | New numbered claude session |
| `topencode` | New numbered opencode session |
| `tservice` | New numbered service session |

## Theme

Catppuccin Frappe with status bar showing:
- Session name (left)
- Window list (center)
- Date/time and hostname (right)
