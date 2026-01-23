# Sapling Configuration

Meta's Sapling (sl) version control system config.

## Files

```
sapling/Library/Preferences/sapling/
└── sapling.conf    # Global sapling config
```

## Key Settings

- **Merge tool**: nvim diff mode (`nvimdiff`)

## Merge Tool

Uses nvim with diff mode for three-way merges:
- `$local` - your version
- `$base` - common ancestor
- `$other` - incoming version

The merged result goes in the bottom pane.
