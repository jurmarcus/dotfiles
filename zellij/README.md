# Zellij Configuration

Terminal multiplexer (tmux replacement) with tmux-style Ctrl+a prefix.

Based on [merikan/.dotfiles](https://github.com/merikan/.dotfiles) with Catppuccin Frappé theme.

## Files

```
zellij/.config/zellij/
├── config.kdl           # Keybindings & settings
├── layouts/
│   └── terminal.kdl     # Default layout with zjstatus
└── plugins/
    └── zjstatus.wasm    # Status bar plugin
```

## Key Bindings

### Prefix: `Ctrl+a` (tmux-style)

After pressing `Ctrl+a`, use these keys:

#### Panes
| Key | Action |
|-----|--------|
| `n` | New pane |
| `N` | New stacked pane |
| `-` / `_` | Split down |
| `\|` / `\` / `s` | Split right |
| `x` | Close pane |
| `z` | Fullscreen toggle |
| `f` | Float toggle |
| `F` | Embed/float toggle |
| `h/j/k/l` | Focus pane |
| `o` | Focus next pane |
| `r` | Rename pane |
| `i` | Pin pane |

#### Tabs
| Key | Action |
|-----|--------|
| `c` | New tab (+ rename) |
| `X` | Close tab |
| `R` | Rename tab |
| `H/L` | Previous/next tab |
| `1-9` | Go to tab |
| `</>` | Move tab left/right |

#### Session
| Key | Action |
|-----|--------|
| `d` | Detach |
| `w` | Session manager |
| `Ctrl+q` | Quit |

#### Other
| Key | Action |
|-----|--------|
| `[` | Scroll mode |
| `]` | Edit scrollback |
| `m` | Resize mode |
| `M` | Move mode |
| `Space` | Next layout |

### Quick Keys (No Prefix)

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Focus pane |
| `Alt+f` | Toggle floating panes |

### Mode Switching (from Tmux mode)

| Key | Mode |
|-----|------|
| `Ctrl+p` | Pane |
| `Ctrl+t` | Tab |
| `Ctrl+n` | Resize |
| `Ctrl+s` | Scroll |
| `Ctrl+o` | Session |
| `Ctrl+m` | Move |
| `Ctrl+g` | Locked |

## Theme

Catppuccin Frappé with zjstatus bar at bottom showing:
- Session name
- Current mode
- Tabs
- User@host
- Date/time (Asia/Tokyo)
