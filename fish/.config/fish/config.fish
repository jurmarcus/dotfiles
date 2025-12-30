# Fish Config - no plugins needed, batteries included

# =============================================================================
# Environment (runs for all shells)
# =============================================================================

fish_add_path ~/.local/bin /opt/homebrew/bin /opt/homebrew/sbin ~/.bun/bin ~/.opencode/bin

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx UV_PYTHON_PREFERENCE only-managed
set -gx EZA_TIME_STYLE long-iso
set -gx BUN_INSTALL ~/.bun
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --line-range :500 {}'"
set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

# Homebrew (required by some tools)
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew
set -gx MANPATH /opt/homebrew/share/man $MANPATH
set -gx INFOPATH /opt/homebrew/share/info $INFOPATH

# Local
set -g DOTFILES ~/dotfiles
set -g TEMPLATE_DIR ~/.config/templates

# =============================================================================
# Interactive shell only
# =============================================================================

status is-interactive || return

# Tool initialization
fzf --fish | source
zoxide init fish --cmd cd | source
atuin init fish | source
starship init fish | source

# Auto-attach to zellij on SSH
set -q SSH_CONNECTION && not set -q ZELLIJ && command -q zellij && zellij attach -c ssh

# -----------------------------------------------------------------------------
# Abbreviations (expand inline, visible in history)
# -----------------------------------------------------------------------------

# Sapling
abbr ss 'sl status'
abbr sa 'sl add'
abbr sc 'sl commit'
abbr sp 'sl push'
abbr spl 'sl pull'
abbr sar 'sl addremove' 

# GitHub CLI
abbr pr 'gh pr'
abbr issue 'gh issue'
abbr repo 'gh repo'

# Zellij
abbr zls 'zellij list-sessions'
abbr zcd 'zellij attach'
abbr zrm 'zellij delete-session'
abbr zssh 'zellij attach -c ssh'

# Navigation
abbr -g .. 'cd ..'
abbr -g ... 'cd ../..'
abbr -g .... 'cd ../../..'
abbr -g ..... 'cd ../../../..'

# -----------------------------------------------------------------------------
# Aliases (wrapper functions - shadow commands)
# -----------------------------------------------------------------------------

# File operations
alias ls 'eza --icons --group-directories-first'
alias ll 'eza -la --icons --group-directories-first'
alias la 'eza -a --icons --group-directories-first'
alias lt 'eza --tree --icons'
alias cat bat
alias grep rg
alias find fd
alias du dust
alias df duf

# System
alias top btop
alias htop btop
alias ps procs
alias help tldr
alias tmux zellij

# Editors
alias nano nvim
alias vim nvim
alias vi nvim
alias v nvim
alias code codium

# Python
alias python 'uv run python'
alias python3 'uv run python'
alias py 'uv run python'
alias pip 'uv pip'
alias ipy 'uvx ipython'

alias pyr 'uv run python'
alias pyt 'uv run pytest'
alias pya 'uv add'
alias pyx 'uvx'

# Typescript
alias tsr 'bun run'
alias tst 'bun test'
alias tsa 'bun add'
alias tsx 'bun x tsx'