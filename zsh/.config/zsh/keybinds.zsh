# ~/.config/zsh/keybinds.zsh

bindkey -e  # Emacs keybindings

# Use Up/Down to search history for commands that start with current prefix
# (both escape-sequence forms for wider terminal compatibility)
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# Shift+Enter inserts a newline (for multi-line commands)
bindkey -s '\e[27;2;13~' '\n'
