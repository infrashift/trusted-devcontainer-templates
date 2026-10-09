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

check "ansible is installed" command -v ansible
check "ansible-playbook is installed" command -v ansible-playbook
# Python: the interpreter AND its executable (see test/ansible-cue/test.sh).
check "python 3.14 is installed" uv python find 3.14
check "python3.14 is on the PATH" python3.14 --version
check "cue is installed" command -v cue
check "cue has an lsp subcommand" bash -c 'cue help lsp > /dev/null 2>&1'

# ansible-tools: ansible-lint, userland, in a uv tool venv, beside (not over)
# the ansible-core feature's ansible.
check "ansible-lint is 26.9.0" bash -c 'ansible-lint --version | grep -q "^ansible-lint 26.9.0 "'
check "ansible-lint lives in a uv tool venv under ~/.local" \
    bash -c 'readlink -f "$(command -v ansible-lint)" | grep -q "^$HOME/.local/share/uv/tools/ansible-lint/"'
check "the ansible-core feature's ansible is untouched (2.21.3)" bash -c 'ansible --version | grep -q "core 2.21.3"'
check "ansible-lint lints a playbook" bash -c '
    d=$(mktemp -d); cd "$d"
    printf -- "---\n- name: Example\n  hosts: localhost\n  tasks:\n    - name: Ping\n      ansible.builtin.ping:\n" > site.yml
    ansible-lint --offline -q site.yml'

# LazyVim, with the extras this template asks for.
check "extras.lua names exactly the extras this template asks for" bash -c '
    f="$HOME/.config/nvim/lua/config/extras.lua"
    for m in infrashift.extras.cue infrashift.extras.ansible_lint; do
        grep -q "import = \"$m\"" "$f" || exit 1
    done
    ! grep "import = " "$f" | grep -qE "lang\.go|lang\.python|lang\.java"'
for p in cue yaml; do
    check "the $p tree-sitter parser is installed" bash -c "ls \"\$HOME\"/.local/share/nvim/site/parser/$p.so"
done
check "an ansible task file gets filetype yaml.ansible and the ansible_lint linter" bash -c '
    d=$(mktemp -d); mkdir -p "$d/roles/r/tasks"; f="$d/roles/r/tasks/main.yml"; printf -- "---\n- name: x\n  ansible.builtin.ping:\n" > "$f"
    out=$(nvim --headless "$f" "+lua io.stdout:write(\"\nFT=\"..vim.bo.filetype..\" LINT=\"..table.concat(require(\"lint\").linters_by_ft[\"yaml.ansible\"] or {}, \",\")..\"\n\")" +qa 2>&1)
    grep -q "^FT=yaml.ansible LINT=ansible_lint$" <<<"$out"'
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
check "cue lsp attaches to a CUE buffer" bash -c '
    d=$(mktemp -d); cd "$d"; mkdir -p cue.mod; printf "module: \"example.com/t@v0\"\nlanguage: version: \"v0.17.0\"\n" > cue.mod/module.cue
    printf "package t\n\nx: 1\n" > t.cue
    attaches t.cue cue'

# sshd from trusted-devcontainer-features, started by its entrypoint.
check "the rootless sshd config loads" /usr/sbin/sshd -t -f "$HOME/.ssh/sshd/sshd_config"

reportResults
