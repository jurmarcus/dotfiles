# Dotfiles Documentation for Claude

This file provides context for Claude Code when making adjustments to dotfiles.

## Repository Location

Main dotfiles repository: `/Users/methylene/dotfiles`

## Directory Structure

```
dotfiles/
├── brew/          # Homebrew configuration (modular with host-specific profiles)
├── ghostty/       # Ghostty terminal emulator configuration
├── macos/         # macOS-specific settings and preferences
├── nvim/          # Neovim text editor configuration
├── stow/          # GNU Stow configuration for symlink management
└── zsh/           # Zsh shell configuration
    ├── .zshenv    # Environment variables (loaded first)
    ├── .zprofile  # Login shell initialization
    └── .config/zsh/
        └── .zshrc # Main shell configuration
```

## Setup Instructions

### Fresh Installation

1. Clone the dotfiles repository:
   ```bash
   git clone <repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the bootstrap script:
   ```bash
   ./bootstrap.sh
   ```

3. Install Homebrew packages:
   ```bash
   brew bundle --file=~/.Brewfile
   ```

4. Use GNU Stow to create symlinks:
   ```bash
   cd ~/dotfiles
   stow zsh ghostty nvim
   ```

5. Restart your shell for changes to take effect

### Prerequisites
- macOS (current setup is macOS-specific)
- Homebrew package manager
- Git for version control

## Installed Tools & Applications

### Development Tools (CLI)

- **eza** - Modern replacement for `ls` with colors and git integration
- **fzf** - Fuzzy finder for command-line
- **mas** - Mac App Store command-line interface
- **neovim** - Modern Vim-based text editor
- **sapling** - Meta's source control client
- **starship** - Fast, customizable shell prompt
- **stow** - Symlink manager for dotfiles
- **tmux** - Terminal multiplexer
- **uv** - Fast Python package installer and resolver
- **zoxide** - Smarter `cd` command with frecency
- **zsh** - Unix shell
- **mosh** - Mobile shell with roaming and local echo
- **gh** - GitHub CLI tool
- **git** - Version control system
- **npm** - Node.js package manager
- **bun** - Fast JavaScript runtime and package manager

### Editors & IDEs

- **Visual Studio Code** - Code editor (using OSS build)
- **Neovim** - Terminal-based editor

### Terminal Emulators

- **Ghostty** - GPU-accelerated terminal emulator (primary)

### Security & Privacy

- **1Password** - Password manager (with CLI and Safari extension)
- **uBlock Origin Lite** - Content blocker for Safari
- **AdGuard for Safari** - Additional content blocker

### Browsers

- **Zen Browser** - Privacy-focused browser
- **Google Chrome** - Web browser

### Productivity & Utilities

- **AppCleaner** - Application uninstaller
- **ChatGPT** - AI assistant desktop app
- **DeepL** - Translation tool
- **Ice** (jordanbaird-ice) - Menu bar manager
- **LocalSend** - Local file sharing
- **Raycast** - Spotlight replacement and productivity tool
- **Obsidian** - Note-taking and knowledge management
- **The Unarchiver** - Archive extraction utility

### Communication

- **Discord** - Team chat and voice
- **Line** - Messaging app (popular in Japan/Asia)

### Learning

- **Anki** - Spaced repetition flashcard system

### Hardware Support

- **Elgato Camera Hub** - Camera control software
- **Elgato Stream Deck** - Stream Deck controller software
- **Elgato Wave Link** - Audio mixer software
- **TourBox Console** - TourBox controller software

### Photography

- **Phoenix Slides** - Photo slideshow software

### Entertainment

- **IINA** - Modern media player for macOS
- **Pocket Casts** - Podcast player
- **Brain.fm** - Focus music app

## Zsh Configuration

### File Locations

- **`.zshenv`**: `/Users/methylene/dotfiles/zsh/.zshenv`
  - Symlinked to: `~/.zshenv`
  - Purpose: Sets up XDG base directories and relocates zsh config to XDG-compliant location
  - Defines: `ZDOTDIR="$XDG_CONFIG_HOME/zsh"`

- **`.zprofile`**: `/Users/methylene/dotfiles/zsh/.zprofile`
  - Symlinked to: `~/.zprofile`
  - Purpose: Initializes Homebrew environment

- **`.zshrc`**: `/Users/methylene/dotfiles/zsh/.config/zsh/.zshrc`
  - Symlinked to: `~/.config/zsh/.zshrc` (via `ZDOTDIR`)
  - Purpose: Main shell configuration, sources modular config files

### XDG Base Directory Specification

This setup follows XDG standards:
- `XDG_CONFIG_HOME`: `~/.config`
- `XDG_CACHE_HOME`: `~/.cache`
- `XDG_DATA_HOME`: `~/.local/share`
- `XDG_STATE_HOME`: `~/.local/state`

### Zsh Config Structure

The `.zshrc` sources additional config files from `$ZDOTDIR` (`~/.config/zsh/`):
- `options.zsh` - Shell options and behavior
- `exports.zsh` - Environment variables
- `keybinds.zsh` - Keyboard shortcuts and bindings
- `completion.zsh` - Command completion configuration
- `tooling.zsh` - Tool-specific initialization (fzf, zoxide, etc.)
- `plugin-manager.zsh` - Antidote plugin manager configuration
- `aliases/*.zsh` - Command aliases organized by category
- `functions/*.zsh` - Custom shell functions

## Homebrew Package Management

### Modular Structure

Brewfile uses a modular, host-based system:
- **Location**: `~/dotfiles/brew/.config/brew/`
- **Main file**: `~/.Brewfile` (symlinked)
- **Host file**: `hosts/methylene-macbook.brew` (current machine)
- **Modules**: Individual category files in `modules/` directory

### Available Modules

- `browsers.brew` - Web browsers
- `communication.brew` - Chat and messaging apps
- `developer.brew` - Development tools and CLIs
- `editors.brew` - Text editors and IDEs
- `entertainment.brew` - Media players and entertainment
- `hardware.brew` - Hardware-specific software
- `learning.brew` - Educational tools
- `photography.brew` - Photo management and editing
- `security.brew` - Security and privacy tools
- `utils.brew` - General utilities and productivity apps

### Adding New Packages

1. Add to appropriate module in `~/dotfiles/brew/.config/brew/modules/`
2. Or enable/disable modules in your host file: `~/dotfiles/brew/.config/brew/hosts/methylene-macbook.brew`
3. Run `brew bundle --file=~/.Brewfile` to install

## SSH Configuration

SSH config location: `~/.ssh/config`
- Uses ed25519 keys by default
- Automatically adds keys to agent and keychain
- Includes server keep-alive settings

## Important Notes for Claude

### When Modifying Dotfiles:

1. **Never modify files in `~/.config/` or `~/` directly** - these are symlinks managed by stow
2. **Always modify the source files in `/Users/methylene/dotfiles/`**
3. **Zsh config changes should be made in**:
   - `/Users/methylene/dotfiles/zsh/.zshenv` for environment setup
   - `/Users/methylene/dotfiles/zsh/.zprofile` for login shell setup
   - `/Users/methylene/dotfiles/zsh/.config/zsh/` for runtime configuration

### Stow Management

Files are symlinked from `dotfiles/` to `~/` using GNU Stow. The structure in `dotfiles/zsh/` mirrors the target structure in the home directory.

### Common Tasks:

- **Add environment variable**: Edit `/Users/methylene/dotfiles/zsh/.config/zsh/exports.zsh`
- **Add alias**: Create or edit files in `/Users/methylene/dotfiles/zsh/.config/zsh/aliases/`
- **Add function**: Create files in `/Users/methylene/dotfiles/zsh/.config/zsh/functions/`
- **Modify shell options**: Edit `/Users/methylene/dotfiles/zsh/.config/zsh/options.zsh`
- **Modify initial environment**: Edit `/Users/methylene/dotfiles/zsh/.zshenv`
- **Install new package**: Add to appropriate Brewfile module in `~/dotfiles/brew/.config/brew/modules/`

## Development Workflows

### Starting New Projects

1. Navigate to project directory: `cd ~/code`
2. Projects organized by category (personal/work/experiments)
3. Initialize git repo if needed: `git init`
4. Use GitHub CLI for repo creation: `gh repo create`

### Shell Workflow

- Use **zoxide** (`z <partial-name>`) for fast directory navigation
- Use **fzf** (Ctrl+R) for fuzzy command history search
- Use **eza** instead of `ls` for colorized directory listings
- Use **starship** prompt for git status and context info

### Editor Workflow

- Primary editor: **Neovim** for terminal work
- Alternative: **VS Code OSS** for GUI-based editing
- Neovim config location: `~/dotfiles/nvim/.config/nvim/`

### Python Development

- Use **uv** for fast package installation and environment management
- UV cache: `~/.cache/uv`

### Node.js Development

- **npm** for traditional Node.js projects
- **bun** for faster alternative runtime and package management

## Tool Alternatives & Rationale

### Why These Tools?

- **eza over ls**: Color-coding, git integration, better defaults
- **zoxide over cd**: Learns frequently used directories, faster navigation
- **starship over oh-my-zsh**: Faster, minimal, cross-shell compatible
- **neovim over vim**: Modern architecture, Lua configuration, better plugin system
- **ghostty over iTerm2/Alacritty**: GPU-accelerated, native macOS, better performance
- **stow over custom scripts**: Standard tool, simple, widely understood
- **1Password over other managers**: Cross-platform, CLI support, developer-friendly
- **raycast over spotlight**: More powerful, extensible, clipboard history
- **uv over pip**: Significantly faster, better dependency resolution
- **bun over node**: Faster runtime, built-in bundler and test runner

## Troubleshooting Guide

### Symlinks Not Working

```bash
# Re-stow specific package
cd ~/dotfiles
stow -R zsh  # -R flag restows (re-creates symlinks)

# Check what stow would do without making changes
stow -n -v zsh
```

### Homebrew Packages Not Installing

```bash
# Update Homebrew first
brew update

# Try installing again
brew bundle --file=~/.Brewfile

# Check for conflicts
brew doctor
```

### Zsh Configuration Not Loading

```bash
# Check if symlinks exist
ls -la ~/.zshenv ~/.zprofile
ls -la ~/.config/zsh/.zshrc

# Verify ZDOTDIR is set
echo $ZDOTDIR  # Should output: /Users/methylene/.config/zsh

# Source config manually to check for errors
source ~/.zshenv
source ~/.zprofile
source ~/.config/zsh/.zshrc
```

### Shell Prompt Not Showing Up

```bash
# Verify starship is installed
which starship

# Check if starship is initialized in zshrc
grep starship ~/.config/zsh/.zshrc
```

### Git Operations Failing

```bash
# Check git config
git config --list

# Check SSH keys
ls -la ~/.ssh/
ssh -T git@github.com

# Check SSH config
cat ~/.ssh/config
```

### Permissions Issues

```bash
# Fix .ssh permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
```

### Cache Cleanup

```bash
# Clear npm cache
npm cache clean --force

# Clear Homebrew cache
brew cleanup

# Clear general caches (be careful)
rm -rf ~/.cache/*
```

### Antidote Plugin Manager Issues

```bash
# Reload antidote
antidote update
source ~/.config/zsh/.zshrc
```

## Maintenance Tasks

### Regular Updates

```bash
# Update Homebrew and packages
brew update && brew upgrade

# Update Homebrew casks
brew upgrade --cask

# Clean up old versions
brew cleanup
```

### Dotfiles Updates

```bash
# Commit changes
cd ~/dotfiles
git add .
git commit -m "Update configuration"
git push
```

### Plugin Updates

Plugins are managed by Antidote and updated automatically on shell restart
