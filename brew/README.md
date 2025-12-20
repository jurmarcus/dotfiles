# Homebrew Configuration

Modular Brewfile system with automatic host detection.

## How It Works

1. `~/.Brewfile` (symlinked from `brew/.Brewfile`) detects hostname
2. Loads matching host profile from `hosts/{hostname}.brew`
3. Host profile calls `enable "module"` for each category
4. Modules from `modules/*.brew` are included

## Files

```
brew/
├── .Brewfile                    # Main loader (Ruby DSL)
└── .config/brew/
    ├── hosts/                   # Per-machine profiles
    │   ├── methylene-macbook.brew
    │   ├── methylene-studio.brew
    │   └── allenj-mac.brew
    └── modules/                 # Category packages
        ├── ai.brew              # Claude, ChatGPT, Perplexity
        ├── browsers.brew        # Zen, Chrome, Safari extensions
        ├── communication.brew   # Discord, Line
        ├── developer.brew       # CLI tools, fonts (67 items)
        ├── editors.brew         # VSCodium
        ├── entertainment.brew   # iina, Pocket Casts
        ├── hardware.brew        # Elgato, TourBox, Karabiner
        ├── learning.brew        # Anki
        ├── photography.brew     # ffmpeg, Phoenix Slides
        ├── security.brew        # 1Password, 1Password-CLI
        └── utils.brew           # Raycast, Obsidian, etc.
```

## Common Tasks

```bash
# Add package to module
echo 'brew "newtool"' >> .config/brew/modules/developer.brew

# Add cask
echo 'cask "newapp"' >> .config/brew/modules/utils.brew

# Add Mac App Store app (need app ID)
echo 'mas "App Name", id: 123456789' >> .config/brew/modules/utils.brew

# Install all packages
brew bundle --global

# Check for orphans (installed but not in Brewfile)
brew bundle cleanup --global

# Remove orphans
brew bundle cleanup --global --force

# Or use the shell function
brewsync        # Install + show orphans
brewsync clean  # Install + remove orphans
```

## Creating New Module

```bash
cat > .config/brew/modules/gaming.brew << 'EOF'
# Gaming
cask "steam"
cask "discord"
EOF
```

Then enable in your host file:
```bash
echo 'enable "gaming"' >> .config/brew/hosts/methylene-macbook.brew
```

## Host Profiles

- **methylene-macbook.brew** - Full development setup (all 11 modules)
- **methylene-studio.brew** - Same + local LLM tools (LM Studio, Ollama)
- **allenj-mac.brew** - Minimal setup (8 modules, no editors/communication/learning)

## Finding App IDs for mas

```bash
mas search "app name"
mas list
```
