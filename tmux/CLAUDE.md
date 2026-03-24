# Tmux Stow Package

Terminal multiplexer config with OSC 52 clipboard integration that works through any nesting of tmux, mosh, ET (Eternal Terminal), and SSH sessions.

## Files

```
tmux/
├── .config/tmux/tmux.conf      # Main tmux configuration
├── .local/bin/osc52-copy        # OSC 52 clipboard helper script
├── CLAUDE.md                    # This file
└── README.md                    # User-facing docs
```

## OSC 52 Clipboard Architecture

### The Problem

Copying text inside a remote tmux session (e.g., tmux inside mosh inside tmux) needs to reach the **local** macOS/Linux clipboard. Standard tmux copy (`copy-selection-and-cancel`) only writes to tmux's internal paste buffer — it never leaves the remote machine.

tmux has built-in OSC 52 support via `set-clipboard on`, but it fails in nested scenarios because tmux server runs as a daemon with no controlling terminal. The built-in mechanism can't reliably write OSC 52 sequences to the correct output.

### The Solution: `osc52-copy`

A 4-line shell script that explicitly sends OSC 52 to the tmux client's TTY:

```sh
#!/bin/sh
TTY=$(tmux display-message -p "#{client_tty}")
printf "\033]52;c;%s\a" "$(base64 | tr -d "\n")" > "$TTY"
```

**How it works:**

1. tmux's `copy-pipe-and-cancel "osc52-copy"` pipes selected text to the script's stdin
2. The script asks tmux for the **client TTY** — the actual PTY device the tmux client is attached to (e.g., `/dev/ttys005` on macOS, `/dev/pts/3` on Linux)
3. It base64-encodes the text and wraps it in an OSC 52 escape sequence: `ESC ] 52 ; c ; <base64> BEL`
4. It writes the sequence directly to the client TTY

**Why `#{client_tty}` is the key insight:**

- `/dev/tty` doesn't work because tmux server is a daemon with no controlling terminal
- Writing to stdout doesn't work because `copy-pipe` command stdout is discarded
- Writing to `#{pane_tty}` would output visible garbage in the shell pane
- `#{client_tty}` is the actual terminal device that feeds into the next layer (mosh, SSH, outer tmux, or the terminal emulator)

### The Escape Chain

In a deeply nested session like:

```
Ghostty → tmux (local) → mosh → tmux (remote) → shell
```

When copying in the inner tmux:

1. Inner tmux runs `osc52-copy`, which writes OSC 52 to the inner tmux's client TTY (mosh's remote PTY)
2. mosh-server relays OSC 52 over UDP to mosh-client
3. mosh-client outputs to the outer tmux pane
4. Outer tmux has `set-clipboard on` — it intercepts the OSC 52, stores it in its paste buffer, and forwards a new OSC 52 to Ghostty
5. Ghostty processes OSC 52 and writes to the macOS system clipboard

The same chain works with ET or plain SSH instead of mosh. It also works with any terminal emulator that supports OSC 52 (Ghostty, iTerm2, Alacritty, WezTerm, kitty, Windows Terminal).

### Critical tmux.conf Settings

```tmux
# These three settings enable the clipboard pipeline:
set -s set-clipboard on          # Accept incoming OSC 52 + forward to terminal
set -g allow-passthrough on      # Allow DCS passthrough (for other escape sequences)

# Copy bindings must use copy-pipe-and-cancel with osc52-copy:
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "osc52-copy"
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "osc52-copy"
```

**Important:** Do NOT use `copy-selection-and-cancel` — it only copies to tmux's internal buffer and never sends OSC 52.

## Deployment

### macOS (via stow)

```bash
cd ~/dotfiles && stow tmux
# Creates:
#   ~/.config/tmux/tmux.conf -> dotfiles symlink
#   ~/.local/bin/osc52-copy  -> dotfiles symlink
```

Requires `~/.local/bin` in PATH (already set in zsh and fish configs).

### Linux remote machines (manual)

For machines not managed by stow (NAS boxes, servers):

```bash
# Copy tmux.conf
scp ~/dotfiles/tmux/.config/tmux/tmux.conf <host>:~/.config/tmux/tmux.conf

# Copy osc52-copy
scp ~/dotfiles/tmux/.local/bin/osc52-copy <host>:~/.local/bin/osc52-copy
ssh <host> 'chmod +x ~/.local/bin/osc52-copy'
```

Ensure `~/.local/bin` is in PATH on the remote machine.

### Android (Termux)

The same tmux.conf and osc52-copy work in Termux. Deploy the same way as Linux. Termux's terminal supports OSC 52.

## Troubleshooting

### Clipboard not working

1. **Test the raw chain** — run this inside the remote tmux:
   ```bash
   printf '\e]52;c;%s\a' $(echo -n "test" | base64)
   ```
   Then Cmd+V. If "test" appears, the terminal chain works and the issue is in tmux config.

2. **Check bindings** — verify copy-pipe is active, not copy-selection:
   ```bash
   tmux list-keys | grep "copy-mode-vi.*y "
   # Should show: copy-pipe-and-cancel "osc52-copy"
   ```

3. **Check osc52-copy is in PATH:**
   ```bash
   which osc52-copy
   ```

4. **Check tmux clipboard settings:**
   ```bash
   tmux show -s set-clipboard        # Should be: on
   tmux show -g allow-passthrough    # Should be: on
   ```

5. **Check terminal features:**
   ```bash
   tmux display -p '#{client_termfeatures}'
   # Should include: clipboard
   ```

### Terminal emulator requirements

The **local** terminal emulator must support OSC 52 clipboard writes. Verified working:
- Ghostty (default `clipboard-write = allow`)
- iTerm2 (enable in Preferences → General → Selection → "Applications in terminal may access clipboard")
- Alacritty, WezTerm, kitty (enabled by default)
- Windows Terminal (enabled by default)
- Termux (enabled by default)

### mosh requirements

mosh 1.4.0+ is required for OSC 52 relay. Check with `mosh --version`.

### ET (Eternal Terminal) requirements

ET 6.2.11+ works. If ET breaks after a brew upgrade (protobuf dylib mismatch), rebuild with:
```bash
brew reinstall mistertea/et/et
```
