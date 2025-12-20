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

# =============================================================================
# Caching (completions + tool init)
# =============================================================================

FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"

# Cache compinit - only rebuild once per day
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Tool initializations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"

# Completions
eval "$(uv generate-shell-completion zsh)"
eval "$(gh completion -s zsh)"
eval "$(op completion zsh)"

# =============================================================================
# History
# =============================================================================

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

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
alias diff="delta"
alias du="dust"
alias df="duf"

# System
alias top="btop"
alias htop="btop"
alias ps="procs"
alias help="tldr"
alias tmux="zellij"

# Editors
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias nano="nvim"
alias code="codium"

# Version control
alias hg="sl"
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"
alias gd="git diff"
alias gds="git diff --staged"
alias lg="lazygit"

# GitHub CLI
alias pr="gh pr"
alias issue="gh issue"
alias repo="gh repo"

# Navigation
alias cdi="zi"

# =============================================================================
# Functions - Claude Workflow
# =============================================================================

context() {
  echo "## Project: $(basename $PWD)"
  echo "\n### Structure"
  eza --tree -L 2 --icons --group-directories-first
  echo "\n### Git Status"
  git status --short 2>/dev/null || echo "Not a git repo"
  echo "\n### Recent Changes"
  git log --oneline -5 2>/dev/null || true
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
dft() { difft "$@"; }

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
  echo "==> Installing from Brewfile..."
  brew bundle --global

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
alias ipy="uvx ipython"
alias pip="uv pip"

pyinit() {
  local name="${1:-.}"
  [[ "$name" != "." ]] && mkdir -p "$name" && cd "$name"
  uv init && uv add --dev ruff pytest
  echo "Created Python project with uv"
}

pyr() { uv run python "$@"; }
pyt() { uv run pytest "$@"; }
pya() { uv add "$@"; }
uvr() { uvx "$@"; }

# =============================================================================
# Functions - TypeScript / bun
# =============================================================================

alias ts="bun run"
alias tsx="bun x tsx"

tsinit() {
  local name="${1:-.}"
  [[ "$name" != "." ]] && mkdir -p "$name" && cd "$name"
  bun init -y && bun add -d typescript @types/bun
  echo "Created TypeScript project with bun"
}

tsr() { bun run "$@"; }
tst() { bun test "$@"; }

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
TEMPLATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/templates"

# =============================================================================
# Functions - MCP Development
# =============================================================================

mcp-init-py() {
  local name="${1:-mcp-server}"
  local module_name="${name//-/_}"
  pyinit "$name"
  cd "$name" 2>/dev/null || true
  uv add mcp
  mkdir -p "src/$module_name"
  template "$TEMPLATE_DIR/mcp-server.py" NAME="$name" > "src/$module_name/server.py"
  echo "Created MCP server: $name"
  echo "Run: uv run python -m $module_name.server"
}

mcp-init-ts() {
  local name="${1:-mcp-server}"
  tsinit "$name"
  cd "$name" 2>/dev/null || true
  bun add @modelcontextprotocol/sdk
  template "$TEMPLATE_DIR/mcp-server.ts" NAME="$name" > src/index.ts
  echo "Created MCP server: $name"
  echo "Run: bun run src/index.ts"
}

# =============================================================================
# Zsh Plugins (must be last, syntax-highlighting before history-substring-search)
# =============================================================================

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# opencode
export PATH=/Users/methylene/.opencode/bin:$PATH

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/methylene/.lmstudio/bin"
# End of LM Studio CLI section

