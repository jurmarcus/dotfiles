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

function _tmux_picker --description "fzf-based tmux session picker"
    set sessions (tmux list-sessions -F '#{session_name}: #{session_windows} win#{?session_attached, (attached),}' 2>/dev/null)

    if test -z "$sessions"
        _tnew dev
        return
    end

    set choice (printf '%s\n+ new session' $sessions | fzf --height=40% --reverse --prompt="tmux> ")

    switch "$choice"
        case "+ new session"
            _tnew dev
        case ""
            return 0  # cancelled, stay in shell
        case '*'
            tmux attach -t (string split ':' $choice)[1]
    end
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
