#!/usr/bin/env bash
# Inspect features sitting in the STAGING namespace and emit a signable verdict
# naming the exact digests that passed.
#
# Ported from trusted-devcontainer-features. The build actor publishes to a
# staging namespace, this script runs as the review actor, and only digests
# named in its verdict are promoted. A compromised build job can put anything
# in staging and still cannot get it promoted, because it cannot produce a
# verdict the release actor will accept.
#
# THE VERDICT IS A DIGEST LIST, NOT A PASS/FAIL
#
# Promotion copies by digest, so what was reviewed and what is promoted are the
# same bytes by construction.
#
# WHAT DIFFERS FROM THE ORIGINAL
#
# There, bootstrap is a sibling in the same namespace and is promoted first, so
# every dependsOn must name that namespace. Here bootstrap lives in ANOTHER
# repository's namespace, and every dependsOn must equal exactly the bootstrap
# the templates in this repository pin -- EXPECT_DEPENDS_ON, which is required.
#
# Required env: FEATURES STAGING_NAMESPACE PROD_NAMESPACE EXPECT_DEPENDS_ON
set -euo pipefail

: "${FEATURES:?}" "${STAGING_NAMESPACE:?}" "${PROD_NAMESPACE:?}" "${EXPECT_DEPENDS_ON:?}"
REGISTRY="${REGISTRY:-ghcr.io}"
# Where consumers resolve production. Normally the same registry staging is
# read from; separate so the script can review a staged copy in a local
# registry against the real production references.
PROD_REGISTRY="${PROD_REGISTRY:-$REGISTRY}"
OUT="${OUT:-staging-verdict.json}"

staging="${REGISTRY}/${STAGING_NAMESPACE,,}"
prod="${PROD_REGISTRY}/${PROD_NAMESPACE,,}"

[[ "$EXPECT_DEPENDS_ON" =~ ^ghcr\.io/[a-z0-9./-]+@sha256:[0-9a-f]{64}$ ]] || {
    echo "::error::EXPECT_DEPENDS_ON is not a digest-pinned reference: ${EXPECT_DEPENDS_ON@Q}" >&2; exit 1; }

fail=0
checked=0
: > /tmp/verdict.jsonl

while IFS= read -r feature; do
    [ -n "$feature" ] || continue
    # Re-assert the shape the matrix guard already checked: this reaches an OCI
    # reference below.
    [[ "$feature" =~ ^[a-z0-9][a-z0-9-]{0,63}$ ]] || {
        echo "::error::refusing to inspect a feature named ${feature@Q}" >&2; exit 1; }

    ref="${staging}/${feature}:latest"

    if ! digest=$(crane digest "$ref" 2>/dev/null); then
        echo "::error::${feature}: not present in staging at ${ref}" >&2
        fail=1; continue
    fi
    [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || {
        echo "::error::malformed digest for ${ref}: ${digest@Q}" >&2; exit 1; }

    # Inspect BY DIGEST, not by tag. A tag can move between this read and the
    # promotion; the digest is what the verdict commits to.
    meta="$(crane manifest "${staging}/${feature}@${digest}" 2>/dev/null \
            | jq -r '.annotations["dev.containers.metadata"] // empty')"
    if [ -z "$meta" ]; then
        echo "::error::${feature}: no dev.containers.metadata annotation on ${ref}" >&2
        fail=1; continue
    fi

    checked=$((checked + 1))

    # 1. No relative references. A consumer resolves "./neovim" against THEIR
    #    .devcontainer/ and gets an ENOENT naming a path inside their own repo.
    relative="$(jq -r '
        [ (.installsAfter // [])[], ((.dependsOn // {}) | keys[]) ]
        | map(select(startswith("./"))) | join(", ")' <<<"$meta")"
    if [ -n "$relative" ]; then
        echo "::error::${feature} staged with relative reference(s): ${relative}" >&2
        fail=1; continue
    fi

    # 2. installsAfter may only name the production namespace or the features
    #    repository -- never staging, which consumers cannot pull.
    stray="$(jq -r '(.installsAfter // [])[]' <<<"$meta" \
        | grep -vE "^(${prod//./\\.}|ghcr\.io/infrashift/trusted-devcontainer-features)/" || true)"
    if [ -n "$stray" ]; then
        echo "::error::${feature} installsAfter names a namespace consumers do not resolve: ${stray}" >&2
        fail=1
    fi

    # 3. dependsOn must be exactly the bootstrap the templates pin. Anything
    #    else installs a second bootstrap next to the template's own, and the
    #    build fails on the venv the first one created.
    ndeps=0
    while IFS= read -r dep; do
        [ -n "$dep" ] || continue
        ndeps=$((ndeps + 1))
        if [ "$dep" != "$EXPECT_DEPENDS_ON" ]; then
            echo "::error::${feature} dependsOn ${dep}, expected ${EXPECT_DEPENDS_ON}" >&2
            fail=1
        fi
    done < <(jq -r '(.dependsOn // {}) | keys[]' <<<"$meta")
    [ "$ndeps" -gt 0 ] || { echo "::error::${feature} declares no dependsOn" >&2; fail=1; }

    jq -n --arg f "$feature" --arg d "$digest" \
      '{feature: $f, digest: $d}' >> /tmp/verdict.jsonl
    echo "  ok ${feature} @ ${digest}"
done < <(jq -r '.[]' <<<"$FEATURES")

[ "$checked" -gt 0 ] || { echo "::error::inspected 0 staged features; refusing to call that a pass" >&2; exit 1; }
[ "$fail" -eq 0 ] || { echo "::error::staging review failed" >&2; exit 1; }

jq -s --arg staging "$staging" --arg prod "$prod" --arg dep "$EXPECT_DEPENDS_ON" \
  '{staging_namespace: $staging, production_namespace: $prod, depends_on: $dep,
    reviewed: length, features: .}' /tmp/verdict.jsonl > "$OUT"

echo "OK: ${checked} staged feature(s) reviewed; verdict written to ${OUT}"
