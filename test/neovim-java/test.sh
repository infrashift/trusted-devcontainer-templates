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

check "java is installed" command -v java
check "javac is installed" command -v javac
check "mvn is installed" command -v mvn
check "mvn runs against the JDK" mvn --version
check "gradle is installed" command -v gradle
check "gradle runs against the JDK" gradle --version

# java-tools: jdtls + lombok, userland, and a launcher that needs no Python.
check "jdtls launcher is installed" test -x "$HOME/.local/bin/jdtls"
check "jdtls 1.61.0 is unpacked under ~/.local/share/jdtls" \
    bash -c 'ls "$HOME"/.local/share/jdtls/1.61.0/plugins/org.eclipse.equinox.launcher_*.jar'
check "lombok.jar points at lombok 1.18.48" \
    bash -c '[ "$(readlink "$HOME/.local/share/jdtls/lombok.jar")" = "$HOME/.local/share/jdtls/lombok-1.18.48.jar" ]'
check "the launcher uses the configuration for this architecture" \
    bash -c 'case "$(uname -m)" in aarch64) c=config_linux_arm ;; *) c=config_linux ;; esac; grep -q "/$c\"" "$HOME/.local/bin/jdtls"'

# LazyVim, with the extras this template asks for.
check "extras.lua names exactly the extras this template asks for" bash -c '
    f="$HOME/.config/nvim/lua/config/extras.lua"
    for m in lazyvim.plugins.extras.lang.java infrashift.extras.java; do
        grep -q "import = \"$m\"" "$f" || exit 1
    done
    ! grep "import = " "$f" | grep -qE "lang\.go|lang\.python"'
check "the java tree-sitter parser is installed" bash -c 'ls "$HOME"/.local/share/nvim/site/parser/java.so'
check "the java extra brought nvim-jdtls" test -d "$HOME/.local/share/nvim/lazy/nvim-jdtls"
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
# found on PATH, never through Mason -- to attach. jdtls starts slowly.
check "jdtls attaches to a Java buffer" bash -c '
    d=$(mktemp -d); cd "$d"; mkdir -p src/main/java/t
    printf "<project><modelVersion>4.0.0</modelVersion><groupId>t</groupId><artifactId>t</artifactId><version>1</version></project>\n" > pom.xml
    printf "package t;\npublic class A {}\n" > src/main/java/t/A.java
    attaches src/main/java/t/A.java jdtls 180000'

# sshd from trusted-devcontainer-features, started by its entrypoint.
check "the rootless sshd config loads" /usr/sbin/sshd -t -f "$HOME/.ssh/sshd/sshd_config"

reportResults
