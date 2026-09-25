#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# features/test/shared/contract-tests.sh
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Usage: contract-tests.sh <template> [container-label]
#
# Ported from trusted-devcontainer-features. Tests the parts of the role
# contract that tests.sh cannot: that re-running a role changes nothing, and
# that a missing, empty, or wrong parameter fails loudly and by name.
#
# This runs on the HOST, not inside the container, because it needs root:
# /opt/bootstrap/run-feature.sh chowns and calls setpriv. `devcontainer exec`
# resolves to the unprivileged `dev` user and offers no --user flag, so the only
# route is `docker exec -u 0` against the container found by its id-label.
#
set -uo pipefail

TEMPLATE="${1:?usage: contract-tests.sh <template> [container-label]}"
LABEL="${2:-$TEMPLATE}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${HERE}/test-lib.sh"

CID="$(docker ps -q --filter "label=test=${LABEL}" | head -1)"
if [ -z "${CID}" ]; then
    echo "ERROR: no running container labelled test=${LABEL}." >&2
    echo "Run: make test-feature-template" >&2
    exit 1
fi

# The CLI bind-mounts the git root at /workspaces/<clone directory name>, which
# is how the roles are reachable at all. The clone directory differs between a
# workstation and Actions, so derive it, then fall back to discovery.
REPO_IN_CTR="/workspaces/$(basename "$(git -C "${HERE}" rev-parse --show-toplevel)")"
if ! docker exec "${CID}" test -d "${REPO_IN_CTR}/features/src"; then
    REPO_IN_CTR="$(docker exec "${CID}" sh -c \
        'for d in /workspaces/*/; do
             if [ -d "${d}features/src" ] && [ -d "${d}features/test" ]; then printf "%s" "${d%/}"; break; fi
         done')"
fi
if [ -z "${REPO_IN_CTR}" ] || ! docker exec "${CID}" test -d "${REPO_IN_CTR}/features/src"; then
    echo "ERROR: could not find this repository's mount inside the container." >&2
    echo "Looked for a /workspaces/* directory containing features/src and features/test." >&2
    docker exec "${CID}" ls -la /workspaces/ >&2 || true
    exit 1
fi
echo "contract tests using ${REPO_IN_CTR}"

# The target account comes from the template, not from a constant.
TMPL_CONF="${HERE}/../${TEMPLATE}/.devcontainer/devcontainer.json"
TARGET_USER="$(grep -oE '"containerUser"[[:space:]]*:[[:space:]]*"[^"]+"' "$TMPL_CONF" \
                 | sed -E 's/.*:[[:space:]]*"([^"]+)"/\1/' | head -1)"
TARGET_USER="${TARGET_USER:-dev}"
TARGET_HOME="$(docker exec "${CID}" bash -lc "getent passwd ${TARGET_USER} | cut -d: -f6" 2>/dev/null | tr -d '\r')"
TARGET_HOME="${TARGET_HOME:-/home/${TARGET_USER}}"
echo "target account: ${TARGET_USER} (${TARGET_HOME})"

# _REMOTE_USER/_REMOTE_USER_HOME are injected by the devcontainer CLI only during
# feature installation, never into an exec environment, so pass them explicitly.
# run-feature.sh resolves the role relative to $(pwd), hence -w. A later --role
# in "$@" overrides the default, which is how a secondary role is exercised.
run_role() {
    local feature="$1"; shift
    docker exec -u 0 -w "${REPO_IN_CTR}/features/src/${feature}" \
        -e _REMOTE_USER="${TARGET_USER}" -e _REMOTE_USER_HOME="${TARGET_HOME}" \
        "${CID}" /opt/bootstrap/run-feature.sh --role ansible-role-feature "$@"
}

