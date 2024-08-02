module completions {
  # Custom completions for external commands (those outside of Nushell)
  # Each completions has two parts: the form of the external command, including its flags and parameters
  # and a helper command that knows how to complete values for those flags and parameters
  #
  # This is a simplified version of completions for git branches and git remotes
  def "nu-complete git branches" [] {
    ^git branch | lines | each { |line| $line | str replace -r '[\*\+] ' '' | str trim }
  }

  def "nu-complete git remotes" [] {
    ^git remote | lines | each { |line| $line | str trim }
  }

  def "nu-complete git cmsg" [] {
    ^git status --porcelain | lines | parse -r '^(.{2})\s(.+)$' | rename status filename | where status == "A " | where filename =~ ".changeset" | each { |changeset| $"\"($changeset.filename | open --raw | parse "---\n{type}\n---\n{content}" | first | get content | str trim)\"" }
  }

  # Download objects and refs from another repository
  export extern "git fetch" [
    repository?: string@"nu-complete git remotes" # name of the repository to fetch
    branch?: string@"nu-complete git branches" # name of the branch to fetch
    --all                                         # Fetch all remotes
    --append(-a)                                  # Append ref names and object names to .git/FETCH_HEAD
    --atomic                                      # Use an atomic transaction to update local refs.
    --depth: int                                  # Limit fetching to n commits from the tip
    --deepen: int                                 # Limit fetching to n commits from the current shallow boundary
    --shallow-since: string                       # Deepen or shorten the history by date
    --shallow-exclude: string                     # Deepen or shorten the history by branch/tag
    --unshallow                                   # Fetch all available history
    --update-shallow                              # Update .git/shallow to accept new refs
    --negotiation-tip: string                     # Specify which commit/glob to report while fetching
    --negotiate-only                              # Do not fetch, only print common ancestors
    --dry-run                                     # Show what would be done
    --write-fetch-head                            # Write fetched refs in FETCH_HEAD (default)
    --no-write-fetch-head                         # Do not write FETCH_HEAD
    --force(-f)                                   # Always update the local branch
    --keep(-k)                                    # Keep dowloaded pack
    --multiple                                    # Allow several arguments to be specified
    --auto-maintenance                            # Run 'git maintenance run --auto' at the end (default)
    --no-auto-maintenance                         # Don't run 'git maintenance' at the end
    --auto-gc                                     # Run 'git maintenance run --auto' at the end (default)
    --no-auto-gc                                  # Don't run 'git maintenance' at the end
    --write-commit-graph                          # Write a commit-graph after fetching
    --no-write-commit-graph                       # Don't write a commit-graph after fetching
    --prefetch                                    # Place all refs into the refs/prefetch/ namespace
    --prune(-p)                                   # Remove obsolete remote-tracking references
    --prune-tags(-P)                              # Remove any local tags that do not exist on the remote
    --no-tags(-n)                                 # Disable automatic tag following
    --refmap: string                              # Use this refspec to map the refs to remote-tracking branches
    --tags(-t)                                    # Fetch all tags
    --recurse-submodules: string                  # Fetch new commits of populated submodules (yes/on-demand/no)
    --jobs(-j): int                               # Number of parallel children
    --no-recurse-submodules                       # Disable recursive fetching of submodules
    --set-upstream                                # Add upstream (tracking) reference
    --submodule-prefix: string                    # Prepend to paths printed in informative messages
    --upload-pack: string                         # Non-default path for remote command
    --quiet(-q)                                   # Silence internally used git commands
    --verbose(-v)                                 # Be verbose
    --progress                                    # Report progress on stderr
    --server-option(-o): string                   # Pass options for the server to handle
    --show-forced-updates                         # Check if a branch is force-updated
    --no-show-forced-updates                      # Don't check if a branch is force-updated
    -4                                            # Use IPv4 addresses, ignore IPv6 addresses
    -6                                            # Use IPv6 addresses, ignore IPv4 addresses
    --help                                        # Display the help message for this command
  ]

  # Check out git branches and files
  export extern "git checkout" [
    ...targets: string@"nu-complete git branches"   # name of the branch or files to checkout
    --conflict: string                              # conflict style (merge or diff3)
    --detach(-d)                                    # detach HEAD at named commit
    --force(-f)                                     # force checkout (throw away local modifications)
    --guess                                         # second guess 'git checkout <no-such-branch>' (default)
    --ignore-other-worktrees                        # do not check if another worktree is holding the given ref
    --ignore-skip-worktree-bits                     # do not limit pathspecs to sparse entries only
    --merge(-m)                                     # perform a 3-way merge with the new branch
    --orphan: string                                # new unparented branch
    --ours(-2)                                      # checkout our version for unmerged files
    --overlay                                       # use overlay mode (default)
    --overwrite-ignore                              # update ignored files (default)
    --patch(-p)                                     # select hunks interactively
    --pathspec-from-file: string                    # read pathspec from file
    --progress                                      # force progress reporting
    --quiet(-q)                                     # suppress progress reporting
    --recurse-submodules: string                    # control recursive updating of submodules
    --theirs(-3)                                    # checkout their version for unmerged files
    --track(-t)                                     # set upstream info for new branch
    -b: string                                      # create and checkout a new branch
    -B: string                                      # create/reset and checkout a branch
    -l                                              # create reflog for new branch
    --help                                          # Display the help message for this command
  ]

  # List, create, or delete branches
  export extern "git branch" [
    ...targets: string@"nu-complete git branches"
    --delete(-d)                                    # Delete a branch
    -D                                              # Shortcut for `--delete --force`
    --create-reflog                                 # Create the branch’s reflog
    --force(-f)                                     # Reset <branchname> to <start-point>, even if <branchname> exists already
    --move(-m)                                      # Move/rename a branch, together with its config and reflog
    --copy(-c)                                      # Copy a branch, together with its config and reflog
    -C                                              # Shortcut for --copy --force
    --color: string                                 # Color branches to highlight current, local, and remote-tracking branches. The value must be always (the default), never, or auto
    --no-color                                      # Turn off branch colors, even when the configuration file gives the default to color output. Same as --color=never
    --ignore-case(-i)                               # Sorting and filtering branches are case insensitive.
    --omit-empty                                    # Do not print a newline after formatted refs where the format expands to the empty string
    --help                                          # Display the help message for this command
  ]

  # Push changes
  export extern "git push" [
    remote?: string@"nu-complete git remotes",      # the name of the remote
    ...refs: string@"nu-complete git branches"      # the branch / refspec
    --all                                           # push all refs
    --atomic                                        # request atomic transaction on remote side
    --delete(-d)                                    # delete refs
    --dry-run(-n)                                   # dry run
    --exec: string                                  # receive pack program
    --follow-tags                                   # push missing but relevant tags
    --force-with-lease                              # require old value of ref to be at this value
    --force(-f)                                     # force updates
    --ipv4(-4)                                      # use IPv4 addresses only
    --ipv6(-6)                                      # use IPv6 addresses only
    --mirror                                        # mirror all refs
    --no-verify                                     # bypass pre-push hook
    --porcelain                                     # machine-readable output
    --progress                                      # force progress reporting
    --prune                                         # prune locally removed refs
    --push-option(-o): string                       # option to transmit
    --quiet(-q)                                     # be more quiet
    --receive-pack: string                          # receive pack program
    --recurse-submodules: string                    # control recursive pushing of submodules
    --repo: string                                  # repository
    --set-upstream(-u)                              # set upstream for git pull/status
    --signed: string                                # GPG sign the push
    --tags                                          # push tags (can't be used with --all or --mirror)
    --thin                                          # use thin pack
    --verbose(-v)                                   # be more verbose
    --help                                          # Display the help message for this command
  ]

  export extern "git commit" [
    --all(-a)                                       # Tell the command to automatically stage files that have been modified and deleted, but new files you have not told Git about are not affected.
    --patch(-p)                                     # Use the interactive patch selection interface to choose which changes to commit.
    --reuse-message(-C): string                     # Take an existing commit object, and reuse the log message and the authorship information (including the timestamp) when creating the commit.
    --reedit-message(-c): string                    # Like -C, but with -c the editor is invoked, so that the user can further edit the commit message.
    --fixup: string
    --squash: string                                # Construct a commit message for use with rebase --autosquash. The commit message subject line is taken from the specified commit with a prefix of "squash! ". Can be used with additional commit message options (-m/-c/-C/-F).
    --reset-author                                  # When used with -C/-c/--amend options, or when committing after a conflicting cherry-pick, declare that the authorship of the resulting commit now belongs to the committer. This also renews the author timestamp.
    --short                                         # When doing a dry-run, give the output in the short-format. See git-status(1) for details. Implies --dry-run.
    --branch                                        # Show the branch and tracking info even in short-format.
    --porcelain                                     # When doing a dry-run, give the output in a porcelain-ready format. See git-status(1) for details. Implies --dry-run.
    --long                                          # When doing a dry-run, give the output in the long-format. Implies --dry-run.
    --null(-z)                                      # When showing short or porcelain status output, print the filename verbatim and terminate the entries with NUL, instead of LF. If no format is given, implies the --porcelain output format. Without the -z option, filenames with "unusual" characters are quoted as explained for the configuration variable core.quotePath (see git-config(1)).
    --file(-F): string                              # Take the commit message from the given file. Use - to read the message from the standard input.
    --author: string                                # Override the commit author. Specify an explicit author using the standard A U Thor <author@example.com> format. Otherwise <author> is assumed to be a pattern and is used to search for an existing commit by that author (i.e. rev-list --all -i --author=<author>); the commit author is then copied from the first such commit found.
    --date: string                                  # Override the author date used in the commit.
    --message(-m): string@"nu-complete git cmsg",   # Use the given <msg> as the commit message. If multiple -m options are given, their values are concatenated as separate paragraphs. The -m option is mutually exclusive with -c, -C, and -F.
    --template(-t): string                          # When editing the commit message, start the editor with the contents in the given file. The commit.template configuration variable is often used to give this option implicitly to the command. This mechanism can be used by projects that want to guide participants with some hints on what to write in the message in what order. If the user exits the editor without editing the message, the commit is aborted. This has no effect when a message is given by other means, e.g. with the -m or -F options.
    --signoff(-s)                                   # Add a Signed-off-by trailer by the committer at the end of the commit log message. The meaning of a signoff depends on the project to which you’re committing. For example, it may certify that the committer has the rights to submit the work under the project’s license or agrees to some contributor representation, such as a Developer Certificate of Origin. (See http://developercertificate.org for the one used by the Linux kernel and Git projects.) Consult the documentation or leadership of the project to which you’re contributing to understand how the signoffs are used in that project.
    --no-signoff                                    # The --no-signoff option can be used to countermand an earlier --signoff option on the command line.
    --trailer: string                               # Specify a (<token>, <value>) pair that should be applied as a trailer. (e.g. git commit --trailer "Signed-off-by:C O Mitter \ <committer@example.com>" --trailer "Helped-by:C O Mitter \ <committer@example.com>" will add the "Signed-off-by" trailer and the "Helped-by" trailer to the commit message.) The trailer.* configuration variables (git-interpret-trailers(1)) can be used to define if a duplicated trailer is omitted, where in the run of trailers each trailer would appear, and other details.
    --no-verify(-n)                                 # By default, the pre-commit and commit-msg hooks are run. When any of --no-verify or -n is given, these are bypassed. See also githooks(5).
    --verify
    --allow-empty                                   # Usually recording a commit that has the exact same tree as its sole parent commit is a mistake, and the command prevents you from making such a commit. This option bypasses the safety, and is primarily for use by foreign SCM interface scripts.
    --allow-empty-message                           # Like --allow-empty this command is primarily for use by foreign SCM interface scripts. It allows you to create a commit with an empty commit message without using plumbing commands like git-commit-tree(1).
    --cleanup: string
    --edit(-e)
    --no-edit
    --amend
    --no-post-rewrite
    --include(-i)
    --only(-o)
    --pathspec-from-file: string
    --pathspec-file-nul: string
    --untracked-files(-u): string
    --verbose(-v)
    --quiet(-q)
    --dry-run
    --status
    --no-status
    --gpg-sign(-S): string
    --no-gpg-sign
    --help
  ]
}

