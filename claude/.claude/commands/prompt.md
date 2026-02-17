---
description: Load and run a prompt from ~/.claude/prompts/
---

Load and run a saved prompt.

Searches `~/.claude/prompts/` for matching prompt files.

## Instructions

1. **If no argument provided**, list available prompts:
   ```bash
   ls ~/.claude/prompts/*.md 2>/dev/null | sed 's|.*/||; s|\.md$||' | sort
   ```
   Then ask the user which prompt to run.

2. **If argument provided** ($ARGUMENTS), find the matching prompt:
   - Search for files matching `*$ARGUMENTS*` in `~/.claude/prompts/`
   - If multiple matches, show them and ask which one
   - If single match, read it

3. **After reading the prompt**, follow its instructions exactly.
   - Team prompts: spawn the team and agents as described
   - Scaffold prompts: run the scaffolding steps
   - Maintenance prompts: execute the maintenance tasks
   - Exploration prompts: run the research/exploration

Do NOT summarize or ask for confirmation before executing. Just run it.

## Example Usage

```
/prompt team-youtube-player-jisho   # runs the YouTube player team prompt
/prompt team-ux-audit               # runs the UX audit team prompt
/prompt explore-new-repo            # runs the new repo exploration prompt
/prompt maintenance                 # fuzzy-matches maintenance prompts
/prompt                             # lists all available prompts
```
