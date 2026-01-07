Move a session plan from claude/ to planned/ with a proper name.

## Instructions

1. **List current session plans**:
   ```bash
   ls ~/Notes/plans/claude/
   ```

2. **Identify which plan to save**:
   - If $ARGUMENTS provided, match against plan names
   - If no argument, ask user which plan to save

3. **Get the new name**:
   - Ask user for a descriptive name (e.g., "morpho_trpc-api")
   - Will be saved as `PLAN_<name>.md`

4. **Move the plan**:
   ```bash
   mv ~/Notes/plans/claude/<old-name>.md ~/Notes/plans/planned/PLAN_<new-name>.md
   ```

5. **Confirm**: Show the new location

## Example Usage

```
/save-plan smooth-popping-llama    # save specific plan
/save-plan                         # list and choose
```

## Naming Convention

Plans in `planned/` follow: `PLAN_<project>_<feature>.md`

Examples:
- `PLAN_morpho_trpc-api.md`
- `PLAN_yomitan_sqlite_backend.md`
- `PLAN_kanji_display_type.md`
