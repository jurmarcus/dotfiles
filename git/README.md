# Git Configuration

Git settings with delta pager for improved diffs.

## Files

```
git/
└── .gitconfig
```

## Delta Pager

- Side-by-side diffs
- Line numbers
- Syntax highlighting
- `n/N` to navigate between files

## Settings

From `.gitconfig`:
- `colorMoved = default`
- `conflictstyle = zdiff3`

From `bootstrap/git.sh`:
- `init.defaultBranch = main`
- `pull.rebase = true`
- `push.autoSetupRemote = true`
- `fetch.prune = true`
- `diff.algorithm = histogram`
- `rerere.enabled = true`

## Aliases (from .zshrc)

| Alias | Command |
|-------|---------|
| `g` | git |
| `gs` | git status |
| `ga` | git add |
| `gc` | git commit |
| `gp` | git push |
| `gl` | git log --oneline |
| `gd` | git diff |
| `gds` | git diff --staged |
| `lg` | lazygit |

## Sapling

Sapling (`sl`) is preferred for daily use. Aliased as `hg`.
