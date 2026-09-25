#!/usr/bin/env bash
# Compare each feature's source against the bytes already published under its
# declared version, and refuse to let them silently differ.
#
# WHY THIS EXISTS
#
# `devcontainer features publish` skips any version tag that already exists in
# the target namespace. Under the staged release that namespace is STAGING, and
# staging persists between runs, so two things follow that this repository had
# no check for:
#
#   1. A source change without a version bump is dropped on the floor. Staging
#      still holds the old bytes under that version, publish says "already
#      exists, skipping", review inspects the old bytes, and promotion ships
#      them again. The release log reports success.
#
#   2. The first run against an EMPTY staging namespace republishes everything,
#      including features whose source has not changed. The feature tarball is
#      not byte-reproducible, so identical source produces a new digest -- and
#      because every dependent pins bootstrap BY DIGEST, a re-minted bootstrap
#      re-pins all of them. Consumers that pin features by digest then hold a
#      mix of two bootstraps and install both. This happened on 2026-09-10.
#
# Both are the same question asked at different times: is the source tree the
# same bytes as what is published under this version?
#
#   --check   (pr-gate, make check)  production has :<version> and it differs
#                                    from src/<feature>  ->  error, bump the version
#   --seed    (release, stage jobs)  production has :<version> and it is
#                                    identical  ->  copy those exact bytes into
#                                    staging so publish skips them and the
#                                    digest cannot change; it differs -> error
#
# Ported from trusted-devcontainer-features. The repo-local features under
# features/src publish to their own namespace, PROD_NAMESPACE.
#
# THE COMPARISON NORMALISES ONE THING
#
# Source declares sibling installsAfter references as "./<id>"; published bytes
# carry the production reference (rewrite-feature-refs.sh). The --check copy is
# rewritten the same way, so the only differences that remain are real edits.
# dependsOn is already absolute and pinned in source, so it needs nothing.
#
# In --seed mode the trees under BASE_DIR have already been rewritten, so they
# are compared as they are.
#
# Required env (--seed): FEATURES (JSON list) STAGING_NAMESPACE BASE_DIR, and a
#                        docker login that can push to staging (crane reads
#                        it). DRY_RUN=1 reports the copies it would make and
#                        pushes nothing.
# Optional env:          PROD_NAMESPACE (default
#                        infrashift/trusted-devcontainer-templates/features)
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1

MODE="${1:---check}"
case "$MODE" in --check|--seed) ;; *) echo "usage: $0 [--check|--seed]" >&2; exit 2 ;; esac

REGISTRY="${REGISTRY:-ghcr.io}"
PROD_NAMESPACE="${PROD_NAMESPACE:-infrashift/trusted-devcontainer-templates/features}"
PROD_NS="${PROD_NAMESPACE,,}"
PROD="${REGISTRY}/${PROD_NS}"

fetch() { curl -sSfL --retry 3 --retry-delay 2 --retry-connrefused --max-time 30 "$@"; }

# Production is public, so an anonymous pull token is enough to read it. The
# token is scoped to one repository and expires in minutes.
pull_token() {
    fetch "https://${REGISTRY}/token?scope=repository:${PROD_NS}/$1:pull&service=${REGISTRY}" | jq -r .token
}

# Prints the manifest digest of <feature>:<tag>, or nothing if the tag is absent.
prod_digest() {
    local feature="$1" tag="$2" token
    # A feature that has never been published has no repository, and GHCR
    # refuses a pull token for it with a 403. That is the first-publish case,
    # not an error: report no digest and let the caller call it new.
    token=$(pull_token "$feature" 2>/dev/null) || return 0
    curl -sSIL --retry 3 --retry-delay 2 --max-time 30 \
        -H "Authorization: Bearer ${token}" \
        -H "Accept: application/vnd.oci.image.manifest.v1+json" \
        "https://${REGISTRY}/v2/${PROD_NS}/${feature}/manifests/${tag}" 2>/dev/null \
      | tr -d '\r' | awk 'tolower($1)=="docker-content-digest:" {print $2}' | tail -1
}

# Prints every production tag of <feature> that currently resolves to <digest>.
# Signature tags (sha256-*.sig) are cosign's and are never copied.
prod_tags_of() {
    local feature="$1" digest="$2" token t
    token=$(pull_token "$feature")
    fetch -H "Authorization: Bearer ${token}" "https://${REGISTRY}/v2/${PROD_NS}/${feature}/tags/list" \
      | jq -r '.tags[]' | grep -v '^sha256-' | while read -r t; do
            [ "$(prod_digest "$feature" "$t")" = "$digest" ] && echo "$t"
        done
}

