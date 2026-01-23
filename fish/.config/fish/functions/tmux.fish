# Tmux session management

# Machine slug from hostname (methylene-macbook → macbook)
function _machine --description "Get machine slug from hostname"
    set host (hostname -s)
    if string match -q 'methylene-*' $host
        string replace 'methylene-' '' $host
    else
        echo $host
    end
end

# Rename current tmux session to machine-prefix-N
function _trename --description "Rename current session to machine-prefix-N"
    set prefix (_machine)-$argv[1]
    set n 1
    while tmux has-session -t "$prefix-$n" 2>/dev/null
        set n (math $n + 1)
    end
    tmux rename-session "$prefix-$n"
    echo "Renamed to $prefix-$n"
end

# fzf-based tmux session picker (uses exec - single exit closes terminal)
function _tmux_picker --description "fzf tmux picker with exec"
    set prefix (_machine)-dev
    set sessions (tmux list-sessions -F '#{session_name}: #{session_windows} win#{?session_attached, (attached),}' 2>/dev/null)

    if test -z "$sessions"
        exec tmux new-session -s "$prefix-1"
    end

    set choice (printf '%s\n+ new session' $sessions | fzf --height=40% --reverse --prompt="tmux> ")

    switch "$choice"
        case "+ new session"
            set n 1
            while tmux has-session -t "$prefix-$n" 2>/dev/null
                set n (math $n + 1)
            end
            exec tmux new-session -s "$prefix-$n"
        case ""
            exit 0  # cancelled - close terminal
        case '*'
            exec tmux attach -t (string split ':' $choice)[1]
    end
end

function tclaude --description "Rename session to claude-N"
    _trename claude
end

function topencode --description "Rename session to opencode-N"
    _trename opencode
end

function tservice --description "Rename session to service-N"
    _trename service
end
