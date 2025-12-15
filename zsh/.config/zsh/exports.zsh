# ~/.config/zsh/exports.zsh

# XDG alternative (opt-in):
mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"

HISTSIZE=100000
SAVEHIST=100000

export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Editor configuration
export EDITOR="codium --wait"
export VISUAL="codium --wait"
