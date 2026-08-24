#!/usr/bin/env bash
# Pin every template's feature references to an immutable digest.
#
# USAGE
#   scripts/pin-features.sh          resolve current digests and rewrite in place
#   scripts/pin-features.sh --check  fail if any reference is not digest-pinned
#
# WHY
#
# A bare reference resolves to :latest, a mutable tag. It was the one remaining
# unpinned link in the supply chain: the base image is digest-pinned, uv and
# ansible-core are version-pinned with checksum verification, and every tool in
# tools.lock carries a sha256 -- but the features, which are the thing that
# actually installs software into a developer's container, were whatever the
# registry happened to serve that minute.
#
# --check is what pr-gate runs. Re-pinning is a deliberate act with a diff to
# review, which is the point: a feature update should be a visible change to
# this repository, not something that happens to a build.
#
# KNOWN LIMIT: this pins the references the templates declare. It does NOT pin
# the dependencies those features declare among themselves -- a feature's
# dependsOn still resolves to :latest of the sibling it names. Closing that gap
# needs the features repo to embed digests at publish time, which is ordered
# (bootstrap must exist before anything can reference its digest). Tracked as
# TODO 20. Until then the chain is pinned one level deep, and saying so is
# better than implying otherwise.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

REGISTRY="${REGISTRY:-ghcr.io}"
NAMESPACE="${NAMESPACE:-infrashift/trusted-devcontainer-features}"
BASE="${REGISTRY}/${NAMESPACE}"

CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

mapfile -t FILES < <(find src -mindepth 3 -maxdepth 3 -name devcontainer.json -path '*/.devcontainer/*' | sort)
[ "${#FILES[@]}" -gt 0 ] || { echo "::error::no template devcontainer.json found under src/" >&2; exit 1; }

# --- check mode -------------------------------------------------------------
if [ "$CHECK_ONLY" -eq 1 ]; then
    fail=0
    total=0
    for f in "${FILES[@]}"; do
        # A reference is pinned only if the feature name is followed by @sha256:.
        while IFS= read -r ref; do
            [ -n "$ref" ] || continue
            total=$((total + 1))
            if ! [[ "$ref" =~ @sha256:[0-9a-f]{64}$ ]]; then
                echo "::error::${f}: ${ref} is not digest-pinned" >&2
                fail=1
            fi
        done < <(grep -oE "\"${BASE}/[a-z0-9-]+(@sha256:[0-9a-f]+)?\"" "$f" | tr -d '"')
    done
    [ "$total" -gt 0 ] || { echo "::error::found 0 feature references; refusing to call that a pass" >&2; exit 1; }
    [ "$fail" -eq 0 ] || exit 1
    echo "OK: all ${total} feature reference(s) across ${#FILES[@]} template(s) are digest-pinned"
    exit 0
fi

# --- pin mode ---------------------------------------------------------------
# Resolve each distinct feature once, so five templates sharing a feature cannot
# end up pinned to five different digests resolved seconds apart.
mapfile -t NAMES < <(grep -hoE "${BASE}/[a-z0-9-]+" "${FILES[@]}" | sed "s|${BASE}/||" | sort -u)

declare -A DIGEST=()
for name in "${NAMES[@]}"; do
    token=$(curl -sSfL "https://ghcr.io/token?scope=repository:${NAMESPACE}/${name}:pull&service=ghcr.io" | jq -r .token)
    d=$(curl -sSI -H "Authorization: Bearer ${token}" \
          -H "Accept: application/vnd.oci.image.manifest.v1+json" \
          "https://ghcr.io/v2/${NAMESPACE}/${name}/manifests/latest" \
        | grep -i '^docker-content-digest' | tr -d '\r' | awk '{print $2}')
    if ! [[ "$d" =~ ^sha256:[0-9a-f]{64}$ ]]; then
        echo "::error::could not resolve a digest for ${name}: got ${d@Q}" >&2
        exit 1
    fi
    DIGEST["$name"]="$d"
    printf '  %-14s %s\n' "$name" "$d"
done

for f in "${FILES[@]}"; do
    for name in "${NAMES[@]}"; do
        # Match the bare ref OR an existing pin, so re-running re-pins rather
        # than appending a second digest.
        sed -i -E "s|\"${BASE}/${name}(@sha256:[0-9a-f]+)?\"|\"${BASE}/${name}@${DIGEST[$name]}\"|g" "$f"
    done
done

echo "pinned ${#NAMES[@]} distinct feature(s) across ${#FILES[@]} template(s)"

# Assert the OUTPUT, not that the loop ran.
"$0" --check
