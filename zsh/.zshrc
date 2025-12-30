# =============================================================================
# Environment
# =============================================================================

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export EZA_TIME_STYLE="long-iso"

# uv - prefer managed Python installations
export UV_PYTHON_PREFERENCE="only-managed"

# Homebrew (inlined - no subprocess fork)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Opencode
export PATH=/Users/methylene/.opencode/bin:$PATH

# =============================================================================
# Completions (cached to files for fast startup)
# =============================================================================

# Completion cache dir - generate with: regen-completions
ZSH_COMP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions"
[[ -d "$ZSH_COMP_DIR" ]] && FPATH="$ZSH_COMP_DIR:$FPATH"
FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"

# Cache compinit - only rebuild once per day
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Regenerate cached completions (run once, or after tool updates)
regen-completions() {
  local dir="$ZSH_COMP_DIR"
  mkdir -p "$dir"
  echo "Generating completions to $dir..."
  uv generate-shell-completion zsh > "$dir/_uv"
  gh completion -s zsh > "$dir/_gh"
  op completion zsh > "$dir/_op"
  just --completions zsh > "$dir/_just"
  echo "Done. Restart shell to use."
}

# =============================================================================
# Tool Initialization (lazy where possible)
# =============================================================================

eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(atuin init zsh)"
eval "$(starship init zsh)"

# =============================================================================
# History (backup - atuin is primary)
# =============================================================================

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS INC_APPEND_HISTORY

# =============================================================================
# Plugins & Tools
# =============================================================================

# fzf config (init is cached above)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# =============================================================================
# SSH / Remote
# =============================================================================

# Auto-start Zellij for SSH sessions
if [[ -n "$SSH_CONNECTION" && -z "$ZELLIJ" && -t 0 ]] && command -v zellij &>/dev/null; then
  zellij attach -c ssh
fi

# =============================================================================
# Zellij Session Management
# =============================================================================

