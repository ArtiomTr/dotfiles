module config-manager {
    export use config.nu *;

    export def main [] {}
}

use config-manager;

export def main [] {}

export def find-pkg [package: string] {
    let packages = [
        { package: "gum", windows: { manager: "winget", package: "charmbracelet.gum" }, debian: { manager: "brew", package: "gum" } },
        { package: "starship", windows: { manager: "winget", package: "starship" }, debian: { manager: "brew", package: "starship" } },
        { package: "zoxide", windows: { manager: "winget", package: "ajeetdsouza.zoxide" }, debian: { manager: "brew", package: "zoxide" } },
        { package: "bat", windows: { manager: "winget", package: "sharkdp.bat" }, debian: { manager: "brew", package: "bat" } },
        { package: "ripgrep", windows: { manager: "winget", package: "BurntSushi.ripgrep.MSVC" }, debian: { manager: "brew", package: "ripgrep" } }
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

export def add [
    package: string;
    --prompt
] {
    if (config-manager config (["packages", $package] | into cell-path)) != null {
        return;
    }

    if (which $package | is-not-empty) {
        return;
    }

    if $prompt {
        let promptResult = sirse confirm $"Package ($package) is missing. Do you want to install it?";

        config-manager config (["packages", $package] | into cell-path) $promptResult

        if $promptResult == false {
            return;
        }
    }

    let info =  try {
        find-pkg $package;
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
        "Ubuntu" => {
            match $info.debian.manager {
                "brew" => {
                    brew install $info.debian.package
                },
                $manager => {
                    error make {
                        msg: $"Unknown manager $($manager) encountered."
                    }
                }
            }
        }
        $platform => {
            error make {
                msg: $"Platform $($platform) is not supported"
            }
        }
    }

    print "Package successfully installed. You may need to restart your shell."
}
