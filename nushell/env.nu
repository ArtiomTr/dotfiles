# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
$env.EDITOR = (which codium | first | get path)

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
        { package: "bat", windows: { manager: "winget", package: "sharkdp.bat" } }
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
    if $prompt and ((which $package | is-not-empty) or not (sirse confirm $"Package ($package) is missing. Do you want to install it?")) {
        return;
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
}

sirse install-manager add gum --prompt;
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
    zoxide init nushell | str replace "cd" "builtin-cd" | save -f ~/.cache/zoxide/init.nu    
} else {
    touch ~/.cache/zoxide/init.nu
}
