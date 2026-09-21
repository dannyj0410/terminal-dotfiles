# ~/.config/fish/config.fish

if not status is-interactive
    exit
end

# ── PATH ────────────────────────────────────────────────────────────────
fish_add_path $HOME/.local/bin # claude, win32yank, fd, bat
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/share/fnm

# ── Node ────────────────────────────────────────────────────────────────
if type -q fnm
    fnm env --use-on-cd --shell fish | source
end

# ── Prompt ──────────────────────────────────────────────────────────────
if type -q starship
    starship init fish | source
end

# ── Navigation ──────────────────────────────────────────────────────────
if type -q zoxide
    zoxide init fish | source
end

# ── Environment ─────────────────────────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS -R
set -gx BROWSER wslview # opens URLs in your Windows browser
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'

set fish_greeting # no startup banner

# ── Abbreviations (expand inline, so you see what actually ran) ─────────
abbr -a g git
abbr -a gs git status --short --branch
abbr -a ga git add
abbr -a gc git commit -v
abbr -a gca git commit -v --amend
abbr -a gco git checkout
abbr -a gsw git switch
abbr -a gd git diff
abbr -a gds git diff --staged
abbr -a gl git log --oneline --graph --decorate -20
abbr -a gp git push
abbr -a gpf git push --force-with-lease
abbr -a gpl git pull
abbr -a gwt git worktree
abbr -a gwl git worktree list
abbr -a lg lazygit

abbr -a p npm
abbr -a pi npm install
abbr -a pd npm dev
abbr -a pb npm build
abbr -a pt npm test
abbr -a ptc npm typecheck
abbr -a plint npm lint

abbr -a v nvim
abbr -a ll 'eza -la --git --icons --group-directories-first'
abbr -a lt 'eza --tree --level=2 --icons'
abbr -a c claude
abbr -a cr 'claude --resume'
abbr -a cw 'claude --worktree'
