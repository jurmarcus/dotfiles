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

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Rust (Homebrew rustup doesn't create ~/.cargo/bin proxies)
export PATH="$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH"

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
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

# =============================================================================
# History (backup - atuin is primary)
# =============================================================================

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS INC_APPEND_HISTORY

# Directory navigation (fish-like AUTO_CD)
setopt AUTO_CD              # Type directory name to cd into it
setopt AUTO_PUSHD           # cd pushes old dir to stack
setopt PUSHD_IGNORE_DUPS    # No duplicates in dir stack

# =============================================================================
# Plugins & Tools
# =============================================================================

# fzf config (init is cached above)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# =============================================================================
# Tmux Session Management
# =============================================================================

# Machine slug from hostname (methylene-macbook → macbook)
_machine() {
  local host=$(hostname -s)
  [[ "$host" == methylene-* ]] && echo "${host#methylene-}" || echo "$host"
}

# Rename current tmux session to machine-prefix-N
_trename() {
  local prefix="$(_machine)-$1" n=1
  while tmux has-session -t "${prefix}-$n" 2>/dev/null; do ((n++)); done
  tmux rename-session "${prefix}-$n"
  echo "Renamed to ${prefix}-$n"
}

# fzf-based tmux session picker (uses exec - single exit closes terminal)
_tmux_picker() {
  local sessions choice n prefix="$(_machine)-dev"
  sessions=$(tmux list-sessions -F '#{session_name}: #{session_windows} win#{?session_attached, (attached),}' 2>/dev/null)

  if [[ -z "$sessions" ]]; then
    exec tmux new-session -s "${prefix}-1"
  fi

  choice=$(echo "$sessions\n+ new session" | fzf --height=40% --reverse --prompt="tmux> ")

  case "$choice" in
    "+ new session")
      n=1
      while tmux has-session -t "${prefix}-$n" 2>/dev/null; do ((n++)); done
      exec tmux new-session -s "${prefix}-$n"
      ;;
    "") exit 0 ;;  # cancelled - close terminal
    *) exec tmux attach -t "${choice%%:*}" ;;
  esac
}

# Auto-start tmux with picker
if [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
  _tmux_picker
fi
tclaude() { _trename claude; }
topencode() { _trename opencode; }
tservice() { _trename service; }

# List, attach, kill sessions
tls() { tmux list-sessions; }
tcd() { tmux attach-session -t "$1"; }
tk() { tmux kill-session -t "$@"; }
tka() { tmux kill-server; }

# =============================================================================
# Aliases - Modern CLI Replacements
# =============================================================================
if [[ "$(hostname -s)" == allenj* ]]; then
  ssh()   { TERM=xterm-256color command ssh "$@"; }
  x2ssh() { TERM=xterm-256color command x2ssh -mosh -mosh_colors 256 "$@"; }
  dev()   { TERM=xterm-256color command dev "$@"; }
  dconn() { TERM=xterm-256color command dev connect -m "$@"; }
  mosh()  { TERM=xterm-256color command mosh "$@"; }
  et()    { TERM=xterm-256color command et "$@"; }
fi

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

# Editors
alias nano="nvim"
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias code="codium"
alias vimdiff='nvim -d'
[[ "$(hostname -s)" == allenj* ]] && alias code="code-fb" || alias code="codium"

# Version control (sapling for everything)
alias ss="sl status"
alias sa="sl add"
alias sc="sl commit"
alias sp="sl push"
alias spl="sl pull --rebase"
alias sar="sl addremove"

# GitHub CLI
alias pr="gh pr"
alias issue="gh issue"
alias repo="gh repo"

if [[ "$(hostname -s)" == allenj* ]]; then
  export META_CLAUDE_CODE_RELEASE=latest
fi

# Claude CLI
alias claude="claude"
alias cc="claude"
alias ccc="claude --continue"
alias ccr="claude --resume"
alias c="claude"

# Navigation (AUTO_CD handles the cd)
alias ...="../.."
alias ....="../../.."
alias .....="../../../.."

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
pyb() { uv build "$@"; }
pyl() { uvx ruff check "$@"; }
pyf() { uvx ruff format "$@"; }

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
tsx() { bunx tsx "$@"; }
tsb() { bun build "$@"; }
tsl() { bunx biome lint "$@"; }
tsf() { bunx biome format "$@"; }

# =============================================================================
# Functions - Rust / cargo
# =============================================================================

rs-init() {
  local name="${1:-.}"
  if [[ "$name" != "." ]]; then
    cargo new "$name" && cd "$name"
  else
    cargo init
  fi
  echo "Created Rust project with cargo"
}

rsr() { cargo run "$@"; }
rst() { cargo test "$@"; }
rsa() { cargo add "$@"; }
rsb() { cargo build "$@"; }
rsl() { cargo clippy "$@"; }
rsf() { cargo fmt "$@"; }

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
