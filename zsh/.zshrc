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

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Rust (Homebrew rustup doesn't create ~/.cargo/bin proxies)
export PATH="$HOME/.cargo/bin:$HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH"

# PostgreSQL client (Homebrew keg-only, not linked)
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

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
# Tool Initialization (cached for fast startup)
# =============================================================================

# Cache directory for tool init scripts
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# Cache helper: sources cached init, regenerates only if cache missing
_cache_init() {
  local cache="$ZSH_CACHE_DIR/$1.zsh"
  if [[ ! -f "$cache" ]]; then
    eval "$2" > "$cache" 2>/dev/null
  fi
  source "$cache"
}

# Guard zle-dependent tools behind TTY check (fzf emits "can't change option: zle" without one)
if [[ -t 0 ]]; then
  _cache_init fzf "fzf --zsh"
  _cache_init atuin "atuin init zsh"
  _cache_init starship "starship init zsh"
fi
_cache_init direnv "direnv hook zsh"
_cache_init zoxide "zoxide init zsh"

# Regenerate all caches (run after tool updates)
regen-tool-cache() {
  rm -rf "$ZSH_CACHE_DIR"/*.zsh
  echo "Cleared tool cache. Restart shell to regenerate."
}

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

# Machine slug from hostname (methylene-macbook or allenj-macbook → macbook)
_HOSTNAME_SHORT=$(hostname -s)
_machine() {
  local host=$_HOSTNAME_SHORT
  host=${host#methylene-}  # Strip methylene- prefix if present
  host=${host#allenj-}     # Strip allenj- prefix if present
  echo "$host"
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

# Auto-start tmux with picker (requires real TTY - prevents hanging IDE env resolvers)
if [[ -z "$TMUX" ]] && [[ -t 0 ]] && [[ -t 1 ]] && [[ "$TERM_PROGRAM" != "vscode" ]] && [[ "$TERM_PROGRAM" != "codium" ]] && [[ "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
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
# Eternal Terminal - persistent remote sessions
# =============================================================================

# Quick connect (opens login shell → tmux picker)
alias ets="et methylene-studio"
alias eth="et hanekawa-nas"

# Direct tmux session via et (bypasses picker, reconnects to named session)
etmux() {
  local host="${1:?Usage: etmux <host> [session]}"
  local session="${2:-main}"
  et "$host" -c "tmux new-session -A -s $session"
}

# =============================================================================
# SSH - rename tmux window to hostname
# =============================================================================
ssh() {
  local host="" skip_next=false
  for arg in "$@"; do
    if $skip_next; then skip_next=false; continue; fi
    case "$arg" in
      -[bcDEeFIiJLlmOopQRSWw]) skip_next=true ;;
      -*) ;;
      *) host="$arg"; break ;;
    esac
  done
  host="${host##*@}"  # strip user@ prefix

  [[ -n "$TMUX" && -n "$host" ]] && tmux rename-window "$host"
  TERM=xterm-256color command ssh "$@"
  [[ -n "$TMUX" ]] && tmux set-window-option automatic-rename on
}

# Work machine overrides
if [[ "$_HOSTNAME_SHORT" == allenj* ]]; then
  x2ssh() { TERM=xterm-256color command x2ssh -mosh -mosh_colors 256 "$@"; }
  dev()   { TERM=xterm-256color command dev "$@"; }
  mosh()  { TERM=xterm-256color command mosh "$@"; }
  et()    { TERM=xterm-256color command et "$@"; }
  # Dev connect wrappers with tmux window naming
  _tmux_name() { [[ -n "$TMUX" ]] && tmux rename-window "$1" && tmux set-window-option automatic-rename off; }
  det()   { [[ -n "$1" ]] && _tmux_name "et:${1%%.*}" || _tmux_name "et"; TERM=xterm-256color command dev connect --et "$@"; }
  dmosh() { [[ -n "$1" ]] && _tmux_name "mosh:${1%%.*}" || _tmux_name "mosh"; TERM=xterm-256color command dev connect --mosh "$@"; }
  dssh()  { [[ -n "$1" ]] && _tmux_name "ssh:${1%%.*}" || _tmux_name "ssh"; TERM=xterm-256color command dev connect --ssh "$@"; }
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

if [[ "$_HOSTNAME_SHORT" == allenj* ]]; then
  alias code="code-fb"
  alias codeoss="codium"
else
  alias code="codium"
fi 

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

if [[ "$_HOSTNAME_SHORT" == allenj* ]]; then
  export META_CLAUDE_CODE_RELEASE=latest
fi

# Claude CLI
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export CLAUDE_CODE_DISABLE_AUTO_MEMORY=0
unalias claude c cc ccc ccr 2>/dev/null
function claude { command claude --dangerously-skip-permissions --teammate-mode tmux "$@"; }
function c      { claude "$@"; }
function cc     { claude "$@"; }
function ccc    { claude --continue "$@"; }
function ccr    { claude --resume "$@"; }

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
  local -a skip_packages=()

  # Machine-specific package skips
  case "$(hostname)" in
    allenj-macbook) skip_packages=(claude git sapling ssh) ;;
  esac

  cd "$DOTFILES" || return 1
  for dir in */; do
    dir="${dir%/}"
    [[ "$dir" == "bootstrap" ]] && continue
    if (( ${skip_packages[(Ie)$dir]} )); then
      echo "Skipping $dir (not managed on $(hostname))..."
      continue
    fi
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
# Functions - kuro (Claude helper)
# =============================================================================

kss() { kuro ss "$@"; }

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

rs-init-mcp() {
  local name="${1:-mcp-server}"
  rs-init "$name"
  cargo add rmcp --features server,transport-io,macros
  cargo add tokio --features full
  cargo add serde --features derive
  cargo add serde_json anyhow tracing tracing-subscriber
  template "$TEMPLATE_DIR/mcp-server.rs" NAME="$name" > src/main.rs
  echo "Created Rust MCP server: $name"
  echo "Run: cargo run"
}

# =============================================================================
# Zsh Plugins (syntax highlighting lazy-loaded for faster startup)
# =============================================================================

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Lazy-load syntax highlighting after first prompt (saves 100-300ms on startup)
_load_syntax_highlighting() {
  unset -f _load_syntax_highlighting
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _load_syntax_highlighting

# Navi CLI
export PATH="/Users/allenj/.navi/bin:$PATH"