# Numbered sessions helper
_znew() {
  local prefix="$1" n=1
  local sessions=$(zellij list-sessions 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g')
  while echo "$sessions" | grep -q "^${prefix}-$n "; do
    ((n++))
  done
  zellij --session "${prefix}-$n"
}

zclaude() { _znew claude; }
zopencode() { _znew opencode; }
zservice() { _znew service; }

# List, switch, and delete sessions
zls() { zellij list-sessions; }
zcd() { zellij attach "$1"; }
zrm() { zellij delete-session "$@"; }
zssh() { zellij attach -c ssh; }

# =============================================================================
# Aliases - Modern CLI Replacements
# =============================================================================

# File operations
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias la="eza -a --icons --group-directories-first"
alias lt="eza --tree --icons"
alias cat="bat"
alias grep="rg"
alias find="fd"
alias du="dust"
alias df="duf"

# System
alias top="btop"
alias htop="btop"
alias ps="procs"
alias help="tldr"
alias tmux="zellij"

# Editors
alias nano="nvim"
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias code="codium"

# Version control (sapling for everything)
alias ss="sl status"
alias sa="sl add"
alias sc="sl commit"
alias sp="sl push"
alias spl="sl pull"
alias sar="sl addremove"

# GitHub CLI
alias pr="gh pr"
alias issue="gh issue"
alias repo="gh repo"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# =============================================================================
# Functions - Claude Workflow
# =============================================================================

context() {
  echo "## Project: $(basename $PWD)"
  echo "\n### Structure"
  eza --tree -L 2 --icons --group-directories-first
  echo "\n### Status"
  sl status 2>/dev/null || echo "Not a repo"
  echo "\n### Recent Changes"
  sl log -l 5 2>/dev/null || true
}

yank() {
  if [[ -f "$1" ]]; then
    bat --style=plain "$1" | pbcopy
    echo "Copied $1 to clipboard ($(wc -l < "$1" | tr -d ' ') lines)"
  else
    echo "File not found: $1"
  fi
}

yankdir() {
  local depth="${2:-2}"
  eza --tree -L "$depth" --icons "${1:-.}" | pbcopy
  echo "Copied directory tree to clipboard"
}

watch() { watchexec -e "${2:-py,ts,js,rs}" -- "$1"; }

# =============================================================================
# Functions - Dotfiles
# =============================================================================

DOTFILES="$HOME/dotfiles"

restow() {
  local dir
  cd "$DOTFILES" || return 1
  for dir in */; do
    dir="${dir%/}"
    [[ "$dir" == "bootstrap" ]] && continue
    echo "Restowing $dir..."
    stow -R "$dir"
  done
  cd - > /dev/null
  echo "Done restowing all packages"
}

brewsync() {
  if brew bundle check --global >/dev/null 2>&1; then
    echo "==> All packages already installed"
  else
    echo "==> Installing from Brewfile..."
    brew bundle --global
  fi

  echo "\n==> Checking for orphans (installed but not in Brewfile)..."
  local orphans
  orphans=$(brew bundle cleanup --global 2>/dev/null)

  if [[ -z "$orphans" ]]; then
    echo "No orphans found"
  else
    echo "$orphans"
    if [[ "$1" == "clean" ]]; then
      echo "\n==> Removing orphans..."
      brew bundle cleanup --global --force
    else
      echo "\nRun 'brewsync clean' to remove these"
    fi
  fi
}

# =============================================================================
# Functions - Python / uv
# =============================================================================

alias python="uv run python"
alias python3="uv run python"
alias py="uv run python"
alias pip="uv pip"
alias ipy="uvx ipython"

py-init() {
  local name="${1:-.}"
  [[ "$name" != "." ]] && mkdir -p "$name" && cd "$name"
  uv init && uv add --dev ruff pytest
  echo "Created Python project with uv"
}

pyr() { uv run python "$@"; }
pyt() { uv run pytest "$@"; }
pya() { uv add "$@"; }
pyx() { uvx "$@"; }

# =============================================================================
# Functions - TypeScript / bun
# =============================================================================

ts-init() {
  local name="${1:-.}"
  [[ "$name" != "." ]] && mkdir -p "$name" && cd "$name"
  bun init -y && bun add -d typescript @types/bun
  echo "Created TypeScript project with bun"
}

tsr() { bun run "$@"; }
tst() { bun test "$@"; }
tsa() { bun add "$@"; }
tsx() { bun x tsx "$@"; }

# =============================================================================
# Functions - Templates
# =============================================================================

# Simple mustache-style template: {{VAR}} gets replaced
# Usage: template file.tpl VAR=value VAR2=value2
template() {
  local file="$1"; shift
  local content=$(<"$file")
  for arg in "$@"; do
    local key="${arg%%=*}"
    local val="${arg#*=}"
    content="${content//\{\{$key\}\}/$val}"
  done
  echo "$content"
}

# Template directory
TEMPLATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/templates"

# =============================================================================
# Functions - MCP Development
# =============================================================================

py-init-mcp() {
  local name="${1:-mcp-server}"
  local module_name="${name//-/_}"
  py-init "$name"
  cd "$name" 2>/dev/null || true
  uv add mcp
  mkdir -p "src/$module_name"
  template "$TEMPLATE_DIR/mcp-server.py" NAME="$name" > "src/$module_name/server.py"
  echo "Created MCP server: $name"
  echo "Run: uv run python -m $module_name.server"
}

ts-init-mcp() {
  local name="${1:-mcp-server}"
  ts-init "$name"
  cd "$name" 2>/dev/null || true
  bun add @modelcontextprotocol/sdk
  template "$TEMPLATE_DIR/mcp-server.ts" NAME="$name" > src/index.ts
  echo "Created MCP server: $name"
  echo "Run: bun run src/index.ts"
}

# =============================================================================
# Zsh Plugins (must be last)
# =============================================================================

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh