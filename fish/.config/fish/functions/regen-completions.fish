# Regenerate cached completions (run once, or after tool updates)

function regen-completions --description "Regenerate shell completions for CLI tools"
    set dir (string replace -r '^$' ~/.config "$XDG_CONFIG_HOME")/fish/completions
    mkdir -p $dir
    echo "Generating completions to $dir..."
    uv generate-shell-completion fish >$dir/uv.fish
    gh completion -s fish >$dir/gh.fish
    op completion fish >$dir/op.fish
    just --completions fish >$dir/just.fish
    echo "Done. Restart shell to use."
end
