Load and implement a plan from ~/Notes/plans/planned/

## Instructions

1. **If no argument provided**, list available plans:
   ```bash
   ls ~/Notes/plans/planned/
   ```
   Then ask the user which plan to load.

2. **If argument provided** ($ARGUMENTS), find the matching plan:
   - Search for files matching `*$ARGUMENTS*` in `~/Notes/plans/planned/`
   - If multiple matches, show them and ask which one
   - If single match, read it

3. **After reading the plan**, summarize:
   - Goal and scope
   - Key phases/steps
   - Files to modify/create

4. **Ask the user**: "Ready to start implementation?" or "Which phase should we begin with?"

## Example Usage

```
/plan morpho_trpc     # loads PLAN_morpho_trpc-api.md
/plan kanji           # loads PLAN_kanji_display_type.md
/plan                 # lists all available plans
```
