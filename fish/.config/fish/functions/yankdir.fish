# Copy directory tree to clipboard
function yankdir
    set depth (test -n "$argv[2]"; and echo $argv[2]; or echo 2)
    set dir (test -n "$argv[1]"; and echo $argv[1]; or echo ".")
    eza --tree -L $depth --icons $dir | pbcopy
    echo "Copied directory tree to clipboard"
end