# Get just the extern definitions without the custom completion commands
use completions *

def "git remove-merged" [
  --remotes(-r)
] {
  if $remotes {
    (git branch --merged | lines | parse -r '^(.)\s(.+)$' | rename status name | where ($it.name != 'main' and $it.name != 'master' and $it.status != '*') | each {|br| git branch -D ($br.name | str trim) } | str trim)
  } else {
    (git branch --merged | lines | parse -r '^(.)\s(.+)$' | rename status name | where ($it.name != 'main' and $it.name != 'master' and $it.status != '*') | each {|br| git branch -d ($br.name | str trim) } | str trim)  
  }
}

def "git ma" [] {
  let out = (sirse cache upsert $"git-main:($env.PWD)" { || { value: (git remote show origin | split row "\n" | where {|x| $x =~ "HEAD"} | first | str trim | parse "HEAD branch: {branch}" | first | get branch), expires: 7day } });

  git checkout $out
}

def "git sta" [] {
  git stash --include-untracked
}

def "git pub" [
  --ssh # Use ssh
  repo  # Repository name in format <username>/<repo>, where <username> - valid GitHub username, <repo> - new repository name
] {
  git init
  git add -A
  git commit -m "Initial commit"
  git branch -M main
  if ($ssh) {
    git remote add origin $"git@github.com:($repo).git"  
  } else {
    git remote add origin $"https://github.com/($repo).git"
  }
  git push -u origin main
}

