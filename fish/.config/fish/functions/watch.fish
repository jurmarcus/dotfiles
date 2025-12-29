# Watch files and run command
function watch
    set ext (test -n "$argv[2]"; and echo $argv[2]; or echo "py,ts,js,rs")
    watchexec -e $ext -- $argv[1]
end
