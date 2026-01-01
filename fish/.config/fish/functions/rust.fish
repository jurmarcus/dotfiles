# Rust / cargo project helpers

function rs-init --description "Initialize Rust project with cargo"
    set name (test -n "$argv[1]"; and echo $argv[1]; or echo ".")
    if test "$name" != "."
        cargo new $name; and cd $name
    else
        cargo init
    end
    echo "Created Rust project with cargo"
end
