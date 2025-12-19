# =============================================================================
# Environment
# =============================================================================

export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export EZA_TIME_STYLE="long-iso"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# =============================================================================
# Completions (cached for speed)
# =============================================================================

FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"

# Cache compinit - only rebuild once per day
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Cache dynamic completions (regenerate with: rm ~/.zsh_completion_cache/*)
_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$_cache_dir" ]] || mkdir -p "$_cache_dir"

_cache_completion() {
  local name="$1" cmd="$2"
  local cache_file="$_cache_dir/$name.zsh"
  if [[ ! -f "$cache_file" ]]; then
    eval "$cmd" > "$cache_file" 2>/dev/null
  fi
  [[ -f "$cache_file" ]] && source "$cache_file"
}

_cache_completion "uv" "uv generate-shell-completion zsh"
_cache_completion "bun" "bun completions"
_cache_completion "gh" "gh completion -s zsh"
_cache_completion "op" "op completion zsh"

unset _cache_dir
unfunction _cache_completion

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

# Zsh plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# zoxide (replaces cd)
eval "$(zoxide init zsh --cmd cd)"

# atuin (shell history)
eval "$(atuin init zsh)"

# Starship prompt
eval "$(starship init zsh)"

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
alias curl="xh"
alias help="tldr"

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
# Functions - Python / uv
# =============================================================================

alias py="python3"
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
# Functions - MCP Development
# =============================================================================

mcp-init-py() {
  local name="${1:-mcp-server}"
  local module_name="${name//-/_}"
  pyinit "$name"
  cd "$name" 2>/dev/null || true
  uv add mcp
  mkdir -p "src/$module_name"
  cat > "src/$module_name/server.py" << MCPEOF
from mcp.server import Server
from mcp.server.stdio import stdio_server

server = Server("$name")

@server.list_tools()
async def list_tools():
    return []

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    raise ValueError(f"Unknown tool: {name}")

async def main():
    async with stdio_server() as (read, write):
        await server.run(read, write)

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
MCPEOF
  echo "Created MCP server: $name"
  echo "Run: uv run python -m $module_name.server"
}

mcp-init-ts() {
  local name="${1:-mcp-server}"
  tsinit "$name"
  cd "$name" 2>/dev/null || true
  bun add @modelcontextprotocol/sdk
  cat > src/index.ts << MCPEOF
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server(
  { name: "$name", version: "0.1.0" },
  { capabilities: { tools: {} } }
);

server.setRequestHandler("tools/list", async () => ({
  tools: []
}));

server.setRequestHandler("tools/call", async (request) => {
  throw new Error(\`Unknown tool: \${request.params.name}\`);
});

const transport = new StdioServerTransport();
server.connect(transport);
MCPEOF
  echo "Created MCP server: $name"
  echo "Run: bun run src/index.ts"
}
