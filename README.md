# dotfiles

> Personal macOS development environment configuration using GNU Stow, modular Homebrew, and XDG-compliant directory structure.

[![macOS](https://img.shields.io/badge/macOS-Compatible-blue.svg)](https://www.apple.com/macos/)
[![GNU Stow](https://img.shields.io/badge/managed%20by-GNU%20Stow-green.svg)](https://www.gnu.org/software/stow/)
[![Sapling](https://img.shields.io/badge/VCS-Sapling-orange.svg)](https://sapling-scm.com/)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Components](#components)
  - [Homebrew (Modular)](#homebrew-modular)
  - [Zsh Configuration](#zsh-configuration)
  - [VSCodium Extensions](#vscodium-extensions)
  - [Ghostty Terminal](#ghostty-terminal)
  - [Neovim](#neovim)
  - [macOS Settings](#macos-settings)
- [Usage](#usage)
- [Customization](#customization)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## Overview

This repository contains my personal macOS development environment configuration. It's designed to be:

- **Modular**: Organize packages by category (AI tools, browsers, developer tools, etc.)
- **Host-aware**: Different configurations for different machines
- **XDG-compliant**: Follows XDG Base Directory specification
- **Reproducible**: Automated setup via bootstrap script
- **Version-controlled**: Using Sapling (sl) for a better Git experience

## Features

- 🎯 **Modular Homebrew management** - Organize formulae and casks by category
- 🏠 **Host-specific profiles** - Different package sets for different machines
- 📁 **XDG Base Directory compliance** - Clean home directory
- 🔗 **GNU Stow** - Symlink management without complex scripts
- 🐚 **Modern Zsh setup** - Fast, modular, well-organized shell configuration
- 🎨 **Ghostty terminal** - GPU-accelerated terminal emulator
- 🔧 **VSCodium extension management** - Track and sync editor extensions
- ⚡ **Fast tools** - Modern alternatives (eza, zoxide, starship, uv, bun)
- 🌳 **Sapling VCS** - Better Git interface with improved UX

## Prerequisites

- **macOS** (tested on macOS 15.x)
- **Xcode Command Line Tools** (installed automatically by bootstrap script)
- **Homebrew** (installed automatically by bootstrap script)

## Quick Start

### Fresh Installation

```bash
# Clone the repository
git clone https://github.com/jurmarcus/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the bootstrap script
./bootstrap.sh

# Restart your shell
exec zsh
```

### What the bootstrap script does:

1. ✅ Installs Xcode Command Line Tools (if needed)
2. ✅ Installs Homebrew (if needed)
3. ✅ Installs GNU Stow
4. ✅ Creates symlinks for all dotfiles using Stow
5. ✅ Installs Homebrew packages via `brew bundle`
6. ✅ Applies macOS settings (if available)

### Manual Installation

If you prefer to install components individually:

```bash
# Install Homebrew packages
brew bundle --file=~/.Brewfile

# Stow specific packages
cd ~/dotfiles
stow zsh        # Shell configuration
stow ghostty    # Terminal emulator
stow nvim       # Neovim configuration
stow vscodium   # VSCodium settings

# Install VSCodium extensions
cd ~/dotfiles/vscodium
./install-extensions.sh
```

---

## Directory Structure

```
dotfiles/
├── bootstrap.sh              # Automated setup script
├── .gitignore               # Git ignore rules
│
├── brew/                    # Homebrew configuration
│   └── .config/brew/
│       ├── hosts/           # Host-specific profiles
│       │   ├── methylene-macbook.brew
│       │   └── allenj-mac.brew
│       └── modules/         # Package modules by category
│           ├── ai.brew
│           ├── browsers.brew
│           ├── communication.brew
│           ├── developer.brew
│           ├── editors.brew
│           ├── entertainment.brew
│           ├── hardware.brew
│           ├── learning.brew
│           ├── photography.brew
│           ├── security.brew
│           └── utils.brew
│   └── .Brewfile           # Main Brewfile (modular loader)
│
├── zsh/                     # Zsh shell configuration
│   ├── .zshenv             # Environment setup (XDG dirs)
│   ├── .zprofile           # Login shell initialization
│   └── .config/zsh/
│       ├── .zshrc          # Main configuration file
│       ├── options.zsh     # Shell options
│       ├── exports.zsh     # Environment variables
│       ├── keybinds.zsh    # Key bindings
│       ├── completion.zsh  # Completion settings
│       ├── tooling.zsh     # Tool initializations
│       ├── plugin-manager.zsh  # Antidote plugins
│       ├── aliases/        # Command aliases
│       └── functions/      # Custom functions
│
├── vscodium/               # VSCodium configuration
│   ├── extensions          # Extension list
│   └── install-extensions.sh  # Installation script
│
├── ghostty/                # Ghostty terminal config
│   └── .config/ghostty/
│       └── config
│
├── nvim/                   # Neovim configuration
│   └── .config/nvim/
│
├── macos/                  # macOS system settings
│   └── macos.sh
│
└── stow/                   # Stow configuration
    └── .stowrc
```

---

## Components

### Homebrew (Modular)

This setup uses a **modular Homebrew system** that allows organizing packages by category and creating host-specific configurations.

#### How it works

**Main Brewfile** (`~/.Brewfile`):
- Detects current hostname automatically
- Loads corresponding host profile from `hosts/`
- Processes `enable()` directives to include modules

**Host Profiles** (`hosts/methylene-macbook.brew`):
```ruby
enable "ai"
enable "browsers"
enable "developer"
enable "editors"
# ... more modules
```

**Modules** (`modules/developer.brew`):
```ruby
# Shell & Terminal
brew "zsh"
brew "starship"
cask "ghostty"

# Version Control
brew "sapling"
brew "gh"
```

#### Available Modules

| Module | Description |
|--------|-------------|
| **ai.brew** | AI coding agents (Claude Code) and assistants (Claude, Perplexity) |
| **browsers.brew** | Web browsers and Safari extensions |
| **communication.brew** | Messaging apps (Discord, Line) |
| **developer.brew** | CLI development tools, terminal emulators, fonts |
| **editors.brew** | Code editors (VSCodium) |
| **entertainment.brew** | Media players and podcasts |
| **hardware.brew** | Hardware control software (Elgato, TourBox) |
| **learning.brew** | Educational tools (Anki) |
| **photography.brew** | Media processing (ffmpeg) and photo tools |
| **security.brew** | Password managers (1Password) |
| **utils.brew** | Productivity tools, file managers, utilities |

#### Managing Packages

**Add a package to a module:**
```bash
# Edit the appropriate module file
vim ~/dotfiles/brew/.config/brew/modules/developer.brew

# Add your package
brew "newtool"

# Install
brew bundle --file=~/.Brewfile
```

**Create a new module:**
```bash
# Create new module file
cat > ~/dotfiles/brew/.config/brew/modules/gaming.brew <<EOF
# Gaming Tools
cask "steam"
cask "discord"
EOF

# Enable in your host profile
echo 'enable "gaming"' >> ~/dotfiles/brew/.config/brew/hosts/$(scutil --get ComputerName | tr '[:upper:]' '[:lower:]').brew

# Install
brew bundle --file=~/.Brewfile
```

**Create a host profile for a new machine:**
```bash
# Create new host file (replace 'new-macbook' with your hostname)
cat > ~/dotfiles/brew/.config/brew/hosts/new-macbook.brew <<EOF
enable "ai"
enable "browsers"
enable "developer"
EOF

# The Brewfile will automatically detect and use it on that machine
```

---

### Zsh Configuration

Modern, modular Zsh setup with XDG Base Directory compliance.

#### File Locations

- `~/.zshenv` → Symlink to `~/dotfiles/zsh/.zshenv`
- `~/.zprofile` → Symlink to `~/dotfiles/zsh/.zprofile`
- `~/.config/zsh/.zshrc` → Symlink to `~/dotfiles/zsh/.config/zsh/.zshrc`

#### XDG Base Directories

```bash
XDG_CONFIG_HOME="$HOME/.config"      # Configuration files
XDG_CACHE_HOME="$HOME/.cache"        # Cache files
XDG_DATA_HOME="$HOME/.local/share"   # Data files
XDG_STATE_HOME="$HOME/.local/state"  # State files
```

#### Modular Configuration

The `.zshrc` sources additional configuration files:

```zsh
source "$ZDOTDIR/options.zsh"          # Shell options
source "$ZDOTDIR/exports.zsh"          # Environment variables
source "$ZDOTDIR/keybinds.zsh"         # Key bindings
source "$ZDOTDIR/completion.zsh"       # Completions
source "$ZDOTDIR/tooling.zsh"          # Tool initialization
source "$ZDOTDIR/plugin-manager.zsh"   # Antidote plugins
source "$ZDOTDIR/aliases/"*.zsh        # All aliases
source "$ZDOTDIR/functions/"*.zsh      # All functions
```

#### Key Tools

- **starship** - Fast, minimal prompt
- **zoxide** - Smarter cd with frecency (`z <partial-name>`)
- **fzf** - Fuzzy finder (Ctrl+R for history)
- **eza** - Modern ls replacement
- **atuin** - Shell history sync and search
- **antidote** - Fast plugin manager

#### Customization

**Add environment variable:**
```bash
echo 'export MY_VAR="value"' >> ~/dotfiles/zsh/.config/zsh/exports.zsh
```

**Add alias:**
```bash
echo 'alias myalias="command"' >> ~/dotfiles/zsh/.config/zsh/aliases/custom.zsh
```

**Add custom function:**
```bash
cat > ~/dotfiles/zsh/.config/zsh/functions/myfunc.zsh <<'EOF'
myfunc() {
  echo "My custom function"
}
EOF
```

---

### VSCodium Extensions

Declarative extension management for VSCodium (open-source VS Code).

#### Extension List

Located at `~/dotfiles/vscodium/extensions`:

```
# AI Coding Assistants
anthropic.claude-code
google.gemini-cli-vscode-ide-companion
openai.chatgpt

# Themes & Icons
catppuccin.catppuccin-vsc
catppuccin.catppuccin-vsc-icons

# Productivity Tools
pedro-bronsveld.anki-editor
```

#### Install All Extensions

```bash
cd ~/dotfiles/vscodium
./install-extensions.sh
```

#### Managing Extensions

**List currently installed extensions:**
```bash
codium --list-extensions
```

**Add new extension:**
```bash
# Install extension
codium --install-extension publisher.extension-name

# Add to extensions file
echo "publisher.extension-name" >> ~/dotfiles/vscodium/extensions
```

**Update extensions file from current installation:**
```bash
codium --list-extensions > ~/dotfiles/vscodium/extensions
# Then add organizational comments
```

---

### Ghostty Terminal

GPU-accelerated, native macOS terminal emulator.

**Configuration:** `~/.config/ghostty/config`

Features:
- GPU acceleration for smooth rendering
- Native macOS integration
- Fast and lightweight
- Highly customizable

---

### Neovim

Modern Vim-based text editor configuration.

**Configuration:** `~/.config/nvim/`

---

### macOS Settings

System preferences and defaults configured via `macos/macos.sh`.

**Apply settings:**
```bash
bash ~/dotfiles/macos/macos.sh
```

---

## Usage

### Daily Workflow

**Update everything:**
```bash
brew update && brew upgrade
brew upgrade --cask
brew cleanup
```

**Add new tool:**
```bash
# Add to appropriate module
vim ~/dotfiles/brew/.config/brew/modules/developer.brew

# Install
brew bundle --file=~/.Brewfile

# Commit changes
sl add -A
sl commit -m "Add new developer tool"
sl push
```

**Sync to new machine:**
```bash
git clone https://github.com/jurmarcus/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

---

## Customization

### Creating Your Own Setup

1. **Fork this repository**
2. **Update Homebrew modules** with your preferred tools
3. **Create your host profile** in `brew/.config/brew/hosts/`
4. **Customize Zsh configuration** in `zsh/.config/zsh/`
5. **Update VSCodium extensions** list
6. **Modify bootstrap.sh** for your needs

### Host-Specific Customization

Different machines can have different package sets:

```ruby
# ~/dotfiles/brew/.config/brew/hosts/work-laptop.brew
enable "ai"
enable "browsers"
enable "developer"
enable "communication"

# ~/dotfiles/brew/.config/brew/hosts/personal-mac.brew
enable "ai"
enable "browsers"
enable "developer"
enable "entertainment"
enable "gaming"
```

---

## Maintenance

### Update Packages

```bash
# Update Homebrew packages
brew update && brew upgrade

# Update VSCodium extensions
codium --update-extensions

# Update Zsh plugins
# Plugins auto-update on shell start via Antidote
```

### Backup Current Configuration

```bash
# Export current Homebrew packages
brew bundle dump --file=~/Desktop/Brewfile.backup

# Export VSCodium extensions
codium --list-extensions > ~/Desktop/extensions.backup
```

### Clean Up

```bash
# Remove old Homebrew versions
brew cleanup

# Remove unused packages
brew autoremove

# Check for issues
brew doctor
```

---

## Troubleshooting

### Symlinks Not Working

```bash
# Re-stow specific package
cd ~/dotfiles
stow -R zsh  # -R flag restows (recreates symlinks)

# Check what stow would do without making changes
stow -n -v zsh
```

### Brewfile Not Loading Modules

```bash
# Check current hostname
scutil --get ComputerName

# Verify host file exists
ls -la ~/dotfiles/brew/.config/brew/hosts/

# Test Brewfile manually
brew bundle --file=~/.Brewfile --verbose
```

### Zsh Configuration Not Loading

```bash
# Verify ZDOTDIR is set
echo $ZDOTDIR  # Should output: /Users/yourusername/.config/zsh

# Check symlinks
ls -la ~/.zshenv ~/.zprofile
ls -la ~/.config/zsh/.zshrc

# Source manually to check for errors
source ~/.zshenv
source ~/.zprofile
source ~/.config/zsh/.zshrc
```

### VSCodium Extensions Not Installing

```bash
# Check codium command exists
which codium

# Install extension manually
codium --install-extension extension-id

# Check extension directory
ls -la ~/.vscode-oss/extensions/
```

### Version Control Issues

```bash
# Check sl/git status
sl status

# Verify repository configuration
sl config --list

# Test SSH connection
ssh -T git@github.com
```

---

## FAQ

**Q: Why Sapling (sl) instead of Git?**
A: Sapling provides a better user experience with intuitive commands while working seamlessly with Git backends. Use `sl` commands for all version control operations.

**Q: Why GNU Stow?**
A: Stow is simple, standard, and widely understood. It creates symlinks without complex scripts, making it easy to see exactly what's linked where.

**Q: Why modular Homebrew setup?**
A: It allows organizing packages by purpose, creating host-specific configurations, and maintaining a clean, understandable package list.

**Q: Can I use this on Linux?**
A: The structure is portable, but some packages (especially casks and mas apps) are macOS-specific. You'd need to adjust the Homebrew modules.

**Q: How do I update just one module?**
A: Edit the module file, then run `brew bundle --file=~/.Brewfile`. Homebrew will install missing packages without affecting others.

**Q: What if I don't want certain modules?**
A: Simply remove or comment out the `enable "module-name"` line in your host profile.

**Q: How do I share config between machines but keep some private?**
A: Create a `private/` directory (add to .gitignore), put sensitive configs there, and source them conditionally in your shell config.

**Q: Why XDG Base Directory compliance?**
A: It keeps your home directory clean by organizing configs in `~/.config`, data in `~/.local/share`, and cache in `~/.cache`.

---

## Version Control with Sapling

This repository uses **Sapling (sl)** commands for version control:

```bash
sl status              # Check working directory status
sl commit -m "msg"     # Create commit
sl push                # Push to remote
sl pull                # Pull from remote
sl log                 # View commit history
sl diff                # View changes
```

> **Important:** Always use `sl` commands instead of `git` commands when working with this repository.

---

## Credits

- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink management
- [Homebrew](https://brew.sh/) - Package management
- [Sapling](https://sapling-scm.com/) - Version control
- [Starship](https://starship.rs/) - Shell prompt
- [Ghostty](https://ghostty.org/) - Terminal emulator

---

## License

This is personal configuration. Feel free to fork and adapt for your own use.

---

**Made with ❤️ and [Claude Code](https://claude.com/claude-code)**
