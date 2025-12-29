# Re-stow all dotfiles packages
function restow
    set orig_dir $PWD
    cd $DOTFILES; or return 1
    for dir in */
        set dir (string trim -r -c "/" $dir)
        if test "$dir" = "bootstrap"
            continue
        end
        echo "Restowing $dir..."
        stow -R $dir
    end
    cd $orig_dir
    echo "Done restowing all packages"
end
