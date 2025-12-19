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

# zoxide (smarter cd)
eval "$(zoxide init zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Aliases
alias ls="eza"
alias ll="eza -la"
alias la="eza -a"
alias lt="eza --tree"
alias cat="bat"
alias grep="rg"
alias find="fd"

# Git aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"
alias gd="git diff"

# uv shell completions
eval "$(uv generate-shell-completion zsh)"

# bun completions
[ -s "/opt/homebrew/Cellar/bun/1.3.5/share/zsh/site-functions/_bun" ] && source "/opt/homebrew/Cellar/bun/1.3.5/share/zsh/site-functions/_bun"
