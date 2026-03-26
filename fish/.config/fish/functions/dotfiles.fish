# Dotfiles management

function restow --description "Re-stow all dotfiles packages"
    set -l host (string lower -- (hostname -s))
    if set -q HOST_OVERRIDE
        set host (string lower -- $HOST_OVERRIDE)
    end

    set -l host_file "$DOTFILES/stow/.config/stow/hosts/$host.conf"
    set -l packages

    if test -f $host_file
        # Read package list from host file (strip comments and blanks)
        for line in (string replace -r '#.*' '' < $host_file)
            set line (string trim $line)
            test -n "$line"; and set -a packages $line
        end
    else
        echo "⚠️  No stow host file for '$host' — stowing all packages"
        for dir in $DOTFILES/*/
            set dir (basename $dir)
            switch $dir
                case '.git*' scripts bin images docs '.github*' private bootstrap
                    continue
            end
            set -a packages $dir
        end
    end

    echo "Host: $host ("(count $packages)" packages)"

    set orig_dir $PWD
    cd $DOTFILES; or return 1
    for dir in $packages
        if not test -d $dir
            echo "Warning: $dir not found, skipping"
            continue
        end
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
