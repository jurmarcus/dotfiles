# Dev connect wrappers with tmux window naming
# Only for local machines (hostname starts with allenj)

function _tmux_name --description 'Set tmux window name and disable auto-rename'
    if set -q TMUX
        tmux rename-window "$argv[1]"
        tmux set-window-option automatic-rename off
    end
end

function det --description 'Dev connect via ET with tmux naming'
    if string match -q 'allenj*' (hostname -s)
        if test -n "$argv[1]"
            _tmux_name "et:"(string split -f1 '.' $argv[1])
        else
            _tmux_name "et"
        end
        TERM=xterm-256color command dev connect --et $argv
    else
        echo "det: only available on local machines"
    end
end

function dmosh --description 'Dev connect via mosh with tmux naming'
    if string match -q 'allenj*' (hostname -s)
        if test -n "$argv[1]"
            _tmux_name "mosh:"(string split -f1 '.' $argv[1])
        else
            _tmux_name "mosh"
        end
        TERM=xterm-256color command dev connect --mosh $argv
    else
        echo "dmosh: only available on local machines"
    end
end

function dssh --description 'Dev connect via SSH with tmux naming'
    if string match -q 'allenj*' (hostname -s)
        if test -n "$argv[1]"
            _tmux_name "ssh:"(string split -f1 '.' $argv[1])
        else
            _tmux_name "ssh"
        end
        TERM=xterm-256color command dev connect --ssh $argv
    else
        echo "dssh: only available on local machines"
    end
end

# TERM wrapper for base dev command
function dev --description 'Dev command with proper TERM'
    if string match -q 'allenj*' (hostname -s)
        TERM=xterm-256color command dev $argv
    else
        command dev $argv
    end
end
