# Stow Configuration

GNU Stow settings for symlink management.

## Files

```
stow/
├── .stowrc              # Settings
└── .stow-global-ignore  # Ignore patterns
```

## Settings (.stowrc)

- `--target=~` - Symlinks to home
- `--verbose=2` - Moderate logging
- `--no-folding` - Symlink files, not directories

## Ignored Patterns

- VCS: `.git`, `.gitignore`, `README*`, `LICENSE*`
- OS: `.DS_Store`, `Thumbs.db`
- Editor: `.idea`, `.vscode`
- Build: `node_modules`, `dist`, `target`
- Zsh: `.zsh_sessions`, `.zsh_history`

## Usage

```bash
# Stow package
stow zsh

# Restow (recreate)
stow -R zsh

# Unstow (remove)
stow -D zsh

# Dry run
stow -n -v zsh

# All packages
restow
```

## --no-folding

Without: symlinks entire directories
With: creates directory structure, symlinks individual files

Important when multiple packages share parent directories (like `.config`).
