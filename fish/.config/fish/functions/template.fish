# Simple mustache-style template: {{VAR}} gets replaced
# Usage: template file.tpl VAR=value VAR2=value2
function template
    set file $argv[1]
    set -e argv[1]
    set content (cat $file)
    for arg in $argv
        set key (string split -m 1 = $arg)[1]
        set val (string split -m 1 = $arg)[2]
        set content (string replace -a "{{$key}}" $val $content)
    end
    echo $content
end
