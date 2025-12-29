# Initialize Python project with uv
function pyinit
    set name (test -n "$argv[1]"; and echo $argv[1]; or echo ".")
    if test "$name" != "."
        mkdir -p $name
        cd $name
    end
    uv init; and uv add --dev ruff pytest
    echo "Created Python project with uv"
end
