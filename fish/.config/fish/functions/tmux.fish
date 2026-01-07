# Tmux session management

function _tnew --description "Create numbered tmux session"
    set prefix $argv[1]
    set n 1
    set sessions (tmux list-sessions -F '#{session_name}' 2>/dev/null)
    while echo $sessions | grep -qx "$prefix-$n"
        set n (math $n + 1)
    end
    tmux new-session -s "$prefix-$n"
end

function tclaude --description "New Claude session (claude-1, claude-2, ...)"
    _tnew claude
end

function topencode --description "New OpenCode session"
    _tnew opencode
end

function tservice --description "New service session"
    _tnew service
end
