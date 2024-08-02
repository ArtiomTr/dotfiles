export def main [
    name?: cell-path;
    value?: any;
    --unset
] {
    let configPath = match (sys host | get name) {
        "Windows" => $"($env.APPDATA)/sirse/config.toml",
        $platform => {
            error make {
                msg: $"Platform ($platform) is not supported"
            }
        }
    }

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
