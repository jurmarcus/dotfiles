# Non-interactive shell PATH (needed for SSH commands like mosh-server)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Cargo
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