def "git rst" [] {
  git ma;
  git pull;
  git remove-merged;
}

def "git br" [
  branch # Name of new branch
] {
  git checkout -b $branch;
}

def "git yolo" [
  message # Commit message
] {
  git add -A;
  git commit -m $message;
  git push;
}

def "kill-port" [...ports] {
  let processes = []

  for $port in $ports {
    let found = (netstat -nao | find $":($port)" | ansi strip)

    let records = ($found | each { |row| $row | str trim | parse -r '^(?<proto>\w+)\s+(?<local_address>\d+\.\d+\.\d+\.\d+:\d+)\s+(?<foreign_address>\d+\.\d+\.\d+\.\d+:\d+)\s+(?<status>\w+)\s+(?<pid>\d+)$' } | filter { |row| ($row | length) > 0 and ($row | first | get pid) != "0" } | each { |row| first } | uniq-by pid);
  
    $processes | append $records
  }

  let portSpan = (metadata $ports).span;

  if ($processes | is-empty) {
    error make {
      msg: "No active processes are currently utilizing these ports. Please ensure the correct port is specified or check if the intended process is running."
      label: {
        text: "Unused port."
        start: $portSpan.start,
        end: $portSpan.end,
      }
    }
  }

  if ($processes | length) == 1 {
    let pid = ($processes | first | get pid);
    try { 
      gum confirm $"Kill process ($pid)?";
      taskkill /F /PID $pid;
    } catch {
      print "Killing process cancelled"
    }
  } else {
    let options = ($processes | each { |row| $"($row.pid | fill -a left -w 5) (ansi grey)\(($row.proto) ($row.local_address)\)(ansi reset)" });
    let pickedOptions = (gum choose --no-limit --header "Multiple processes using port(-s) found. Pick some (space) or all (a) processes to kill and press enter" $options)

    let pickedRows = ($pickedOptions | ansi strip | str trim | split row "\n" | filter { |row| not ($row | str trim | is-empty) });

    if ($pickedRows | is-empty) {
      print "Killing process cancelled"
    } else {
      $pickedRows | each { |row| 
        let $pid = ($row | parse -r '^(?<pid>\d+)\s' | first | get pid); 
        taskkill /F /PID $pid;
      }
    }
  }
}

