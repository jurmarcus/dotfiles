# TypeScript / bun project helpers

function ts-init --description "Initialize TypeScript project with bun"
    set name (test -n "$argv[1]"; and echo $argv[1]; or echo ".")
    if test "$name" != "."
        mkdir -p $name
        cd $name
    end
    bun init -y; and bun add -d typescript @types/bun
    echo "Created TypeScript project with bun"
end
