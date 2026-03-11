# SSH wrapper - rename tmux window to hostname
function ssh --description "SSH with tmux window rename" --wraps ssh
    set -l host ""
    set -l skip_next false
    for arg in $argv
        if test "$skip_next" = true
            set skip_next false
            continue
        end
        switch $arg
            case '-b' '-c' '-D' '-E' '-e' '-F' '-I' '-i' '-J' '-L' '-l' '-m' '-O' '-o' '-p' '-Q' '-R' '-S' '-W' '-w'
                set skip_next true
            case '-*'
                # flags without args, skip
            case '*'
                set host $arg
                break
        end
    end

    # Strip user@ prefix
    set host (string replace -r '.*@' '' $host)

    # Set tmux window name to hostname
    if set -q TMUX; and test -n "$host"
        tmux rename-window $host
    end

    TERM=xterm-256color command ssh $argv

    # Restore automatic window naming
    if set -q TMUX
        tmux set-window-option automatic-rename on
    end
end
