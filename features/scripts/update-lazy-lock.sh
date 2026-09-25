#!/usr/bin/env bash
# Regenerate the LazyVim plugin lockfile the 'lazyvim' feature installs from.
#
# USAGE
#   features/scripts/update-lazy-lock.sh      (or: make lazy-lock)
#
# WHY THIS EXISTS
#
# The feature installs every plugin at the commit recorded in
# ansible-role-feature/files/nvim/lazy-lock.json and asserts it did. That file
# has to come from somewhere, and this is the ONE place in the pipeline that
# resolves plugins to "whatever is newest": it runs `Lazy! sync` against the
# shipped config in a throwaway container and copies out the lockfile lazy.nvim
# writes. The result is a reviewable diff of commit hashes -- a plugin update is
# a visible change to this repository, not something that happens to a build.
#
# Bump the 'lazyvim' feature's version in the same change, or
# check-published-drift.sh will refuse it.
#
# WHAT IT RUNS AGAINST
#
# The same base image the templates build from (read from shared/Containerfile)
# and the Neovim release the 'neovim' feature pins, verified against that
# feature's own checksum -- so the plugin set is resolved by the editor version
# that will actually load it.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1

FEATURE_DIR=features/src/lazyvim/ansible-role-feature/files/nvim
NVIM_FEATURE=features/src/neovim

command -v docker > /dev/null || { echo "docker is required" >&2; exit 1; }

BASE_IMAGE=$(awk 'toupper($1)=="FROM" {print $2; exit}' shared/Containerfile)
[[ "$BASE_IMAGE" == *@sha256:* ]] || { echo "::error::shared/Containerfile FROM is not digest-pinned: ${BASE_IMAGE}" >&2; exit 1; }

# JSONC: strip // comments before parsing.
NVIM_VERSION=$(python3 - "${NVIM_FEATURE}/devcontainer-feature.json" <<'PYEOF'
import json, re, sys
doc = json.loads(re.sub(r"(?m)^\s*//.*$", "", open(sys.argv[1]).read()))
print(doc["options"]["target_version"]["default"])
PYEOF
)
NVIM_SHA=$(python3 - "${NVIM_FEATURE}/ansible-role-feature/vars/main.yml" "$NVIM_VERSION" <<'PYEOF'
import re, sys
text, version = open(sys.argv[1]).read(), sys.argv[2]
m = re.search(r'"%s":\s*\n\s*amd64:\s*"([0-9a-f]{64})"' % re.escape(version), text)
print(m.group(1) if m else "")
PYEOF
)
[ -n "$NVIM_SHA" ] || { echo "::error::no amd64 checksum pinned for neovim ${NVIM_VERSION}" >&2; exit 1; }

OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT

echo "base image: ${BASE_IMAGE}"
echo "neovim:     ${NVIM_VERSION} (sha256 ${NVIM_SHA:0:16}...)"

docker run --rm --platform linux/amd64 --user 0 \
    -e NVIM_VERSION="$NVIM_VERSION" -e NVIM_SHA="$NVIM_SHA" \
    -v "$(pwd)/${FEATURE_DIR}:/src:ro" \
    -v "${OUT}:/out" \
    "$BASE_IMAGE" bash -euo pipefail -c '
        dnf5 -y -q install --setopt=install_weak_deps=False git gcc tar gzip curl > /dev/null
        tarball=nvim-linux-x86_64.tar.gz
        curl -fsSL -o "/tmp/${tarball}" \
            "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${tarball}"
        echo "${NVIM_SHA}  /tmp/${tarball}" | sha256sum -c -
        mkdir -p /opt/nvim && tar -xzf "/tmp/${tarball}" -C /opt/nvim --strip-components=1

        export HOME=/root
        mkdir -p "$HOME/.config"
        cp -r /src "$HOME/.config/nvim"
        rm -f "$HOME/.config/nvim/lazy-lock.json"

        # lazy.nvim from its newest stable release; `Lazy! sync` then records
        # the commit it ended up on, like every other plugin.
        git clone -q --filter=blob:none --branch=stable \
            https://github.com/folke/lazy.nvim.git "$HOME/.local/share/nvim/lazy/lazy.nvim"

        /opt/nvim/bin/nvim --headless "+Lazy! sync" +qa
        test -s "$HOME/.config/nvim/lazy-lock.json"
        cp "$HOME/.config/nvim/lazy-lock.json" /out/lazy-lock.json
    '

jq -e 'type == "object" and length > 0 and all(.[]; .commit | test("^[0-9a-f]{40}$"))' \
    "${OUT}/lazy-lock.json" > /dev/null \
  || { echo "::error::lazy.nvim wrote a lockfile that is not a map of 40-hex commits" >&2; exit 1; }
jq -e 'has("lazy.nvim") and has("LazyVim")' "${OUT}/lazy-lock.json" > /dev/null \
  || { echo "::error::lockfile is missing lazy.nvim or LazyVim" >&2; exit 1; }

cp "${OUT}/lazy-lock.json" "${FEATURE_DIR}/lazy-lock.json"
echo "wrote ${FEATURE_DIR}/lazy-lock.json ($(jq length "${FEATURE_DIR}/lazy-lock.json") plugins)"
git --no-pager diff --stat -- "${FEATURE_DIR}/lazy-lock.json" || true
