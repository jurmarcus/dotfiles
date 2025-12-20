# Ghostty Terminal Configuration

GPU-accelerated terminal emulator for macOS.

## Files

```
ghostty/.config/ghostty/
└── config
```

## Current Settings

- **Font**: FiraCode Nerd Font Mono, size 14
- **Theme**: Catppuccin Frappe
- **macOS**: Option as Alt, tabs in title bar
- **Keybinds**: Alt+arrows unbound (pass to Zellij)

## Common Customizations

```
# Change font
font-family = "JetBrainsMono Nerd Font"
font-size = 13

# Change theme
theme = catppuccin-mocha

# Background opacity
background-opacity = 0.95

# Padding
window-padding-x = 10
window-padding-y = 10
```

## Why Option as Alt?

Zellij uses Alt key for navigation. Without `macos-option-as-alt = true`, Option+key produces special characters instead of Alt+key sequences.
