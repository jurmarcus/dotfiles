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

# atuin (better shell history with sync)
eval "$(atuin init zsh)"

# Starship prompt
eval "$(starship init zsh)"

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

# Git aliases
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"
alias gd="git diff"
alias gds="git diff --staged"

# Shell completions (dynamic generation)
eval "$(uv generate-shell-completion zsh)"      # uv (Python)
eval "$(bun completions)"                        # bun (JavaScript)
eval "$(gh completion -s zsh)"                   # GitHub CLI
eval "$(op completion zsh)" 2>/dev/null          # 1Password CLI (if available)
