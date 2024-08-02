use sirse;

sirse install-manager add gum --prompt;

if ((sirse config editor) == null) {
    let possibleEditors = [{
        value: "code",
        label: "Visual Studio Code"
    }, {
        value: "codium",
        label: "VSCodium"
    }];

    let installedEditors = $possibleEditors | each { |it| if (which $it.value | is-not-empty) { $it } };

    if ($installedEditors | is-empty) {
        print "No editors detected - please specify path to editor";

        let editor = (sirse ui pick-file);

        sirse config editor.path;
    } else if (($installedEditors | length) == 1) {
        let editor = $installedEditors | first;

        print $"Selected ($editor.label) editor";

        sirse config editor.program $editor.value
    } else {
        let editor = sirse ui choose ($possibleEditors | append { label: "Other...", value: "other" }) "Select your preferred editor";

        if $editor == "other" {
            let editor = (sirse ui pick-file);

            sirse config editor.path $editor
        } else {
            sirse config editor.program $editor
        }
    }
}

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
$env.EDITOR = if ((sirse config editor.program) != null) {
    let editor = (sirse config editor.program);

    which $editor | first | get path | str replace -a "\\" "/"
} else {
    sirse config editor.path | str replace -a "\\" "/"
}

sirse install-manager add starship --prompt;
sirse install-manager add zoxide --prompt;
sirse install-manager add bat --prompt;

mkdir ~/.cache/starship
if (which starship | is-not-empty) {
    starship init nu | str replace -n " -c" "" | save -f ~/.cache/starship/init.nu    
} else {
    touch ~/.cache/starship/init.nu
}

mkdir ~/.cache/zoxide
if (which zoxide | is-not-empty) {
    zoxide init nushell | str replace -a "cd" "builtin-cd" | save -f ~/.cache/zoxide/init.nu    
} else {
    touch ~/.cache/zoxide/init.nu
}
