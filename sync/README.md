# sync

Real-time bidirectional Claude memory sync across the macOS dev mesh (studio, macbook, mini) using Syncthing.

## What this package owns

- **`folders.conf`** — declarative list of folders to sync (single source of truth)
- **`stignore/`** — `.stignore` templates deployed into each synced folder root
- **Helper bins** — `claude-sync-status`, `claude-sync-add-folder`

The actual Syncthing daemon, folder registration, and mesh pairing are driven by `bootstrap/syncthing.sh` and `bootstrap/syncthing-mesh.sh` (in the root `bootstrap/` dir, not part of this stow package).

## What gets synced

| Folder ID | Path | Purpose |
|---|---|---|
| `claude-mem-global` | `~/.claude/memory/` | global Claude memories (user profile, cross-project feedback, references) |
| `claude-mem-projects` | `~/.claude/projects/` | per-project memories only — session jsonl files and runtime state are excluded via `.stignore` |

## Daily commands

```bash
claude-sync-status              # health check: folder state, peer connections, conflicts
```

## Bootstrap on a new machine

```bash
spl                                          # sl pull --rebase to get latest dotfiles
brewsync                                     # installs syncthing formula
stow --target="$HOME" sync                   # this package
~/dotfiles/bootstrap/syncthing.sh            # configures local daemon
# Then ONCE from any peer:
~/dotfiles/bootstrap/syncthing-mesh.sh       # wires pairings via SSH-tunneled REST
```

The mesh script auto-skips unreachable peers, so you can run it whenever 2+ peers are online and add the rest later.

## Adding a new sync folder later

Uncomment the line in `~/.config/claude-sync/folders.conf`, then:

```bash
claude-sync-add-folder claude-plans \
  "$HOME/Notes/plans/claude-personal" \
  "Claude Plans" claude-plans
```

The helper appends to `folders.conf`, registers via Syncthing's REST API, deploys the matching stignore template, and shares with all currently-paired devices.

## Conflict handling

Both halves of the mesh merge bidirectionally. When two machines have different content for the same path, Syncthing keeps the most-recent-mtime version under the canonical name and saves the other as `<original>.sync-conflict-<timestamp>-<deviceID>.<ext>`. Use the `/memory-sync` skill to audit and resolve.

Deleted files are kept under `<folder>/.stversions/` for 5 versions as insurance.

## Trust anchor

Pairing piggybacks on the existing Tailscale SSH mesh. `syncthing-mesh.sh` SSHes to each peer, reads its device ID file (`~/.claude/.syncthing-device-id`), opens an SSH-tunneled REST connection to its Syncthing daemon, and wires the `POST /rest/config/devices` + `PUT /rest/config/folders/<id>` calls. No QR codes, no manual web-UI work.

## Files in this package

```
sync/
├── .config/claude-sync/
│   ├── folders.conf                       # declarative folder list
│   └── stignore/
│       ├── claude-memory                  # template for ~/.claude/memory/.stignore
│       └── claude-projects                # template for ~/.claude/projects/.stignore (re-includes only **/memory/**)
└── .local/bin/
    ├── claude-sync-status                 # health check
    └── claude-sync-add-folder             # extensibility helper
```

## Operational quirks

- **Syncthing v2 requires API-key auth on every endpoint, even `/rest/system/ping`** (returns 403 CSRF unauthenticated). The bootstrap script reads the key from `~/Library/Application Support/Syncthing/config.xml` via `xmllint` BEFORE waiting for the daemon to respond.
- **`brew "syncthing"` not `cask "syncthing"`** — the cask installs `Syncthing.app` (GUI bundle), which doesn't put the CLI on PATH. The formula is what `brew services` and `bootstrap/syncthing.sh` need.
- **`bash 4+` required** for `mapfile` and `declare -A`. macOS `/bin/bash` is 3.2; `#!/usr/bin/env bash` resolves to Homebrew's bash 5+ which is installed via the dev brew module.
- **`.consolidate-lock` files** (Claude Code's per-machine memory-edit locks) must NOT sync — already in `.stignore`.

## Background

- Spec: `~/notes/projects/dotfiles/2026-05-10-claude-memory-sync-design.md`
- Plan: `~/notes/projects/dotfiles/2026-05-10-claude-memory-sync-plan.md`
