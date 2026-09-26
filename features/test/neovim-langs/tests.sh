#!/usr/bin/env bash
# Runs INSIDE the feature test container, as the unprivileged dev user.
# Asserts what each repo-local LANGUAGE feature promises -- python-tools,
# java-tools, ansible-tools, and lazyvim with every extra they serve -- at the
# versions each one declares by default.
# shellcheck source=/dev/null disable=SC2016  # the bash -c bodies expand inside the container, on purpose
source "$(dirname "$0")/test-lib.sh"

# One Neovim session per language server: open a buffer, wait for the named
# client to attach, print how many did. $1 = file, $2 = client name, $3 = ms.
attaches() {
    local file="$1" client="$2" ms="${3:-60000}"
    timeout $((ms / 1000 + 60)) nvim --headless "$file" \
        "+lua vim.wait(${ms}, function() return #vim.lsp.get_clients({ name = \"${client}\" }) > 0 end, 200) io.stdout:write(\"\nATTACHED=\"..#vim.lsp.get_clients({ name = \"${client}\" })..\"\n\")" +qa 2>&1 \
        | grep -q "^ATTACHED=1$"
}
export -f attaches

echo "python-tools"
check "basedpyright is 1.40.1" bash -c 'basedpyright --version | grep -q "^basedpyright 1.40.1$"'
check "basedpyright-langserver is on PATH" command -v basedpyright-langserver
check "basedpyright lives in a uv tool venv under ~/.local" \
    bash -c 'readlink -f "$(command -v basedpyright)" | grep -q "^$HOME/.local/share/uv/tools/basedpyright/"'

echo "ansible-tools"
check "ansible-lint is 26.9.0" bash -c 'ansible-lint --version | grep -q "^ansible-lint 26.9.0 "'
check "ansible-lint lives in a uv tool venv under ~/.local" \
    bash -c 'readlink -f "$(command -v ansible-lint)" | grep -q "^$HOME/.local/share/uv/tools/ansible-lint/"'
check "the ansible-core feature's ansible is untouched (2.21.3)" bash -c 'ansible --version | grep -q "core 2.21.3"'
check "ansible-lint lints a playbook" bash -c '
    d=$(mktemp -d); cd "$d"
    printf -- "---\n- name: Example\n  hosts: localhost\n  tasks:\n    - name: Ping\n      ansible.builtin.ping:\n" > site.yml
    ansible-lint --offline -q site.yml'

echo "java-tools"
check "jdtls launcher is installed" test -x "$HOME/.local/bin/jdtls"
check "jdtls 1.61.0 is unpacked under ~/.local/share/jdtls" \
    bash -c 'ls "$HOME"/.local/share/jdtls/1.61.0/plugins/org.eclipse.equinox.launcher_*.jar'
check "lombok.jar points at lombok 1.18.48" \
    bash -c '[ "$(readlink "$HOME/.local/share/jdtls/lombok.jar")" = "$HOME/.local/share/jdtls/lombok-1.18.48.jar" ]'
check "the launcher uses the configuration for this architecture" \
    bash -c 'case "$(uname -m)" in aarch64) c=config_linux_arm ;; *) c=config_linux ;; esac; grep -q "/$c\"" "$HOME/.local/bin/jdtls"'

echo "cue (the cuelang feature's language server)"
check "cue has an lsp subcommand" bash -c 'cue help lsp > /dev/null 2>&1'

echo "lazyvim extras"
check "extras.lua names every extra this template asked for" bash -c '
    f="$HOME/.config/nvim/lua/config/extras.lua"
    for m in lazyvim.plugins.extras.lang.python lazyvim.plugins.extras.lang.java infrashift.extras.java infrashift.extras.cue infrashift.extras.ansible_lint; do
        grep -q "import = \"$m\"" "$f" || { echo "missing $m"; exit 1; }
    done
    ! grep -q "lang.go" "$f"'
check "every plugin the spec names is at its locked commit" bash -c '
    lock="$HOME/.config/nvim/lazy-lock.json"
    spec=$(nvim --headless "+lua local n={} for _,p in ipairs(require(\"lazy\").plugins()) do n[#n+1]=p.name end io.stdout:write(\"\nSPEC=\"..table.concat(n,\" \")..\"\n\")" +qa 2>&1 | sed -n "s/^SPEC=//p")
    n=0
    for name in $spec; do
        commit=$(sed -nE "s/^ *\"${name//./\\.}\": \{.*\"commit\": \"([0-9a-f]{40})\".*/\1/p" "$lock")
        [ -n "$commit" ] || { echo "$name is not in the lockfile"; exit 1; }
        [ "$(git -C "$HOME/.local/share/nvim/lazy/$name" rev-parse HEAD)" = "$commit" ] || { echo "$name"; exit 1; }
        n=$((n + 1))
    done
    echo "checked $n"; [ "$n" -ge 30 ]'
