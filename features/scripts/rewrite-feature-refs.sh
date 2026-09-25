#!/usr/bin/env bash
# Rewrite each feature's relative installsAfter references ("./neovim") to the
# production reference a consumer resolves
# ("ghcr.io/infrashift/trusted-devcontainer-templates/features/neovim").
#
# USAGE
#   BASE_DIR=/tmp/stage features/scripts/rewrite-feature-refs.sh
#
# Source keeps "./<id>" because the devcontainer CLI fetches every installsAfter
# reference while resolving a build, and a sibling that has not been published
# yet cannot be fetched -- the feature test template would not build. A
# consumer resolves "./<id>" against THEIR .devcontainer/ instead, so the
# published bytes must carry the absolute form. installsAfter only orders, so
# the reference stays bare (no digest): pinning is dependsOn's job, and
# dependsOn is already absolute and pinned in source.
#
# Runs on a staged COPY of features/src, never on the working tree.
#
# Required env: BASE_DIR
# Optional env: PROD_NAMESPACE (default infrashift/trusted-devcontainer-templates/features)
set -euo pipefail

: "${BASE_DIR:?}"
REGISTRY="${REGISTRY:-ghcr.io}"
PROD_NAMESPACE="${PROD_NAMESPACE:-infrashift/trusted-devcontainer-templates/features}"
PROD="${REGISTRY}/${PROD_NAMESPACE,,}"

[ -d "$BASE_DIR" ] || { echo "::error::${BASE_DIR} does not exist" >&2; exit 1; }
case "$(cd "$BASE_DIR" && pwd)" in
    "$(cd "$(dirname "${BASH_SOURCE[0]}")/../src" && pwd)")
        echo "::error::refusing to rewrite the working tree; point BASE_DIR at a staged copy" >&2; exit 1 ;;
esac

rewritten=0
for f in "$BASE_DIR"/*/devcontainer-feature.json; do
    [ -f "$f" ] || continue
    for ref in $(grep -oE '"\./[a-z0-9-]+"' "$f" | tr -d '"' | sed 's|^\./||' | sort -u); do
        [ -d "${BASE_DIR}/${ref}" ] || {
            echo "::error::$(basename "$(dirname "$f")"): ./${ref} is not a staged feature" >&2; exit 1; }
        sed -i -E "s|\"\./${ref}\"|\"${PROD}/${ref}\"|g" "$f"
        rewritten=$((rewritten + 1))
    done
done

# Assert the output: no relative reference may survive into staging.
if grep -lE '"\./[a-z0-9-]+"' "$BASE_DIR"/*/devcontainer-feature.json 2>/dev/null; then
    echo "::error::relative references remain after rewriting" >&2; exit 1
fi
echo "rewrote ${rewritten} relative reference(s) to ${PROD}"
