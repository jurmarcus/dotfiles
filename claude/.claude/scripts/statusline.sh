#!/bin/bash
# Claude Code status line: sl bookmark · hostname
# Must be fast (<100ms) — runs on every render
b=$(sl log -r . --template '{bookmarks}' 2>/dev/null)
h=$(hostname -s)
[ -n "$b" ] && echo "$b · $h" || echo "$h"
