# =============================================================================
# Fish Shell Configuration
# =============================================================================
# Native features (no plugins needed):
#   - Autosuggestions (built-in)
#   - Syntax highlighting (built-in)
#   - History search (built-in, use Ctrl+R or up arrow)
#   - Tab completion (built-in, parses man pages automatically)
# =============================================================================

# =============================================================================
# Environment
# =============================================================================

set -gx PATH $HOME/.local/bin $PATH
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx EZA_TIME_STYLE long-iso

# uv - prefer managed Python installations
set -gx UV_PYTHON_PREFERENCE only-managed

# Homebrew
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew
set -gx PATH /opt/homebrew/bin /opt/homebrew/sbin $PATH
set -gx MANPATH /opt/homebrew/share/man $MANPATH
set -gx INFOPATH /opt/homebrew/share/info $INFOPATH

# Bun
set -gx BUN_INSTALL $HOME/.bun
set -gx PATH $BUN_INSTALL/bin $PATH

# opencode
set -gx PATH $HOME/.opencode/bin $PATH

# LM Studio
set -gx PATH $PATH $HOME/.lmstudio/bin

# fzf config
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --line-range :500 {}'"
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

# Dotfiles location
set -gx DOTFILES $HOME/dotfiles

# Template directory
set -gx TEMPLATE_DIR $HOME/.config/zsh/templates

# =============================================================================
# Tool Initialization
# =============================================================================

# fzf keybindings and completion
fzf --fish | source

# zoxide (smart cd)
zoxide init fish --cmd cd | source

# starship prompt
starship init fish | source

# =============================================================================
# Aliases - Modern CLI Replacements
# =============================================================================

# File operations
alias ls "eza --icons --group-directories-first"
alias ll "eza -la --icons --group-directories-first"
alias la "eza -a --icons --group-directories-first"
alias lt "eza --tree --icons"
alias cat bat
alias grep rg
alias find fd
alias diff delta
alias du dust
alias df duf

# System
alias top btop
alias htop btop
alias ps procs
alias help tldr
alias tmux zellij

# Editors
alias vim nvim
alias vi nvim
alias v nvim
alias nano nvim
alias code codium

# Version control
alias hg sl
alias g git
alias gs "git status"
alias ga "git add"
alias gc "git commit"
alias gp "git push"
alias gl "git log --oneline"
alias gd "git diff"
alias gds "git diff --staged"
alias lg lazygit

# GitHub CLI
alias pr "gh pr"
alias issue "gh issue"
alias repo "gh repo"

# Navigation
alias cdi zi
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
alias ..... "cd ../../../.."

# Python / uv
alias python "uv run python"
alias python3 "uv run python"
alias py "uv run python"
alias ipy "uvx ipython"
alias pip "uv pip"

# TypeScript / bun
alias ts "bun run"
alias tsx "bun x tsx"

# Tailscale quick machines
alias studio "tssh studio"
alias mstudio "mosh studio"

# =============================================================================
# SSH / Remote - Auto-start Zellij
# =============================================================================

if set -q SSH_CONNECTION; and not set -q ZELLIJ; and status is-interactive
    if command -q zellij
        zellij attach -c ssh
    end
end
