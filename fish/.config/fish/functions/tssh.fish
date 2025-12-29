# Tailscale quick connect (mosh with SSH fallback)
function tssh
    set host (test -n "$argv[1]"; and echo $argv[1]; or echo "studio")
    set -e argv[1]
    if command -q mosh
        mosh $host -- zellij attach -c main $argv
    else
        ssh -t $host "zellij attach -c main" $argv
    end
end