# Extracts the published feature tarball for <feature>@<digest> into <dir>.
extract_published() {
    local feature="$1" digest="$2" dir="$3" token manifest layer
    token=$(pull_token "$feature")
    manifest=$(fetch -H "Authorization: Bearer ${token}" \
        -H "Accept: application/vnd.oci.image.manifest.v1+json" \
        "https://${REGISTRY}/v2/${PROD_NS}/${feature}/manifests/${digest}")
    layer=$(jq -r '.layers[0].digest' <<<"$manifest")
    [[ "$layer" =~ ^sha256:[0-9a-f]{64}$ ]] || { echo "::error::${feature}@${digest}: no layer" >&2; return 1; }
    mkdir -p "$dir"
    fetch -H "Authorization: Bearer ${token}" \
        "https://${REGISTRY}/v2/${PROD_NS}/${feature}/blobs/${layer}" | tar -x -C "$dir"
}

feature_version() {
    python3 - "$1" <<'PYEOF'
import json, re, sys
raw = open(sys.argv[1]).read()
print(json.loads(re.sub(r"(?m)^\s*//.*$", "", raw)).get("version", ""))
PYEOF
}

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

fail=0
checked=0
seeded=0
new=0

# The set of features to look at, and where their to-be-published tree lives.
if [ "$MODE" = "--seed" ]; then
    : "${FEATURES:?}" "${STAGING_NAMESPACE:?}" "${BASE_DIR:?}"
    [ "${DRY_RUN:-0}" = "1" ] || command -v crane >/dev/null \
        || { echo "::error::crane is required for --seed" >&2; exit 1; }
    STAGING="${REGISTRY}/${STAGING_NAMESPACE,,}"
    mapfile -t NAMES < <(jq -r '.[]' <<<"$FEATURES")
else
    mapfile -t NAMES < <(find features/src -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
    BASE_DIR=features/src
fi

for feature in "${NAMES[@]}"; do
    [[ "$feature" =~ ^[a-z0-9][a-z0-9-]{0,63}$ ]] || { echo "::error::refusing feature name ${feature@Q}" >&2; exit 1; }
    tree="${BASE_DIR}/${feature}"
    [ -d "$tree" ] || { echo "::error::${tree} does not exist" >&2; fail=1; continue; }
    version=$(feature_version "${tree}/devcontainer-feature.json")
    [ -n "$version" ] || { echo "::error::${feature}: no version declared" >&2; fail=1; continue; }

    digest=$(prod_digest "$feature" "$version")
    if [ -z "$digest" ]; then
        printf '  %-14s %-8s new: not yet published\n' "$feature" "$version"
        new=$((new + 1))
        continue
    fi
    checked=$((checked + 1))

    published="${WORK}/${feature}/published"
    extract_published "$feature" "$digest" "$published"

    # A comparable copy of the source. In --check mode the source still says
    # "./<id>" in installsAfter, so rewrite it the way the release does.
    candidate="${WORK}/${feature}/candidate"
    mkdir -p "$candidate"
    cp -r "${tree}/." "$candidate/"
    # Comment lines are left alone, exactly as rewrite-feature-refs.sh leaves
    # them: neovim's header mentions "./bootstrap" in prose, and rewriting it
    # here but not at release made identical bytes look like drift.
    if [ "$MODE" = "--check" ]; then
        sed -i -E "/^[[:space:]]*\/\//!s|\"\./([a-z0-9-]+)\"|\"${PROD}/\1\"|g" "${candidate}/devcontainer-feature.json"
    fi

    if diff -r "$candidate" "$published" > "${WORK}/${feature}.diff" 2>&1; then
        if [ "$MODE" = "--seed" ]; then
            # Identical bytes already exist in production under this version.
            # Copy THAT digest into staging under every tag production gives it,
            # so publish sees the version and skips, review inspects production's
            # own bytes, and promotion is a no-op copy. The digest cannot move.
            mapfile -t tags < <(prod_tags_of "$feature" "$digest")
            [ "${#tags[@]}" -gt 0 ] || tags=("$version")
            for t in "${tags[@]}"; do
                if [ "${DRY_RUN:-0}" = "1" ]; then
                    echo "  would copy ${PROD}/${feature}@${digest} -> ${STAGING}/${feature}:${t}"
                else
                    crane copy "${PROD}/${feature}@${digest}" "${STAGING}/${feature}:${t}" >/dev/null
                fi
            done
            printf '  %-14s %-8s unchanged: seeded staging from %s (%s)\n' "$feature" "$version" "${digest:0:19}" "${tags[*]}"
            seeded=$((seeded + 1))
        else
            printf '  %-14s %-8s unchanged: matches published %s\n' "$feature" "$version" "${digest:0:19}"
        fi
    else
        echo "::error::${feature}: features/src/${feature} differs from the bytes published as ${version} (${digest}). Publish would skip it as already existing. Bump the version." >&2
        sed 's/^/           /' "${WORK}/${feature}.diff" | head -20 >&2
        fail=1
    fi
done

if [ "$MODE" = "--check" ]; then
    [ $((checked + new)) -gt 0 ] || { echo "::error::inspected 0 features; refusing to call that a pass" >&2; exit 1; }
fi
[ "$fail" -eq 0 ] || exit 1
echo "OK: ${checked} published version(s) match their source, ${new} new version(s) to publish${seeded:+, ${seeded} seeded into staging}"
