# Path
export PATH="$HOME/.local/bin:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Auto-start Zellij for SSH sessions
if [[ -n "$SSH_CONNECTION" && -z "$ZELLIJ" && -t 0 ]] && command -v zellij &>/dev/null; then
  zellij attach -c ssh
fi

# Completions
FPATH="/opt/homebrew/share/zsh/site-functions:$FPATH"
autoload -Uz compinit && compinit

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

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
alias cdi="zi"

# atuin (better shell history with sync)
eval "$(atuin init zsh)"

# Starship prompt
eval "$(starship init zsh)"

# bat as man pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Aliases - Modern replacements
alias ls="eza --icons"
alias ll="eza -la --icons"
alias la="eza -a --icons"
alias lt="eza --tree --icons"
alias cat="bat"
alias grep="rg"
alias find="fd"
alias top="btop"
alias htop="btop"
alias diff="delta"
alias du="dust"
alias df="duf"
alias ps="procs"
alias curl="xh"
alias help="tldr"

# Git aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"
alias gd="git diff"
alias gds="git diff --staged"
alias lg="lazygit"

# GitHub CLI aliases
alias pr="gh pr"
alias issue="gh issue"
alias repo="gh repo"

# Shell completions (dynamic generation)
eval "$(uv generate-shell-completion zsh)"      # uv (Python)
eval "$(bun completions)"                        # bun (JavaScript)
eval "$(gh completion -s zsh)"                   # GitHub CLI
eval "$(op completion zsh)" 2>/dev/null          # 1Password CLI (if available)
