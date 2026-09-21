# ~/.config/fish/conf.d/dev.fish
#
# Worktrees + Zellij, for working several tickets at once.
# Everything is local. The only command that contacts Bitbucket is
# `git fetch`, which downloads and changes nothing. Nothing here pushes,
# deletes remote branches, or creates pull requests.
#
#   wt  bugfix/ON-1234-fix-email     create worktree, open in VS Code
#   zt  ON-1234                      open a Zellij session for it
#   tk  bugfix/ON-1234-fix-email     both at once
#   wts                              list worktrees + ports + sessions
#   wtrm ON-1234                     delete the local folder
#
# Each ticket gets its own port, always the same one, so you can run
# several dev servers side by side without them fighting.

set -q WORKTREE_ROOT; or set -gx WORKTREE_ROOT $HOME/worktrees

# ── helpers ─────────────────────────────────────────────────────────────

# "bugfix/ON-1234-fix-email-issues" → "ON-1234"
function __wt_id --argument-names branch
    set -l id (string match -r '[A-Za-z]+-[0-9]+' -- $branch)
    test -n "$id"; and echo $id; and return 0
    string split / -- $branch | tail -1
end

# Always the same port for the same ticket, in the 5170-5199 range.
function __wt_port --argument-names id
    set -l sum (echo -n (string lower $id) | cksum | string split ' ')[1]
    math 5170 + $sum % 30
end

# ── wt: make the worktree ───────────────────────────────────────────────

function wt -d "Create a worktree for a branch and open it in VS Code"
    set -l branch $argv[1]
    if test -z "$branch"
        echo "usage: wt bugfix/ON-1234-fix-email-issues"
        return 1
    end

    set -l repo (git rev-parse --show-toplevel 2>/dev/null)
    if test -z "$repo"
        echo "wt: run this from inside your project folder"
        return 1
    end

    set -l id (__wt_id $branch)
    set -l dir $WORKTREE_ROOT/$id
    set -l port (__wt_port $id)

    if not test -d $dir
        echo "→ fetching (read-only)"
        git -C $repo fetch --quiet origin

        echo "→ creating $dir on $branch"
        if git -C $repo show-ref --verify --quiet refs/remotes/origin/$branch
            git -C $repo worktree add --track -b $branch $dir origin/$branch
        else
            git -C $repo worktree add $dir $branch
        end

        if test $status -ne 0
            echo
            echo "That failed. Usual cause: your main project folder is"
            echo "sitting on that branch, and git only allows a branch to be"
            echo "checked out in one place at a time. Park it first:"
            echo "    git -C $repo switch master"
            return 1
        end

        for f in .env .env.local .env.development.local .npmrc .nvmrc
            test -f $repo/$f; and cp $repo/$f $dir/$f
        end

        if test -f $dir/package.json
            echo "→ installing dependencies"
            pushd $dir >/dev/null
            npm install; or echo "⚠  install failed, sort it out in the folder"
            popd >/dev/null
        end
    end

    set -gx DEV_PORT $port
    echo
    echo "  $dir"
    echo "  port $port  →  npm run dev -- --port $port"
    echo

    type -q code; and code $dir
end

# ── zt: open a Zellij session for a worktree ────────────────────────────

function zt -d "Open a Zellij session for a worktree"
    set -l id (__wt_id $argv[1])
    set -l dir $WORKTREE_ROOT/$id

    if not test -d $dir
        echo "zt: no worktree at $dir"
        return 1
    end

    set -gx DEV_PORT (__wt_port $id)

    if zellij list-sessions 2>/dev/null | string match -q "*$id*"
        zellij attach $id
        return
    end

    # Start the session detached, populate it, then attach.
    zellij -s $id --create-background
    sleep 1

    zellij -s $id action new-tab --name claude --cwd $dir
    zellij -s $id action new-tab --name dev --cwd $dir
    zellij -s $id action new-tab --name git --cwd $dir

    zellij attach $id
end

# ── tk: both at once ────────────────────────────────────────────────────

function tk -d "Create a worktree and open its Zellij session"
    wt $argv[1]; or return 1
    zt (__wt_id $argv[1])
end

# ── listing and cleanup ─────────────────────────────────────────────────

function wts -d "List worktrees, their ports, and running sessions"
    set -l repo (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$repo"
        echo "worktrees:"
        for line in (git -C $repo worktree list)
            set -l path (string split ' ' -- $line)[1]
            set -l id (basename $path)
            printf "  %-40s :%s\n" $line (__wt_port $id)
        end
        echo
    end
    echo "zellij sessions:"
    zellij list-sessions 2>/dev/null; or echo "  none"
end

function wtrm -d "Delete a worktree folder (local only)"
    set -l id (__wt_id $argv[1])
    if test -z "$id"
        echo "usage: wtrm ON-1234"
        return 1
    end

    set -l repo (git rev-parse --show-toplevel 2>/dev/null); or return 1
    set -l dir $WORKTREE_ROOT/$id

    read -l -P "Delete folder $dir? The Bitbucket branch is untouched. [y/N] " ok
    test "$ok" = y; or return 0

    zellij kill-session $id 2>/dev/null
    zellij delete-session $id 2>/dev/null

    git -C $repo worktree remove $dir
    or begin
        read -l -P "It has uncommitted changes. Delete anyway? [y/N] " force
        test "$force" = y; and git -C $repo worktree remove --force $dir
    end
    rm -f /tmp/zellij-$id.kdl
end

# ── general ─────────────────────────────────────────────────────────────

function zj -d "Attach to a Zellij session, or create it"
    set -l name (test -n "$argv[1]"; and echo $argv[1]; or echo work)
    if zellij list-sessions 2>/dev/null | string match -q "*$name*"
        zellij attach $name
    else
        zellij -s $name
    end
end

function killport -d "Kill whatever is using a port"
    set -l pid (lsof -ti :$argv[1] 2>/dev/null)
    if test -n "$pid"
        kill -9 $pid
        echo "killed $pid on :$argv[1]"
    else
        echo "nothing on :$argv[1]"
    end
end

# mono shortcut - 'mono' from anywhere
function mono -d "Open the MonoShare workspace"
    if zellij list-sessions 2>/dev/null | string match -q "*mono*"
        zellij attach mono
    else
        zellij -s mono --layout mono
    end
end
