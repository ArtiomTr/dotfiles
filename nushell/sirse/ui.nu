export def choose [
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

export def pick-file [] {
    if (which gum | is-empty) {
        return (input "Enter file path: ");
    } else {
        return (gum file --file);
    }
}

export def confirm [prompt: string] {
    if (which gum | is-empty) {
        let output = ["Yes", "No"] | input list $prompt;

        return ($output == "Yes");
    } else {
        try { gum confirm $prompt; return true; } catch { return false; }
    }
}
