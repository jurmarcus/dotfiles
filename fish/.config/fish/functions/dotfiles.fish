# Dotfiles management

function restow --description "Re-stow all dotfiles packages"
    set orig_dir $PWD
    cd $DOTFILES; or return 1
    for dir in */
        set dir (string trim -r -c "/" $dir)
        test "$dir" = "bootstrap"; and continue
        echo "Restowing $dir..."
        stow -R $dir
    end
    cd $orig_dir
    echo "Done restowing all packages"
end

function brewsync --description "Sync Homebrew with Brewfile"
    if brew bundle check --global >/dev/null 2>&1
        echo "==> All packages already installed"
    else
        echo "==> Installing from Brewfile..."
        brew bundle --global
    end

    echo ""
    echo "==> Checking for orphans..."
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
