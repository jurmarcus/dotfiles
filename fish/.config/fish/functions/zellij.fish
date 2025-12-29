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