# Sync Homebrew with Brewfile
function brewsync
    echo "==> Installing from Brewfile..."
    brew bundle --global

    echo ""
    echo "==> Checking for orphans (installed but not in Brewfile)..."
    set orphans (brew bundle cleanup --global 2>/dev/null)

    if test -z "$orphans"
        echo "No orphans found"
    else
        echo $orphans
        if test "$argv[1]" = "clean"
            echo ""
            echo "==> Removing orphans..."
            brew bundle cleanup --global --force
        else
            echo ""
            echo "Run 'brewsync clean' to remove these"
        end
    end
end
