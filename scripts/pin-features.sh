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


# Every ghcr.io call goes through one of these two. Both --check and pin mode
# run in CI against a registry that rate-limits and occasionally 5xxs, and a
# single dropped token request used to fail the whole gate.
#
#   --retry 3 --retry-delay 2   timeouts, 5xx and 429
#   --retry-connrefused         a refused connection, which curl does not treat
#                               as transient by default
#
# Deliberately NOT --retry-all-errors: a 404 here means the feature or digest
# genuinely is not published, which is a real finding this script should report
# promptly rather than retry three times first.
#
# --max-time bounds a SINGLE attempt, not the whole retry sequence, so the
# worst case is roughly 3 x max-time plus the delays.
registry_get() {
    curl -sSfL --retry 3 --retry-delay 2 --retry-connrefused --max-time 20 "$@"
}

# HEAD variant. -f matters as much as the retry flags do: without it curl calls
# a 503 a success, hands back a response with no docker-content-digest header,
# and the retry never fires because curl saw nothing wrong.
registry_head() {
    curl -sSfI --retry 3 --retry-delay 2 --retry-connrefused --max-time 20 "$@"
}

# Read a published feature's metadata annotation, by the digest the template pins.
# Reading the DIGEST rather than :latest matters -- the point is to compare a
# template against the exact artifact it will install, not against whatever
# upstream happens to be serving now.
feature_metadata() {
    local name="$1" digest
    digest=$(grep -hoE "${BASE}/${name}@sha256:[0-9a-f]{64}" "${FILES[@]}" | head -1 | sed 's/.*@//')
    [ -n "$digest" ] || return 1
    local token
    token=$(registry_get "https://ghcr.io/token?scope=repository:${NAMESPACE}/${name}:pull&service=ghcr.io" | jq -r .token) || return 1
    registry_get -H "Authorization: Bearer ${token}" \
        -H "Accept: application/vnd.oci.image.manifest.v1+json" \
        "https://ghcr.io/v2/${NAMESPACE}/${name}/manifests/${digest}" \
      | jq -r '.annotations["dev.containers.metadata"] // empty' || return 1
}

# feature|option|value for every explicitly passed version option in a template.
template_option_pins() {
    python3 - "$1" <<'PYEOF' 2>/dev/null || true
import json, sys
doc = json.load(open(sys.argv[1]))
for ref, opts in (doc.get("features") or {}).items():
    name = ref.split("@")[0].rsplit("/", 1)[-1]
    for k, v in (opts or {}).items():
        if "version" in k and isinstance(v, str) and v:
            print(f"{name}|{k}|{v}")
PYEOF
}

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
    # --- explicit option values vs the pinned feature's own defaults ---------
    # A template may pass an option explicitly, which makes it a SECOND copy of
    # that feature's default. The features repo has been bitten twice by exactly
    # this: a template kept requesting ansible-core 2.18.2 after the default moved
    # to 2.21.3, so the image was built with one version while everything else
    # assumed another. Divergence can be deliberate, so this WARNS rather than
    # fails -- but it says so, every time, instead of waiting for a CVE report.
    for f in "${FILES[@]}"; do
        while IFS= read -r line; do
            [ -n "$line" ] || continue
            name="${line%%|*}"; rest="${line#*|}"
            opt="${rest%%|*}"; val="${rest##*|}"
            meta=$(feature_metadata "$name") || continue
            want=$(jq -r --arg o "$opt" '.options[$o].default // empty' <<<"$meta" 2>/dev/null || true)
            if [ -n "$want" ] && [ "$want" != "$val" ]; then
                echo "::warning::$(basename "$(dirname "$(dirname "$f")")"): ${name}.${opt}=${val}, but the pinned feature declares ${want}"
            fi
        done < <(template_option_pins "$f")
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
    token=$(registry_get "https://ghcr.io/token?scope=repository:${NAMESPACE}/${name}:pull&service=ghcr.io" | jq -r .token)
    # `|| true` so that a failed fetch, or a response without the header, falls
    # through to the explicit error below. Without it `set -e` kills the script
    # on the assignment and the operator gets no message at all -- which is how
    # a registry blip used to read as a silent exit.
    d=$(registry_head -H "Authorization: Bearer ${token}" \
          -H "Accept: application/vnd.oci.image.manifest.v1+json" \
          "https://ghcr.io/v2/${NAMESPACE}/${name}/manifests/latest" \
        | grep -i '^docker-content-digest' | tr -d '\r' | awk '{print $2}' || true)
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
