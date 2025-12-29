# Helper: create numbered zellij session
function _znew
    set prefix $argv[1]
    set n 1
    set sessions (zellij list-sessions 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g')
    while echo $sessions | grep -q "^$prefix-$n "
        set n (math $n + 1)
    end
    zellij --session "$prefix-$n"
end