run_install() {
    local feature="$1"; shift
    local envs=(); for kv in "$@"; do envs+=(-e "$kv"); done
    docker exec -u 0 -w "${REPO_IN_CTR}/features/src/${feature}" \
        -e _REMOTE_USER="${TARGET_USER}" -e _REMOTE_USER_HOME="${TARGET_HOME}" \
        "${envs[@]}" "${CID}" bash ./install.sh
}

# Re-running a role must report changed=0 (ADR-012 idempotency contract).
assert_idempotent() {
    local feature="$1"; shift
    local out; out="$(run_role "$feature" "$@" 2>&1)"
    if [[ "$out" != *"changed=0"* ]]; then
        echo "${out}" | grep -E "changed:|changed=|fatal:" | tail -8
        return 1
    fi
    return 0
}

echo "Contract tests: ${TEMPLATE} [${LABEL}] (container ${CID})"
echo ""
echo "Idempotency — a second run must change nothing:"

# Role -> the runner arguments its install.sh passes, at their declared
# defaults. A two-lane feature has one entry per role, keyed <feature>:<role>.
declare -A ROLE_ARGS=(
  [neovim]='-e _nvim_version=0.12.5 -e _nvim_checksum='
  [tmux]='--privileged -e _tmux_session_name=dev -e _tmux_editor_pane_command=nvim -e _tmux_shell_pane_percent=35 -e _tmux_autostart=interactive'
  [go-tools]='-e _gopls_version=0.23.0 -e _gofumpt_version=0.12.0 -e _goimports_version=0.50.0 -e _gomodifytags_version=1.17.0 -e _impl_version=1.5.0 -e _delve_version=1.27.2 -e _golangci_lint_version=2.14.0 -e _golangci_lint_checksum='
  [lazyvim:system]='--role ansible-role-system --privileged'
  [lazyvim]='-e _tree_sitter_version=0.27.0 -e _tree_sitter_checksum= -e _stylua_version=2.5.2 -e _stylua_checksum= -e _shfmt_version=3.14.1 -e _shfmt_checksum='
)

# Only the repo-local features this template installs.
mapfile -t FEATURES < <(grep -oE '"\./[a-z0-9-]+"' "$TMPL_CONF" | tr -d '"' | sed 's|^\./||' | sort -u)
[ "${#FEATURES[@]}" -gt 0 ] || { echo "ERROR: ${TMPL_CONF} installs no ./ features" >&2; exit 1; }

for f in "${FEATURES[@]}"; do
    found=0
    for key in "$f" "$f:system"; do
        [[ -v ROLE_ARGS[$key] ]] || continue
        found=1
        # shellcheck disable=SC2086
        check "idempotent: ${key}" assert_idempotent "$f" ${ROLE_ARGS[$key]}
    done
    # An unrecorded feature is a FAILURE here, not a skip: every feature in
    # this collection is ours, so there is no excuse for leaving one untested.
    [ "$found" -eq 1 ] || check "idempotent: ${f} (no ROLE_ARGS entry recorded)" false
done

echo ""
echo "Failure modes — each must fail by name, before any work:"

has() { [[ " ${FEATURES[*]} " == *" $1 "* ]]; }

if has neovim; then
    check_fails "neovim: missing -e is named" "_nvim_checksum is defined" \
        run_role neovim -e _nvim_version=0.12.5
    check_fails "neovim: empty mandatory option stops in the shell" "resolved empty" \
        run_install neovim TARGET_VERSION= TARGET_CHECKSUM=
    check_fails "neovim: unpinned version refuses to download unverified" "No SHA256 is pinned" \
        run_role neovim -e _nvim_version=0.11.4 -e _nvim_checksum=
    check_fails "neovim: malformed checksum is rejected by shape" "must be a 64-character SHA256" \
        run_role neovim -e _nvim_version=0.12.5 -e _nvim_checksum=deadbeef
    check_fails "neovim: malformed version is rejected by shape" "must look like X.Y.Z" \
        run_role neovim -e _nvim_version=v0.12.5 -e _nvim_checksum=
fi

