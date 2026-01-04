---
name: homebrew-modular
description: Manage Homebrew packages through modular dotfiles. Use when user asks to install brew packages, mentions brew install, or works with Homebrew. Never run brew install directly - always add to the appropriate module file.
---

# Homebrew Modular Management

When the user wants to install Homebrew packages, **never run `brew install` directly**. Instead, add packages to the modular Brewfile system in dotfiles.

## Structure

```
~/dotfiles/brew/.config/brew/
├── hosts/           # Per-machine profiles
│   ├── methylene-studio.brew
│   ├── methylene-macbook.brew
│   └── ...
└── modules/         # Category packages
    ├── terminal.brew    # CLI tools, shells
    ├── dev.brew         # Editors, runtimes, VCS
    ├── remote.brew      # SSH, mosh, tailscale
    ├── ai.brew          # AI apps (Claude, ChatGPT)
    ├── browsers.brew    # Web browsers
    ├── media.brew       # ffmpeg, video players
    ├── utils.brew       # Raycast, misc tools
    └── ...
```

## Module Selection Guide

| Package Type | Module | Examples |
|--------------|--------|----------|
| CLI tools, shells | `terminal.brew` | bat, eza, fd, ripgrep, zsh |
| Editors, languages | `dev.brew` | neovim, vscodium, node, python |
| Remote access | `remote.brew` | mosh, et, tailscale |
| AI apps | `ai.brew` | claude, chatgpt |
| Web browsers | `browsers.brew` | zen-browser, chrome |
| Media/video | `media.brew` | ffmpeg, iina |
| Productivity | `utils.brew` | raycast, karabiner |
| Fonts | `fonts.brew` | nerd fonts |
| Security | `security.brew` | 1password |

## Workflow

1. **Identify the right module** for the package type
2. **Add to module file**:
   ```bash
   # For CLI tools (formulae)
   echo 'brew "toolname"' >> ~/dotfiles/brew/.config/brew/modules/terminal.brew

   # For GUI apps (casks)
   echo 'cask "appname"' >> ~/dotfiles/brew/.config/brew/modules/utils.brew

   # For Mac App Store apps
   echo 'mas "App Name", id: 123456789' >> ~/dotfiles/brew/.config/brew/modules/utils.brew
   ```
3. **Run brewsync** to install:
   ```bash
   brewsync
   ```

## Finding Mac App Store IDs

```bash
mas search "app name"
mas list  # Shows installed apps with IDs
```

## Important Rules

- **NEVER** run `brew install <package>` directly
- **ALWAYS** add to the appropriate module file first
- **ALWAYS** run `brewsync` after adding packages
- Ask user which module if unclear
- Check if package is formula (`brew`) or cask (`cask`)

## Creating New Modules

If no existing module fits:
```bash
# Create module
cat > ~/dotfiles/brew/.config/brew/modules/gaming.brew << 'EOF'
# Gaming
cask "steam"
EOF

# Enable in host profile
echo 'enable "gaming"' >> ~/dotfiles/brew/.config/brew/hosts/methylene-studio.brew
```

## Checking Package Type

```bash
# Search for formula
brew search toolname

# Check if it's a cask
brew info --cask appname
```
