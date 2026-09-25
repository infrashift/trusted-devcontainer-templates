#!/usr/bin/env bash
# Promote reviewed features from the staging namespace to production, by digest.
#
# Ported from trusted-devcontainer-features; production is PROD_NAMESPACE
# rather than the repository's own namespace.
#
# WHY BY DIGEST
#
# The verdict names a digest per feature. Copying that digest is what makes the
# review binding: the bytes promoted are the bytes inspected, not "whatever is
# in staging now". Re-resolving the tag here would reopen exactly the gap the
# staging split closes -- a build actor could push again between review and
# promotion and ship something nobody looked at.
#
# THE VERDICT SIGNATURE IS CHECKED FIRST
#
# The verdict is produced by the review actor and signed with the review key.
# This job holds the release key, not the review key, so it cannot forge one.
# Verification against the committed public half is the gate; everything after
# it is mechanical.
#
# Required env: PROD_NAMESPACE
# Optional env: VERDICT (default staging-verdict.json)
#               REVIEW_PUB (default .github/pdp/public-keys/review.pub)
#               DRY_RUN=1  verify and report, copy nothing
set -euo pipefail

: "${PROD_NAMESPACE:?}"
REGISTRY="${REGISTRY:-ghcr.io}"
VERDICT="${VERDICT:-staging-verdict.json}"
REVIEW_PUB="${REVIEW_PUB:-.github/pdp/public-keys/review.pub}"

[ -f "$VERDICT" ]    || { echo "::error::verdict ${VERDICT} not found" >&2; exit 1; }
[ -f "${VERDICT}.sig" ] || { echo "::error::verdict signature ${VERDICT}.sig not found" >&2; exit 1; }
[ -f "$REVIEW_PUB" ] || { echo "::error::review public key ${REVIEW_PUB} not found" >&2; exit 1; }

# Fail closed: an unverifiable verdict promotes nothing.
if ! cosign verify-blob --key "$REVIEW_PUB" --signature "${VERDICT}.sig" "$VERDICT" >/dev/null 2>&1; then
  echo "::error::verdict signature does not verify against ${REVIEW_PUB}. Promoting nothing." >&2
  exit 1
fi
echo "verdict signature verified against ${REVIEW_PUB}"

staging=$(jq -r '.staging_namespace' "$VERDICT")
prod="${REGISTRY}/${PROD_NAMESPACE,,}"

# The verdict records the production namespace it was reviewed against. If that
# disagrees with where we are about to push, the verdict is not about this
# release and must not authorise it.
claimed_prod=$(jq -r '.production_namespace' "$VERDICT")
[ "$claimed_prod" = "$prod" ] || {
  echo "::error::verdict was reviewed against ${claimed_prod}, but this job would promote to ${prod}" >&2
  exit 1; }

promoted=0
while IFS=$'\t' read -r feature digest; do
  [ -n "$feature" ] || continue
  [[ "$feature" =~ ^[a-z0-9][a-z0-9-]{0,63}$ ]] || {
    echo "::error::refusing to promote a feature named ${feature@Q}" >&2; exit 1; }
  [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || {
    echo "::error::verdict carries a malformed digest for ${feature}: ${digest@Q}" >&2; exit 1; }

  src="${staging}/${feature}@${digest}"

  # The digest still has to BE there. A verdict for bytes that have since been
  # deleted or replaced must fail rather than promote something else.
  actual=$(crane digest "${staging}/${feature}:latest" 2>/dev/null || true)
  [ "$actual" = "$digest" ] || {
    echo "::error::${feature}: staging :latest is ${actual@Q}, verdict approved ${digest}" >&2
    echo "           Staging moved after review. Refusing to promote." >&2
    exit 1; }

  # THE SIGNATURE MUST ALREADY EXIST, and this is the gate that makes "signed"
  # true rather than customary. Signing used to run AFTER this script, so a
  # failure there left promoted-but-unsigned bytes in production with every
  # consumer tag pointing at them and nothing downstream noticing -- which
  # happened on a cosign keyless OIDC hiccup (sqlpackage 1.0.2, 2026-09-16).
  # The release now signs staging first; refusing here is what makes the
  # ordering enforced rather than merely intended.
  sig_tag="sha256-${digest#sha256:}.sig"
  if ! crane digest "${staging}/${feature}:${sig_tag}" >/dev/null 2>&1; then
    echo "::error::${feature}: no signature in staging for ${digest}" >&2
    echo "           Expected ${staging}/${feature}:${sig_tag}." >&2
    echo "           Sign staging before promoting (SIGN_NAMESPACE=<staging> features/scripts/sign-features.sh)." >&2
    exit 1
  fi

  # Copy every tag staging carries, so production ends up with the same version,
  # major, minor and latest tags a consumer resolves against. Each copy is of the
  # SAME digest, so the tag set differs but the bytes cannot.
  #
  # EXCEPT the cosign tags. A signature is its own manifest under a tag derived
  # from the digest it signs, so copying `$src' onto that name would overwrite
  # the signature with the image and leave production looking signed while
  # holding nothing of the sort. They are copied tag-to-tag below instead.
  mapfile -t tags < <(crane ls "${staging}/${feature}" 2>/dev/null | sort)
  [ "${#tags[@]}" -gt 0 ] || { echo "::error::${feature}: no tags in staging" >&2; exit 1; }

  sigs=0
  for t in "${tags[@]}"; do
    case "$t" in
      sha256-*.sig|sha256-*.att|sha256-*.sbom)
        if [ "${DRY_RUN:-0}" = "1" ]; then
          echo "  would copy ${staging}/${feature}:${t} -> ${prod}/${feature}:${t}"
        else
          crane copy "${staging}/${feature}:${t}" "${prod}/${feature}:${t}"
        fi
        sigs=$((sigs + 1))
        continue
        ;;
    esac
    if [ "${DRY_RUN:-0}" = "1" ]; then
      echo "  would copy ${src} -> ${prod}/${feature}:${t}"
    else
      crane copy "$src" "${prod}/${feature}:${t}"
    fi
  done

  if [ "${DRY_RUN:-0}" != "1" ]; then
    # Assert the copy landed on the reviewed digest. crane copy preserves the
    # manifest, so a mismatch here means something other than a copy happened.
    landed=$(crane digest "${prod}/${feature}:latest")
    [ "$landed" = "$digest" ] || {
      echo "::error::${feature}: promoted digest ${landed} != reviewed ${digest}" >&2; exit 1; }
  fi

  echo "  promoted ${feature} @ ${digest} (${#tags[@]} tag(s), ${sigs} signature tag(s))"
  promoted=$((promoted + 1))
done < <(jq -r '.features[] | [.feature, .digest] | @tsv' "$VERDICT")

[ "$promoted" -gt 0 ] || { echo "::error::promoted 0 features; refusing to call that a release" >&2; exit 1; }
echo "promoted ${promoted} feature(s) from ${staging} to ${prod}"
