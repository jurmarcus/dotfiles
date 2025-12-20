# Zellij Configuration

Terminal multiplexer (tmux replacement) with vim-style navigation.

## Files

```
zellij/.config/zellij/
└── config.kdl
```

## Modes

- **normal** - Default, basic navigation
- **pane** (Ctrl+p) - Pane management
- **tab** (Ctrl+t) - Tab management
- **resize** (Ctrl+n) - Resize panes
- **scroll** (Ctrl+s) - Scroll/search
- **locked** (Ctrl+g) - Pass all keys to terminal

## Key Bindings

### Normal Mode
- `Alt+h/j/k/l` - Focus pane
- `Alt+[/]` - Previous/next tab
- `Alt+1-9` - Go to tab

### Pane Mode (Ctrl+p)
- `n/d` - New pane down/right
- `x` - Close pane
- `f` - Fullscreen
- `w` - Float/unfloat

### Tab Mode (Ctrl+t)
- `n` - New tab
- `x` - Close tab
- `r` - Rename
- `1-9` - Go to tab

### Scroll Mode (Ctrl+s)
- `j/k` - Scroll
- `Ctrl+f/b` - Page down/up
- `s` - Search
- `e` - Edit in $EDITOR

## SSH Auto-Attach

SSH sessions automatically attach to Zellij session named "ssh".
