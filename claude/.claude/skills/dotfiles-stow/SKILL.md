---
name: dotfiles-stow
description: Apply dotfiles changes with GNU Stow. Use when editing files in ~/dotfiles to ensure changes are properly symlinked to home directory. Handles stow conflicts with adopt workflow.
---

# Dotfiles Stow Management

When editing files in `~/dotfiles`, changes must be stowed to take effect.

## Core Rule

**NEVER edit files directly in `~/`** - always edit in `~/dotfiles/` then stow.

## After Editing Dotfiles

After any edit in `~/dotfiles/<package>/`, run:

```bash
stow -R -d ~/dotfiles <package>
```

Examples:
```bash
stow -R -d ~/dotfiles zsh      # After editing zsh/.zshrc
stow -R -d ~/dotfiles brew     # After editing brew configs
stow -R -d ~/dotfiles claude   # After editing claude configs
stow -R -d ~/dotfiles nvim     # After editing neovim configs
```

## Package to Directory Mapping

| Package | Manages | Target |
|---------|---------|--------|
| `zsh` | `.zshrc`, `.zprofile` | `~/` |
| `fish` | `config.fish`, functions | `~/.config/fish/` |
| `brew` | `.Brewfile`, modules | `~/`, `~/.config/brew/` |
| `claude` | CLAUDE.md, commands, skills | `~/.claude/` |
| `nvim` | Neovim config | `~/.config/nvim/` |
| `ghostty` | Terminal config | `~/.config/ghostty/` |
| `starship` | Prompt config | `~/.config/starship.toml` |
| `git` | `.gitconfig` | `~/` |
| `karabiner` | Keyboard remaps | `~/.config/karabiner/` |

## Handling Conflicts

If stow fails with "existing target" error:

### Option 1: Adopt existing file (preserve current)
```bash
# This moves ~/file INTO dotfiles, replacing dotfiles version
stow --adopt -d ~/dotfiles <package>

# Then check what changed
git -C ~/dotfiles diff

# If you want the dotfiles version, restore it
git -C ~/dotfiles checkout -- <file>
```

### Option 2: Remove existing file first
```bash
# Backup and remove the conflicting file
mv ~/.config/something ~/.config/something.bak
stow -R -d ~/dotfiles <package>
```

## Restow All Packages

Use the shell function:
```bash
restow
```

Or manually:
```bash
for pkg in zsh fish brew claude nvim ghostty starship git karabiner; do
  stow -R -d ~/dotfiles "$pkg"
done
```

## Verify Symlinks

Check that files are properly linked:
```bash
ls -la ~/.zshrc           # Should show -> dotfiles/zsh/.zshrc
ls -la ~/.config/nvim     # Should show -> ../dotfiles/nvim/.config/nvim
```

## Workflow

1. **Edit** file in `~/dotfiles/<package>/`
2. **Stow** the package: `stow -R -d ~/dotfiles <package>`
3. **Verify** the symlink exists
4. **Test** the change works
5. **Commit** to dotfiles repo

## Common Issues

| Issue | Solution |
|-------|----------|
| "existing target is not owned by stow" | Use `--adopt` or remove file first |
| "cannot stow over directory" | Remove the directory first, then stow |
| Changes not taking effect | Check symlink exists, restart shell/app |
