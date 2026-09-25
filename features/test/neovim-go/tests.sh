#!/usr/bin/env bash
# Runs INSIDE the feature test container, as the unprivileged dev user.
# Asserts what each repo-local feature promises, at the versions each one
# declares by default.
# shellcheck source=/dev/null disable=SC2016  # the bash -c bodies expand inside the container, on purpose
source "$(dirname "$0")/test-lib.sh"

echo "neovim"
check "nvim is 0.12.5" bash -c '[ "$(nvim --version | head -1)" = "NVIM v0.12.5" ]'
check "nvim is a symlink into ~/.local/share/nvim-dist" \
    bash -c 'readlink "$HOME/.local/bin/nvim" | grep -q "/.local/share/nvim-dist/0.12.5/bin/nvim$"'
check "nvim starts headless" nvim --headless +qa

echo "tmux"
check "tmux is installed" bash -c 'tmux -V | grep -qE "^tmux [0-9]"'
check "/etc/tmux.conf is root-owned and not writable by dev" \
    bash -c '[ "$(stat -c %U /etc/tmux.conf)" = root ] && ! test -w /etc/tmux.conf'
check "dev-session is installed" test -x /usr/local/bin/dev-session
check "the login hook is installed" test -r /etc/profile.d/dev-session.sh
check "dev-session --detach builds the two-pane layout" bash -c '
    export TMUX_TMPDIR=$(mktemp -d)
    DEV_SESSION_NAME=layout-test dev-session --detach
    panes=$(tmux list-panes -t "=layout-test:" | wc -l)
    cmd=$(tmux display-message -p -t "=layout-test:.0" "#{pane_start_command}")
    tmux kill-server
    [ "$panes" -eq 2 ] && [[ "$cmd" == *nvim* ]]'
check "dev-session is idempotent (re-running attaches, does not duplicate)" bash -c '
    export TMUX_TMPDIR=$(mktemp -d)
    DEV_SESSION_NAME=idem-test dev-session --detach
    DEV_SESSION_NAME=idem-test dev-session --detach
    sessions=$(tmux list-sessions | wc -l); panes=$(tmux list-panes -t "=idem-test:" | wc -l)
    tmux kill-server
    [ "$sessions" -eq 1 ] && [ "$panes" -eq 2 ]'
# A non-interactive login shell must never be captured by the hook: that is
# what `ssh host cmd` and scripted probes look like.
check "the login hook leaves non-interactive shells alone" \
    bash -c '[ "$(bash -lc "echo plain")" = plain ]'

echo "go-tools"
for t in gopls gofumpt goimports gomodifytags impl dlv golangci-lint; do
    check "$t is on PATH" command -v "$t"
done
check "gopls is 0.23.0"   bash -c 'go version -m "$(command -v gopls)" | grep -qP "\tmod\tgolang.org/x/tools/gopls\tv0\.23\.0\t"'
check "dlv is 1.27.2"     bash -c 'go version -m "$(command -v dlv)"   | grep -qP "\tmod\tgithub.com/go-delve/delve\tv1\.27\.2\t"'
check "golangci-lint is 2.14.0" bash -c 'golangci-lint version | grep -q "has version 2.14.0 "'
check "the go install scratch directory was removed" bash -c '! test -e /tmp/go-tools-build'

echo "lazyvim"
check "tree-sitter is 0.27.0" bash -c 'tree-sitter --version | grep -qE "^tree-sitter 0\.27\.0( |$)"'
check "stylua is 2.5.2" bash -c '[ "$(stylua --version)" = "stylua 2.5.2" ]'
check "shfmt is 3.14.1" bash -c '[ "$(shfmt --version)" = "v3.14.1" ]'
# No jq in this image, so the lockfile is read with sed: lazy.nvim writes one
# plugin per line. The count guard matters -- a parse that found nothing would
# otherwise compare nothing and pass.
check "every plugin is at its locked commit" bash -c '
    lock="$HOME/.config/nvim/lazy-lock.json"
    n=0
    while read -r name commit; do
        [ "$(git -C "$HOME/.local/share/nvim/lazy/$name" rev-parse HEAD)" = "$commit" ] || { echo "$name"; exit 1; }
        n=$((n + 1))
    done < <(sed -nE "s/^ *\"([^\"]+)\": \{.*\"commit\": \"([0-9a-f]{40})\".*/\1 \2/p" "$lock")
    echo "checked $n"; [ "$n" -ge 30 ]'
check "lazy.nvim reports nothing to install" bash -c '
    out=$(nvim --headless "+lua local m={} for _,p in ipairs(require(\"lazy\").plugins()) do if not p._.installed then m[#m+1]=p.name end end io.stdout:write(\"\nMISSING=\"..#m..\"\n\")" +qa 2>&1)
    grep -q "^MISSING=0$" <<<"$out"'
check "the update checker is off" bash -c '
    out=$(nvim --headless "+lua io.stdout:write(\"\nCHECKER=\"..tostring(require(\"lazy.core.config\").options.checker.enabled)..\"\n\")" +qa 2>&1)
    grep -q "^CHECKER=false$" <<<"$out"'
check "the Go tree-sitter parser is installed" bash -c 'ls "$HOME"/.local/share/nvim/site/parser/go.so'
# The same test LazyVim runs at startup before it downloads a parser. Anything
# listed here would be fetched, unpinned, the first time the editor opens.
check "LazyVim has no tree-sitter parser left to download" bash -c '
    out=$(nvim --headless "+lua LazyVim.treesitter.get_installed(true) local m = vim.tbl_filter(function(l) return not LazyVim.treesitter.have(l) end, LazyVim.opts(\"nvim-treesitter\").ensure_installed or {}) io.stdout:write(\"\nTS_MISSING=\"..table.concat(m, \",\")..\"|\"..#m..\"\n\")" +qa 2>&1)
    grep -qE "^TS_MISSING=\|0$" <<<"$out" || { grep TS_MISSING <<<"$out"; exit 1; }'
check "Mason has installed nothing" bash -c '! ls "$HOME"/.local/share/nvim/mason/packages/* > /dev/null 2>&1'
# The real proof that the editor works for Go: open a Go file and wait for
# gopls, found on PATH rather than through Mason, to attach.
check "gopls attaches to a Go buffer" bash -c '
    d=$(mktemp -d); cd "$d"
    printf "module example.com/t\n\ngo 1.27\n" > go.mod
    printf "package main\n\nfunc main() {}\n" > main.go
    out=$(timeout 120 nvim --headless main.go \
        "+lua vim.wait(60000, function() return #vim.lsp.get_clients({ name = \"gopls\" }) > 0 end, 200) io.stdout:write(\"\nGOPLS=\"..#vim.lsp.get_clients({ name = \"gopls\" })..\"\n\")" +qa 2>&1)
    grep -q "^GOPLS=1$" <<<"$out"'

echo "sshd (from trusted-devcontainer-features, alongside the login hook)"
check "rootless sshd config loads" /usr/sbin/sshd -t -f "$HOME/.ssh/sshd/sshd_config"

report_results
