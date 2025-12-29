# Copy file contents to clipboard
function yank
    if test -f "$argv[1]"
        bat --style=plain "$argv[1]" | pbcopy
        set lines (wc -l < "$argv[1]" | string trim)
        echo "Copied $argv[1] to clipboard ($lines lines)"
    else
        echo "File not found: $argv[1]"
    end
end
