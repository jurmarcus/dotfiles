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
    │   ├── methylene-studio.brew    # AI workhorse
    │   ├── methylene-macbook.brew   # Travel laptop
    │   ├── methylene-mini.brew      # TV/media center
    │   └── allenj-mac.brew          # Minimal setup
    └── modules/                 # Category packages
        ├── base.brew            # Meta: terminal + security + browsers + utils
        ├── terminal.brew        # Shells, CLI tools, prompt, emulator (27 tools)
        ├── dev.brew             # Editors, VCS, runtimes, linting (neovim, vscodium)
        ├── remote.brew          # Remote access (mosh, et, tailscale)
        ├── fonts.brew           # Nerd fonts
        ├── ai.brew              # Claude, ChatGPT, Perplexity
        ├── local-llm.brew       # LM Studio, Ollama
        ├── browsers.brew        # Zen, Chrome, Safari extensions
        ├── security.brew        # 1Password
        ├── utils.brew           # Raycast, file tools, Karabiner, mas, duti
        ├── media.brew           # ffmpeg, iina, Phoenix Slides, Pocket Casts
        ├── knowledge.brew       # Obsidian, Anki
        ├── communication.brew   # Discord, Line
        └── hardware.brew        # Elgato, TourBox
```

## Host Profiles

| Host | Purpose | Modules |
|------|---------|---------|
| **studio** | AI workhorse | base, dev, remote, fonts, ai, local-llm, media, knowledge, communication, hardware |
| **macbook** | Travel | base, dev, remote, fonts, ai, media, knowledge, communication, hardware |
| **mini** | TV/Media | base, dev, remote, fonts, media |
| **allenj-mac** | Minimal | base, dev, remote, fonts, ai, media, hardware |

## Common Tasks

```bash
# Add package to module
echo 'brew "newtool"' >> .config/brew/modules/dev.brew

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
EOF
```

Then enable in your host file:
```bash
echo 'enable "gaming"' >> .config/brew/hosts/methylene-macbook.brew
```

## Meta-Modules

`base.brew` is a meta-module that enables common modules:
```ruby
enable "terminal"
enable "security"
enable "browsers"
enable "utils"
```

This keeps host configs DRY - just `enable "base"` instead of listing 4 modules.

## Finding App IDs for mas

```bash
mas search "app name"
mas list
```
