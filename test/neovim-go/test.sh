#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

# The editor and the terminal layout.
check "go is installed" command -v go
check "make is installed" command -v make
check "nvim is installed" command -v nvim
check "tmux is installed" command -v tmux
check "dev-session is installed" test -x /usr/local/bin/dev-session
check "the login hook is installed" test -r /etc/profile.d/dev-session.sh

# The Go tools gopls and LazyVim's Go extra expect on PATH.
for t in gopls gofumpt goimports gomodifytags impl dlv golangci-lint; do
    check "${t} is installed" command -v "$t"
done

# LazyVim is fully installed at build time: nothing left for lazy.nvim to
# install, and no tree-sitter parser left for LazyVim to download.
check "lazy.nvim reports nothing to install" bash -c '
    out=$(nvim --headless "+lua local m=0 for _,p in ipairs(require(\"lazy\").plugins()) do if not p._.installed then m=m+1 end end io.stdout:write(\"\nMISSING=\"..m..\"\n\")" +qa 2>&1)
    grep -q "^MISSING=0$" <<<"$out"'
check "LazyVim has no tree-sitter parser left to download" bash -c '
    out=$(nvim --headless "+lua LazyVim.treesitter.get_installed(true) local m = vim.tbl_filter(function(l) return not LazyVim.treesitter.have(l) end, LazyVim.opts(\"nvim-treesitter\").ensure_installed or {}) io.stdout:write(\"\nTS_MISSING=\"..#m..\"\n\")" +qa 2>&1)
    grep -q "^TS_MISSING=0$" <<<"$out"'

# The layout builds, on a private tmux socket so nothing real is touched.
check "dev-session builds the editor | shell layout" bash -c '
    export TMUX_TMPDIR=$(mktemp -d)
    DEV_SESSION_NAME=smoke dev-session --detach
    panes=$(tmux list-panes -t "=smoke:" | wc -l)
    tmux kill-server
    [ "$panes" -eq 2 ]'

# sshd from trusted-devcontainer-features, started by its entrypoint.
check "the rootless sshd config loads" /usr/sbin/sshd -t -f "$HOME/.ssh/sshd/sshd_config"

reportResults
