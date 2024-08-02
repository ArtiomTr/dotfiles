
let configPath = match (sys host | get name) {
    "Windows" => $"($env.APPDATA)/sirse/config.toml",
    $platform => {
        error make {
            msg: $"Platform ($platform) is not supported"
        }
    }
}

def "sirse update" [
    --check;
    --channel: string
] {
    cd $"($env.APPDATA)/sirse/repo"

    if $channel != null {
        sirse config update.channel $channel
    }

    mut channel = sirse config update.channel

    if $channel == null {
        $channel = main
    }

    let latestCommit = ( git ls-remote origin $channel | parse --regex '(^[a-f0-9]+)\s' | rename hash | first | get hash)

    let lastUpdate = sirse config update.commit

    if $lastUpdate == $latestCommit {
        print "Nothing to update - already latest version."
        return;
    }

    if $check {
        if not (sirse confirm "New update available - do you want to install?") {
            return;
        }
    }

    print $"Syncing updates on channel ($channel)"

    git fetch --all err+out>> $"($env.APPDATA)/sirse/update.log"

    git switch --detach $latestCommit err+out>> $"($env.APPDATA)/sirse/update.log"

    sirse config update.commit $latestCommit

    print "Successfully updated configuration! Please, restart your shell now"
}

def "sirse config" [
    name?: cell-path;
    value?: any;
    --unset
] {
    let sirseConfig = if ($configPath | path exists) {
        open $configPath
    } else {
        mkdir $"($configPath | path dirname)"
    
        {} | save $configPath
    
        {}
    }

    if $name == null {
        return $sirseConfig
    } else if $unset {
        $sirseConfig | reject $name | save -f $configPath    
    } else if $value == null {
        return ($sirseConfig | get -i $name);
    } else {
        $sirseConfig | upsert $name $value | save -f $configPath
    }
}

def "sirse choose" [
    options; 
    prompt?: string;
] {
    let selectedLabel = if (which gum | is-empty) {
        $options | get label | input list $prompt
    } else {
        if ($prompt != null) {
            gum choose --header $prompt ...($options | get label)
        } else {
            gum choose ...($options | get label)
        }
    }

    let item = $options | where label == $selectedLabel | first;

    return $item.value
}

def "sirse pick-file" [] {
    if (which gum | is-empty) {
        return (input "Enter file path: ");
    } else {
        return (gum file --file);
    }
}

def "sirse confirm" [prompt: string] {
    if (which gum | is-empty) {
        let output = ["Yes", "No"] | input list $prompt;

        return ($output == "Yes");
    } else {
        try { gum confirm $prompt; return true; } catch { return false; }
    }
}

def "sirse install-manager get" [package: string] {
    let packages = [
        { package: "gum", windows: { manager: "winget", package: "charmbracelet.gum" } },
        { package: "starship", windows: { manager: "winget", package: "starship" } },
        { package: "zoxide", windows: { manager: "winget", package: "ajeetdsouza.zoxide" } },
        { package: "bat", windows: { manager: "winget", package: "sharkdp.bat" } },
        { package: "ripgrep", windows: { manager: "winget", package: "BurntSushi.ripgrep.MSVC" } }
    ];

    let infos = $packages | where package == $package;
    
    if ($infos | is-empty) {
        error make {
            msg: "Unable to find package",
            label: {
                text: "Unknown package",
                span: (metadata $package).span,
            }
        }
    } else {
        return ($infos | first);
    }
}

def "sirse install-manager add" [
    package: string;
    --prompt
] {
    if (sirse config (["packages", $package] | into cell-path)) != null {
        return;
    }

    if (which $package | is-not-empty) {
        return;
    }

    if $prompt {
        let promptResult = sirse confirm $"Package ($package) is missing. Do you want to install it?";

        sirse config (["packages", $package] | into cell-path) $promptResult

        if $promptResult == false {
            return;
        }
    }

    let info =  try {
        sirse install-manager get $package;
    } catch {
        error make {
            msg: "Unable to install package",
            label: {
                text: "Unknown package",
                span: (metadata $package).span,
            }
        }
    }

    match (sys host | get name) {
        "Windows" => {
            print $info.windows.manager;

            match $info.windows.manager {
                "winget" => {
                    winget install $info.windows.package
                },
                $manager => {
                    error make {
                        msg: $"Unknown manager $($manager) encountered."
                    }
                }
            }
        },
        $platform => {
            error make {
                msg: $"Platform $($platform) is not supported"
            }
        }
    }

    print "Package successfully installed. You may need to restart your shell."
}

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

        let editor = (sirse pick-file);

        sirse config editor.path;
    } else if (($installedEditors | length) == 1) {
        let editor = $installedEditors | first;

        print $"Selected ($editor.label) editor";

        sirse config editor.program $editor.value
    } else {
        let editor = sirse choose ($possibleEditors | append { label: "Other...", value: "other" }) "Select your preferred editor";

        if $editor == "other" {
            let editor = (sirse pick-file);

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
