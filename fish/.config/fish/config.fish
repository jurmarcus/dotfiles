# =============================================================================
# Fish Shell Configuration
# =============================================================================
# No plugins needed - fish has autosuggestions, syntax highlighting,
# history search, and tab completion built in.
# =============================================================================

# =============================================================================
# PATH (fish_add_path is idempotent - no duplicates)
# =============================================================================

fish_add_path $HOME/.local/bin
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
fish_add_path $HOME/.bun/bin
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.lmstudio/bin

# =============================================================================
# Environment
# =============================================================================

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx EZA_TIME_STYLE long-iso
set -gx UV_PYTHON_PREFERENCE only-managed

# Homebrew
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew
set -gx MANPATH /opt/homebrew/share/man $MANPATH
set -gx INFOPATH /opt/homebrew/share/info $INFOPATH

# fzf
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --line-range :500 {}'"
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

# Dotfiles
set -gx DOTFILES $HOME/dotfiles
set -gx TEMPLATE_DIR $HOME/.config/fish/templates

# =============================================================================
# Tool Initialization
# =============================================================================

fzf --fish | source
zoxide init fish --cmd cd | source
starship init fish | source

# =============================================================================
# Abbreviations (expand inline - shows real command in history)
# =============================================================================

# Sapling (aliased as sl, muscle memory from hg)
abbr -a ss "sl status"
abbr -a sa "sl add"
abbr -a sc "sl commit"
abbr -a sp "sl push"
abbr -a spl "sl pull"
abbr -a slog "sl log -l 10"

# GitHub CLI
abbr -a pr "gh pr"
abbr -a issue "gh issue"
abbr -a repo "gh repo"

# Python / uv
abbr -a pyr "uv run python"
abbr -a pyt "uv run pytest"
abbr -a pya "uv add"
abbr -a uvr uvx

# TypeScript / bun
abbr -a tsr "bun run"
abbr -a tst "bun test"

# Zellij
abbr -a zls "zellij list-sessions"
abbr -a zssh "zellij attach -c ssh"

# =============================================================================
# Aliases (shadow existing commands)
# =============================================================================

# Modern CLI replacements
alias ls "eza --icons --group-directories-first"
alias ll "eza -la --icons --group-directories-first"
alias la "eza -a --icons --group-directories-first"
alias lt "eza --tree --icons"
alias cat bat
alias grep rg
alias find fd
alias du dust
alias df duf
alias top btop
alias htop btop
alias ps procs
alias help tldr
alias hg sl
alias tmux zellij

# Editors
alias vim nvim
alias vi nvim
alias v nvim
alias nano nvim
alias code codium

# Python
alias python "uv run python"
alias py "uv run python"
alias pip "uv pip"
alias ipy "uvx ipython"

# TypeScript
alias ts "bun run"
alias tsx "bun x tsx"

# Navigation
alias cdi zi
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."

# Remote
alias studio "tssh studio"
alias mstudio "mosh studio"

# =============================================================================
# Auto-start Zellij for SSH sessions
# =============================================================================

if set -q SSH_CONNECTION; and not set -q ZELLIJ; and status is-interactive
    command -q zellij; and zellij attach -c ssh
end
