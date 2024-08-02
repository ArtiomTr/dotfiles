module config-manager {
    export use config.nu *;

    export def main [] {}
}

use config-manager;
use ui.nu;

export def main [
    --check;
    --channel: string
] {
    cd $"(config-manager dir repo)"

    if $channel != null {
        config-manager config update.channel $channel
    }

    mut channel = config-manager config update.channel

    if $channel == null {
        $channel = main
    }

    let latestCommit = (git ls-remote origin $channel | parse --regex '(^[a-f0-9]+)\s' | rename hash | first | get hash)

    let lastUpdate = config-manager config update.commit

    if $lastUpdate == $latestCommit {
        print "Nothing to update - already latest version."
        return;
    }

    if $check {
        if not (ui confirm "New update available - do you want to install?") {
            return;
        }
    }

    print $"Syncing updates on channel ($channel)"

    git fetch --all err+out>> $"(config-manager dir update.log)"

    git switch --detach $latestCommit err+out>> $"(config-manager dir update.log)"

    config-manager config update.commit $latestCommit

    print "Successfully updated configuration! Please, restart your shell now"
}

export def auto [] {}
