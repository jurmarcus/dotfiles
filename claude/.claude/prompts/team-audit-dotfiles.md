# Team Audit — Dotfiles

> Full-repo dotfiles health check with parallel agents | Model: Haiku | Agents: 3

---

Create an agent team with 3 teammates to audit this dotfiles repo. Use Haiku for each
teammate to keep costs low. Require plan approval before any teammate makes changes.

## Teammate 1: Shell Sync Auditor

Audit consistency between zsh and fish shell configs. The repo uses GNU Stow so
configs live in ~/dotfiles/zsh/ and ~/dotfiles/fish/. Both shells MUST have matching:

- Aliases (compare .zshrc aliases with config.fish abbreviations/aliases)
- Environment variables (PATH, EDITOR, tool configs)
- Functions (zsh functions in .zshrc vs fish functions in functions/*.fish)
- Tool integrations (starship, atuin, fzf, zoxide, direnv)

Report a table of discrepancies: what exists in one shell but not the other.
Do NOT edit any files — research only.

## Teammate 2: Dead Code Detective

Search for unused aliases, dead references, and broken paths across ALL config files.
Check for:

- Aliases/abbreviations that reference binaries not in any .brew module
- PATH entries pointing to directories that likely don't exist
- Environment variables referencing tools that aren't installed
- Stale references to old tool names or deprecated configs
- Any sourced files or scripts that are referenced but missing

Report findings with file:line for each issue. Do NOT edit any files — research only.

## Teammate 3: Brew Module Reviewer

Review the modular Homebrew setup in ~/dotfiles/brew/.config/brew/modules/*.brew files.
Check for:

- Packages that appear in multiple .brew module files (duplicates)
- Packages that are dependencies of other packages (unnecessary explicit installs)
- Logical grouping — are packages in the right module for their category?
- Any packages referenced in shell configs that are missing from brew modules
- Compare against what's actually installed (brew list) if possible

Report findings organized by module file. Do NOT edit any files — research only.

## Coordination

After all teammates report, synthesize findings into a single prioritized action list
sorted by impact. Wait for all teammates to finish before summarizing.

---

## Notes

- **Haiku for teammates**: Read-only research doesn't need Opus/Sonnet reasoning power; Haiku keeps costs ~10x lower
- **Plan approval required**: You see each teammate's plan before they start, good for learning the workflow or catching scope creep
- **"Do NOT edit" per teammate**: Explicit guard repeated per agent because each teammate gets its own context — they don't inherit your session instructions
- **Non-overlapping file boundaries**: Shell sync looks at zsh/fish, dead code looks cross-repo, brew reviewer looks at brew/ — minimal conflict
- **"Wait for all teammates"**: Prevents the lead from summarizing prematurely with incomplete data
