module config-manager {
    export use config.nu *;

    export def main [] {}
}

use config-manager;

def inner_set [key: string, value: string, expires: duration] {
    let $cachePath = (config-manager dir cache.db);

    if (not ($cachePath | path exists)) {
        [["index", "value", "expires"]; [$key $value ((date now) + $expires)]] | into sqlite $cachePath -t caches
    } else {
        let $db = (open $cachePath);

        $db | query db "DELETE FROM caches WHERE datetime(expires) < datetime()";
        $db | query db "INSERT INTO caches(\"index\", \"value\", \"expires\") VALUES (?, ?, ?)" -p [$key $value ((date now) + $expires)];
    }
}

def inner_get [name: string] {
    let $cachePath = (config-manager dir cache.db);

    if (not ($cachePath | path exists)) {
        return null;
    } else {
        let rows = (open $cachePath | query db "SELECT value FROM caches WHERE \"index\" = ? AND datetime(expires) >= datetime() ORDER BY expires DESC LIMIT 1" -p [$name]);

        if ($rows | is-empty) {
            return null;
        } else {
            return ($rows | first).value;
        }
    }
}

export def set [key: string, value: string, expires: duration] {
    inner_set $key $value $expires
}

export def get [name: string] {
    return (inner_get $name);
}

export def clear [] {
    let $cachePath = (config-manager dir cache.db);

    if not ($cachePath | path exists) {
        return;
    }

    open $cachePath | query db "DELETE FROM caches WHERE 1";
}

export def upsert [name: string, upd: closure] {
    let value = inner_get $name;

    if $value != null {
        return $value;
    } else {
        let $out = (do $upd);

        inner_set $name $out.value $out.expires;

        return $out.value;
    }
}

export def main [] {}
