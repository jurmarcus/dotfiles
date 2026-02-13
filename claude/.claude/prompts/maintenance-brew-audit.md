# Maintenance: Brew Module Audit

> Health check for modular Homebrew setup — duplicates, orphans, grouping | Model: default | Agents: 0

---

Audit the modular Homebrew configuration in ~/dotfiles/brew/.config/brew/modules/.

## Current modules

Read every *.brew file in the modules directory. Current modules include:
ai, base, browsers, communication, dev, fonts, hardware, knowledge,
local-llm, media, remote, security, terminal, utils.

## Checks

### 1. Duplicates

Find any package that appears in more than one .brew file.
Present as: `package-name` → found in `module1.brew`, `module2.brew`

### 2. Dependency overlap

Check if any explicitly listed package is already a dependency of another listed package
(unnecessary explicit install). Use `brew deps --tree` for installed packages.

### 3. Grouping review

For each module, check if every package logically belongs there:
- Is `ripgrep` in terminal/utils where it belongs, or miscategorized?
- Are there packages that would fit better in a different module?
- Are any modules too large (>15 packages) and should be split?

### 4. Shell config cross-reference

Check shell configs (zsh, fish) for references to tools that are NOT in any .brew module:
- Commands used in aliases/functions
- Tools referenced in PATH additions
- Binaries checked with `command -v` / `type -q`

Report any missing packages that should be added to a module.

### 5. Cask audit

Check cask applications:
- Are any casks no longer available? (renamed, removed from Homebrew)
- Are any installed casks missing from the .brew files? (`brew list --cask`)
- Are any .brew casks not actually installed?

## Output

Organize findings by module file:

```
## base.brew
- DUPLICATE: `coreutils` also in utils.brew
- MISSING: `jq` used in zsh alias but not in any module

## dev.brew
- UNNECESSARY: `openssl` is a dependency of `python`, no need to list explicitly
- MISCATEGORIZED: `gh` might fit better in remote.brew
```

Do NOT edit any files until I review the findings.

---

## Notes

- **Module-per-category**: Your brew setup splits packages into logical groups. This audit ensures the grouping stays meaningful as packages are added over time.
- **Cross-reference with shell configs**: The most valuable check — catches "I added an alias for `foo` but forgot to add `foo` to a .brew module" situations.
- **`brew deps --tree`**: May take a moment to run but catches unnecessary explicit installs that just add noise to your .brew files.
- **Run after adding new tools**: Whenever you install something new, run this audit to ensure it lands in the right module.
