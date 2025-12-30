# Claude workflow helpers

function context --description "Show project context for Claude"
    echo "## Project: "(basename $PWD)
    echo ""
    echo "### Structure"
    eza --tree -L 2 --icons --group-directories-first
    echo ""
    echo "### Status"
    sl status 2>/dev/null or echo "Not a repo"
    echo ""
    echo "### Recent Changes"
    sl log -l 5 2>/dev/null or true
end

function yank --description "Copy file contents to clipboard"
    if test -f "$argv[1]"
        bat --style=plain "$argv[1]" | pbcopy
        set lines (wc -l < "$argv[1]" | string trim)
        echo "Copied $argv[1] to clipboard ($lines lines)"
    else
        echo "File not found: $argv[1]"
    end
end

function yankdir --description "Copy directory tree to clipboard"
    set depth (test -n "$argv[2]"; and echo $argv[2]; or echo 2)
    set dir (test -n "$argv[1]"; and echo $argv[1]; or echo ".")
    eza --tree -L $depth --icons $dir | pbcopy
    echo "Copied directory tree to clipboard"
end

function watch --description "Watch files and run command"
    set ext (test -n "$argv[2]"; and echo $argv[2]; or echo "py,ts,js,rs")
    watchexec -e $ext -- $argv[1]
end