check "the java and python extras brought their plugins" \
    bash -c 'test -d "$HOME/.local/share/nvim/lazy/nvim-jdtls" && test -d "$HOME/.local/share/nvim/lazy/venv-selector.nvim"'
check "the Go extra did not (it was not asked for)" \
    bash -c '! grep -rqs "lazyvim.plugins.extras.lang.go" "$HOME/.config/nvim/lua/config/extras.lua"'
check "lazy.nvim reports nothing to install" bash -c '
    out=$(nvim --headless "+lua local m={} for _,p in ipairs(require(\"lazy\").plugins()) do if not p._.installed then m[#m+1]=p.name end end io.stdout:write(\"\nMISSING=\"..#m..\"\n\")" +qa 2>&1)
    grep -q "^MISSING=0$" <<<"$out"'
for p in python java cue yaml; do
    check "the $p tree-sitter parser is installed" bash -c "ls \"\$HOME\"/.local/share/nvim/site/parser/$p.so"
done
check "LazyVim has no tree-sitter parser left to download" bash -c '
    out=$(nvim --headless "+lua LazyVim.treesitter.get_installed(true) local m = vim.tbl_filter(function(l) return not LazyVim.treesitter.have(l) end, LazyVim.opts(\"nvim-treesitter\").ensure_installed or {}) io.stdout:write(\"\nTS_MISSING=\"..table.concat(m, \",\")..\"|\"..#m..\"\n\")" +qa 2>&1)
    grep -qE "^TS_MISSING=\|0$" <<<"$out" || { grep TS_MISSING <<<"$out"; exit 1; }'
check "Mason has installed nothing" bash -c '! ls "$HOME"/.local/share/nvim/mason/packages/* > /dev/null 2>&1'
check "the python extra is set to basedpyright" bash -c '
    out=$(nvim --headless "+lua io.stdout:write(\"\nPYLSP=\"..tostring(vim.g.lazyvim_python_lsp)..\"\n\")" +qa 2>&1)
    grep -q "^PYLSP=basedpyright$" <<<"$out"'
check "an ansible task file gets filetype yaml.ansible and the ansible_lint linter" bash -c '
    d=$(mktemp -d); mkdir -p "$d/roles/r/tasks"; f="$d/roles/r/tasks/main.yml"; printf -- "---\n- name: x\n  ansible.builtin.ping:\n" > "$f"
    out=$(nvim --headless "$f" "+lua io.stdout:write(\"\nFT=\"..vim.bo.filetype..\" LINT=\"..table.concat(require(\"lint\").linters_by_ft[\"yaml.ansible\"] or {}, \",\")..\"\n\")" +qa 2>&1)
    grep -q "^FT=yaml.ansible LINT=ansible_lint$" <<<"$out" || { grep "^FT=" <<<"$out"; exit 1; }'

# The real proof the editor works for each language: open a buffer and wait
# for the server -- found on PATH, never through Mason -- to attach.
echo "language servers attach"
check "basedpyright attaches to a Python buffer" bash -c '
    d=$(mktemp -d); cd "$d"; printf "def f() -> int:\n    return 1\n" > m.py
    attaches m.py basedpyright'
check "ruff attaches to a Python buffer" bash -c '
    d=$(mktemp -d); cd "$d"; printf "import os\n" > m.py
    attaches m.py ruff'
check "cue lsp attaches to a CUE buffer" bash -c '
    d=$(mktemp -d); cd "$d"; mkdir -p cue.mod; printf "module: \"example.com/t@v0\"\nlanguage: version: \"v0.17.0\"\n" > cue.mod/module.cue
    printf "package t\n\nx: 1\n" > t.cue
    attaches t.cue cue'
check "jdtls attaches to a Java buffer" bash -c '
    d=$(mktemp -d); cd "$d"; mkdir -p src/main/java/t
    printf "<project><modelVersion>4.0.0</modelVersion><groupId>t</groupId><artifactId>t</artifactId><version>1</version></project>\n" > pom.xml
    printf "package t;\npublic class A {}\n" > src/main/java/t/A.java
    attaches src/main/java/t/A.java jdtls 180000'

echo "sshd (from trusted-devcontainer-features, alongside the login hook)"
check "rootless sshd config loads" /usr/sbin/sshd -t -f "$HOME/.ssh/sshd/sshd_config"

report_results
