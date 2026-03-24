# Eternal Terminal - persistent remote sessions

# Direct tmux session via et (bypasses picker, reconnects to named session)
function etmux --description "Connect via et with direct tmux session"
    set host $argv[1]
    set session (test (count $argv) -ge 2; and echo $argv[2]; or echo main)

    if test -z "$host"
        echo "Usage: etmux <host> [session]"
        return 1
    end

    et $host -c "tmux new-session -A -s $session"
end
