# Scaffold Monorepo

> Bootstrap a new monorepo with full tooling stack | Model: default | Agents: 0

---

Create a new monorepo at [REPO_PATH] for [PROJECT_DESCRIPTION].

## Structure

```
[project-name]/
├── CLAUDE.md              # Root: architecture, conventions, just recipes
├── justfile               # Task runner (all build/test/lint commands)
├── .envrc                 # direnv: shared env vars
├── .gitignore
├── [package-1]/           # First package
│   ├── CLAUDE.md          # Package-specific instructions
│   └── ...
├── [package-2]/           # Second package
│   ├── CLAUDE.md          # Package-specific instructions
│   └── ...
└── docs/
    └── plans/             # Design docs and implementation plans
```

## Tooling Setup

### Per-language packages

**If Python package**:
```bash
cd [package-dir] && uv init && uv add --dev pytest ruff
```
- Use `pyproject.toml` with ruff config
- Add `py.typed` marker for type checking

**If TypeScript package**:
```bash
cd [package-dir] && bun init && bun add -d typescript @types/bun
```
- Enable strict mode in tsconfig.json
- Add biome.json for formatting/linting

**If Rust package**:
```bash
cd [package-dir] && cargo init
```
- Use `edition = "2024"` in Cargo.toml
- Add clippy config in clippy.toml

### Root justfile

Create recipes for every common operation:

```just
# List all recipes
default:
    @just --list

# Run all tests across packages
test:
    [per-package test commands]

# Format all code
fmt:
    [per-package format commands]

# Lint all code
lint:
    [per-package lint commands]

# Type check all code
check:
    [per-package type check commands]
```

### Root CLAUDE.md

Include:
- Project purpose and architecture overview
- How packages relate to each other (dependency graph)
- Common `just` recipes and when to use them
- Conventions: naming, error handling, testing patterns
- Per-package sections pointing to their CLAUDE.md files

### Version control

```bash
sl init
sl add .
sl commit -m "feat: scaffold [project-name] monorepo"
```

## Machines

If this project spans methylene-macbook and methylene-studio:
- Add `.envrc` with conditional URLs based on hostname
- Use `JISHO_REMOTE_HOST` pattern for cross-machine communication
- Document which packages run where in CLAUDE.md

---

## Notes

- **justfile over Makefile**: `just` is the standard task runner across all your projects. Every command goes through it.
- **Layered CLAUDE.md**: Root describes architecture, each package describes its own conventions. Claude reads these automatically.
- **direnv for env vars**: Keeps machine-specific config out of code. The `.envrc` pattern scales cleanly across your Tailscale network.
- **Per-language tooling**: uv (Python), bun (TypeScript), cargo (Rust) — never use pip, npm, or other package managers.
- **sl for version control**: Initialize with Sapling from the start. Git compatibility is automatic.
- **docs/plans/ directory**: Where design docs and implementation plans live. Your `/design` command writes here.