if has tmux; then
    check_fails "tmux: unknown autostart mode is rejected" "interactive | ssh | never" \
        run_role tmux --privileged -e _tmux_session_name=dev -e _tmux_editor_pane_command=nvim \
            -e _tmux_shell_pane_percent=35 -e _tmux_autostart=always
    check_fails "tmux: a session name tmux would misparse is rejected" "letters, digits, '_' and '-'" \
        run_role tmux --privileged -e _tmux_session_name=dev.1 -e _tmux_editor_pane_command=nvim \
            -e _tmux_shell_pane_percent=35 -e _tmux_autostart=interactive
    check_fails "tmux: shell metacharacters in the pane command are rejected" "may contain only letters" \
        run_role tmux --privileged -e _tmux_session_name=dev -e '_tmux_editor_pane_command=nvim;id' \
            -e _tmux_shell_pane_percent=35 -e _tmux_autostart=interactive
    check_fails "tmux: pane width out of range is rejected" "between 10 and 90" \
        run_role tmux --privileged -e _tmux_session_name=dev -e _tmux_editor_pane_command=nvim \
            -e _tmux_shell_pane_percent=95 -e _tmux_autostart=interactive
    check_fails "tmux: empty mandatory option stops in the shell" "resolved empty" \
        run_install tmux SESSION_NAME= EDITOR_PANE_COMMAND=nvim SHELL_PANE_PERCENT=35 AUTOSTART=interactive
fi

if has go-tools; then
    gt_ok='-e _gofumpt_version=0.12.0 -e _goimports_version=0.50.0 -e _gomodifytags_version=1.17.0 -e _impl_version=1.5.0 -e _delve_version=1.27.2'
    # shellcheck disable=SC2086
    check_fails "go-tools: a v-prefixed version is rejected by shape" "must look like X.Y.Z" \
        run_role go-tools -e _gopls_version=v0.23.0 $gt_ok -e _golangci_lint_version=2.14.0 -e _golangci_lint_checksum=
    # shellcheck disable=SC2086
    check_fails "go-tools: unpinned golangci-lint refuses to download unverified" "No SHA256 is pinned" \
        run_role go-tools -e _gopls_version=0.23.0 $gt_ok -e _golangci_lint_version=2.13.0 -e _golangci_lint_checksum=
    # shellcheck disable=SC2086
    check_fails "go-tools: missing -e is named" "_golangci_lint_checksum is defined" \
        run_role go-tools -e _gopls_version=0.23.0 $gt_ok -e _golangci_lint_version=2.14.0
fi

if has lazyvim; then
    check_fails "lazyvim: unpinned tree-sitter refuses to download unverified" "No SHA256 is pinned" \
        run_role lazyvim -e _tree_sitter_version=0.26.5 -e _tree_sitter_checksum= \
            -e _stylua_version=2.5.2 -e _stylua_checksum= -e _shfmt_version=3.14.1 -e _shfmt_checksum=
    check_fails "lazyvim: malformed checksum is rejected by shape" "must be a 64-character SHA256" \
        run_role lazyvim -e _tree_sitter_version=0.27.0 -e _tree_sitter_checksum= \
            -e _stylua_version=2.5.2 -e _stylua_checksum=deadbeef -e _shfmt_version=3.14.1 -e _shfmt_checksum=
    check_fails "lazyvim: empty mandatory option stops in the shell" "resolved empty" \
        run_install lazyvim TREE_SITTER_VERSION= STYLUA_VERSION=2.5.2 SHFMT_VERSION=3.14.1
fi

# The runner contract itself: without the CLI-injected identity there is no safe default.
check_fails "role run outside run-feature.sh's contract is refused" "_REMOTE_USER" \
    docker exec -u 0 -w "${REPO_IN_CTR}/features/src/${FEATURES[0]}" "${CID}" \
        /opt/bootstrap/run-feature.sh --role ansible-role-feature

report_results
