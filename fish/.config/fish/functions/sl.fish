function sl --description "sl with no args → sl ssl (Super Smartlog); otherwise pass through"
    if test (count $argv) -eq 0
        command sl ssl
    else
        command sl $argv
    end
end
