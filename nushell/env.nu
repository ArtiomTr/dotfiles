# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
$env.EDITOR = (which codium | first | get path)

mkdir ~/.cache/starship
starship init nu | str replace -n " -c" "" | save -f ~/.cache/starship/init.nu
mkdir ~/.cache/zoxide
zoxide init nushell | save -f ~/.cache/zoxide/init.nu
