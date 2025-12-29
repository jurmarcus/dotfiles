# Show project context for Claude
function context
    echo "## Project: "(basename $PWD)
    echo ""
    echo "### Structure"
    eza --tree -L 2 --icons --group-directories-first
    echo ""
    echo "### Git Status"
    git status --short 2>/dev/null; or echo "Not a git repo"
    echo ""
    echo "### Recent Changes"
    git log --oneline -5 2>/dev/null
end
