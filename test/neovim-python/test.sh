#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

# One Neovim session per language server: open a buffer, wait for the named
# client to attach, print how many did. $1 = file, $2 = client name, $3 = ms.
attaches() {
    local file="$1" client="$2" ms="${3:-60000}"
    timeout $((ms / 1000 + 60)) nvim --headless "$file" \
        "+lua vim.wait(${ms}, function() return #vim.lsp.get_clients({ name = \"${client}\" }) > 0 end, 200) io.stdout:write(\"\nATTACHED=\"..#vim.lsp.get_clients({ name = \"${client}\" })..\"\n\")" +qa 2>&1 \
        | grep -q "^ATTACHED=1$"
}
export -f attaches

# The editor and the terminal layout.
check "make is installed" command -v make
check "nvim is installed" command -v nvim
check "tmux is installed" command -v tmux
check "dev-session is installed" test -x /usr/local/bin/dev-session
check "the login hook is installed" test -r /etc/profile.d/dev-session.sh

# Python: the python feature installs into uv's MANAGED store, not onto PATH,
# so `uv python find` is the contract (see test/python/test.sh).
check "python 3.14 is installed" uv python find 3.14
check "ruff is installed" command -v ruff

# pyrefly: a native binary, userland, in a uv tool venv -- and no Node anywhere.
check "pyrefly is 1.3.1" bash -c 'pyrefly --version | grep -q "^pyrefly 1.3.1"'
check "pyrefly lives in a uv tool venv under ~/.local" \
    bash -c 'readlink -f "$(command -v pyrefly)" | grep -q "^$HOME/.local/share/uv/tools/pyrefly/"'
check "there is no node binary in the image's userland" bash -c '! find "$HOME/.local" -name node -type f 2>/dev/null | grep -q .'
check "there is no npm package tree in the image's userland" bash -c '! find "$HOME/.local" -type d -path "*/node_modules/npm" 2>/dev/null | grep -q .'

# LazyVim, with the extras this template asks for.
check "extras.lua names exactly the extras this template asks for" bash -c '
    f="$HOME/.config/nvim/lua/config/extras.lua"
    for m in lazyvim.plugins.extras.lang.python; do
        grep -q "import = \"$m\"" "$f" || exit 1
    done
    ! grep "import = " "$f" | grep -qE "lang\.go|lang\.java|infrashift\.extras"'
check "the python tree-sitter parser is installed" bash -c 'ls "$HOME"/.local/share/nvim/site/parser/python.so'
check "the python extra is set to pyrefly" bash -c '
    out=$(nvim --headless "+lua io.stdout:write(\"\nPYLSP=\"..tostring(vim.g.lazyvim_python_lsp)..\"\n\")" +qa 2>&1)
    grep -q "^PYLSP=pyrefly$" <<<"$out"'
check "Mason has installed nothing" bash -c '! ls "$HOME"/.local/share/nvim/mason/packages/* > /dev/null 2>&1'

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

# The real proof the editor works: open a buffer and wait for the server --
# found on PATH, never through Mason -- to attach.
check "pyrefly attaches to a Python buffer" bash -c '
    d=$(mktemp -d); cd "$d"; printf "def f() -> int:\n    return 1\n" > m.py
    attaches m.py pyrefly'
check "ruff attaches to a Python buffer" bash -c '
    d=$(mktemp -d); cd "$d"; printf "import os\n" > m.py
    attaches m.py ruff'

# sshd from trusted-devcontainer-features, started by its entrypoint.
check "the rootless sshd config loads" /usr/sbin/sshd -t -f "$HOME/.ssh/sshd/sshd_config"

reportResults