def "pnpm lsu" [dependency] {
  let found = (pnpm ls --depth Infinity -r $dependency | find $dependency);

  let versions = (($found | each { |row| $row | ansi strip | str trim | parse -r $'\s($dependency)\s('(\d+\.\d+\.\d+)')' } | filter { |row| not ($row | is-empty) }) | each { |row| $row | first } | uniq);

  let readable = ($versions | rename version);

  echo $readable;
}

alias builtin-cd = cd
alias builtin-cat = cat

source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu

def cat [...args] {
  if (which bat | is-not-empty) {
    bat ...$args
  } else {
    builtin-cat ...$args
  }
}

def cd --env [directory] {
  if (which zoxide | is-not-empty) {
    z $directory
  } else {
    builtin-cd $directory
  }
}

if (which fnm | is-not-empty) {
  let variables = fnm env --corepack-enabled --shell bash | lines | str replace "export " "" | str replace -a '"' '' | split column '=' | rename name value;

  load-env ($variables | where name != "PATH" | reduce -f {} {|it, acc| $acc | upsert $it.name $it.value });

  let fnmPath = $variables | where name == "PATH" | first | get value | str replace ":$PATH" "";

  $env.PATH = ($env.PATH | split row (char esep) | prepend $fnmPath)
}

alias modulekill = rm -rf node_modules and rm -rf **/node_modules
alias docker = wsl docker
alias lzd = wsl /home/linuxbrew/.linuxbrew/bin/lazydocker
alias minikube = wsl minikube

def "start-emulator" [] {
  let options = (emulator -list-avds | split row "\r\n" | filter { |row| not ($row | str trim | is-empty) and $row !~ '^INFO\s+\|' });

  let picked = match ($options | length) {
    0 => {
      error make -u {
        msg: "No available emulators found."
      }
    },
    1 => ($options | first),
    _ => (gum choose ...$options)
  }

  if ($picked | is-empty) {
    error make -u {
      msg: "Emulator not selected."
    }
  } else {
    emulator -avd $picked;
  }
}

$env.config = ($env.config | upsert show_banner false)
