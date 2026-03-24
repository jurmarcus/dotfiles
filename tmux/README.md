# Tmux Configuration

Terminal multiplexer with Ctrl+A prefix, Catppuccin Frappe theme, and OSC 52 clipboard that works through nested tmux/mosh/ET/SSH sessions.

## Files

```
tmux/
├── .config/tmux/tmux.conf    # Main config
└── .local/bin/osc52-copy     # Clipboard helper (pipes OSC 52 to client TTY)
```

## Key Bindings

### Prefix: `Ctrl+A`

After pressing `Ctrl+A`, use these keys:

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
| `Shift+←` | Move window left |
| `Shift+→` | Move window right |
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
| `y` | Copy to system clipboard (in copy mode) |
| Mouse drag | Copy to system clipboard |
| `Escape` | Exit copy mode |

Clipboard works through any nesting of tmux, mosh, ET, and SSH — see CLAUDE.md for architecture details.

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
