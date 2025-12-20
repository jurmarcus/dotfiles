# Starship Prompt Configuration

Customized cross-shell prompt using Catppuccin Frappe colors.

## Files

```
starship/.config/
└── starship.toml
```

## Features

- Multi-line prompt with OS icon, directory, git, languages
- Catppuccin Frappe palette (22 colors)
- Vim mode indicator
- Directory substitutions (Documents, Downloads, Developer, etc.)
- Custom symbols for 20+ languages

## Customization

### Change color scheme
Replace palette values in `[palettes.catppuccin_frappe]`

### Add/remove segments
Modify the `format` string at the top

### Adjust directory truncation
```toml
[directory]
truncation_length = 5
```

### Change git symbols
```toml
[git_status]
ahead = "⇡${count}"
behind = "⇣${count}"
```
