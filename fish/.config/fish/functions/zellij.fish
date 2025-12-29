# Zellij session management

function _znew --description "Create numbered zellij session"
    set prefix $argv[1]
    set n 1
    set sessions (zellij list-sessions 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g')
    while echo $sessions | grep -q "^$prefix-$n "
        set n (math $n + 1)
    end
    zellij --session "$prefix-$n"
end

function zclaude --description "New Claude session (claude-1, claude-2, ...)"
    _znew claude
end

function zopencode --description "New OpenCode session"
    _znew opencode
end

function zservice --description "New service session"
    _znew service
end

function zcd --description "Switch to zellij session"
    zellij attach $argv[1]
end

function zrm --description "Delete zellij session"
    zellij delete-session $argv
end

function zdev --description "Show zellij session help"
    echo "Zellij sessions:"
    echo "  zssh      - ssh session (shared)"
    echo "  zclaude   - new claude session (claude-1, claude-2, ...)"
    echo "  zopencode - new opencode session"
    echo "  zservice  - new service session"
    echo "  zls       - list sessions"
    echo "  zcd NAME  - switch to session"
    echo "  zrm NAME  - delete session"
    echo ""
    zellij list-sessions 2>/dev/null; or echo "No active sessions"
end
