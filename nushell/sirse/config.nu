export def main [
    name?: cell-path;
    value?: any;
    --unset
] {
    let configPath = dir "config.toml";

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
};

export def dir [name?: string] {
    let configDir = (match (sys host | get name) {
        "Windows" => $"($env.APPDATA)\\sirse",
        $platform => {
            error make {
                msg: $"Platform ($platform) is not supported"
            }
        }
    });

    if $name != null {
        return ([$configDir, $name] | path join);
    } else {
        return $configDir;
    }
}
