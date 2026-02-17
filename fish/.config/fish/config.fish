# Fish Config - no plugins needed, batteries included

# =============================================================================
# Environment (runs for all shells)
# =============================================================================

fish_add_path ~/.local/bin /opt/homebrew/bin /opt/homebrew/sbin ~/.bun/bin

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

# Android SDK
set -gx ANDROID_HOME ~/Library/Android/sdk
fish_add_path $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools

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
direnv hook fish | source
starship init fish | source

# Auto-start tmux with picker
# Require real TTY - prevents hanging IDE env resolvers (fzf blocks without one)
if not set -q TMUX; and isatty stdin; and isatty stdout; and test "$TERM_PROGRAM" != vscode; and test "$TERM_PROGRAM" != codium
    _tmux_picker
end

# -----------------------------------------------------------------------------
# Abbreviations (expand inline, visible in history)
# -----------------------------------------------------------------------------

# Sapling
abbr ss 'sl status'
abbr sa 'sl add'
abbr sc 'sl commit'
abbr sp 'sl push'
abbr spl 'sl pull --rebase'
abbr sar 'sl addremove' 

# GitHub CLI
abbr pr 'gh pr'
abbr issue 'gh issue'
abbr repo 'gh repo'

# Tmux
abbr tls 'tmux list-sessions'
abbr tcd 'tmux attach-session -t'
abbr tk 'tmux kill-session -t'
abbr tka 'tmux kill-server'

# Navigation (fish has AUTO_CD built-in)
abbr -g ... '../..'
abbr -g .... '../../..'
abbr -g ..... '../../../..'

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

# Editors
alias nano nvim
alias vim nvim
alias vi nvim
alias v nvim
alias code codium
alias vimdiff 'nvim -d'

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
alias pyb 'uv build'
alias pyl 'uvx ruff check'
alias pyf 'uvx ruff format'

# Typescript
alias tsr 'bun run'
alias tst 'bun test'
alias tsa 'bun add'
alias tsx 'bunx tsx'
alias tsb 'bun build'
alias tsl 'bunx biome lint'
alias tsf 'bunx biome format'

# Rust
alias rsr 'cargo run'
alias rst 'cargo test'
alias rsa 'cargo add'
alias rsb 'cargo build'
alias rsl 'cargo clippy'
alias rsf 'cargo fmt'

# Claude CLI
set -gx CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS 1
<<<<<<< dest:   57a46d1dbc49 - me: lots of changes 10
function claude --description "Claude Code" --wraps claude
    command claude --dangerously-skip-permissions --teammate-mode tmux $argv
end
function cc --wraps claude;  claude $argv; end
function c --wraps claude;   claude $argv; end
function ccc --wraps claude; claude --continue $argv; end
function ccr --wraps claude; claude --resume $argv; end=======
set -gx CLAUDE_CODE_DISABLE_AUTO_MEMORY 0
alias claude 'claude --dangerously-skip-permissions --teammate-mode tmux'
alias cc claude
alias ccc 'claude --continue'
alias ccr 'claude --resume'
alias c claude>>>>>>> source: b23ea240f8b4 - me: lots of changes 8
