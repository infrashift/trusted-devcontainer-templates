#!/usr/bin/env bash
# Sign every staged feature with the release key, and again keylessly.
#
# Ported from trusted-devcontainer-features. Signs the STAGING namespace
# (SIGN_NAMESPACE); promote-features.sh refuses a digest it finds no signature
# for, and carries the signature tags into production with the bytes.
#
# Before this existed the pipeline pushed features to GHCR and signed nothing.
# A consumer had no way to tell a feature this org published from one someone
# else pushed to a repository that looks like ours.
#
# Two signatures answer two different questions. The keyed one proves it came
# from this organisation's release actor and verifies offline against a
# committed public key. The keyless one puts a transparency-log entry in Rekor
# that a third party can audit without holding any of our keys.
#
# Required env: FEATURES SIGN_NAMESPACE COSIGN_PRIVATE_KEY COSIGN_PASSWORD
set -euo pipefail

: "${FEATURES:?}" "${SIGN_NAMESPACE:?}"
: "${COSIGN_PRIVATE_KEY:?}" "${COSIGN_PASSWORD:?}"

# SIGN_NAMESPACE is a full registry path, e.g.
# ghcr.io/infrashift/trusted-devcontainer-templates-staging/features.
SIGN_NAMESPACE="${SIGN_NAMESPACE,,}"

signed=0
skipped=0
: > /tmp/signed.jsonl

while IFS= read -r feature; do
  [ -n "$feature" ] || continue
  # Re-assert the shape the matrix guard already checked: this reaches an OCI
  # reference below.
  [[ "$feature" =~ ^[a-z0-9][a-z0-9-]{0,63}$ ]] || {
    echo "::error::refusing to sign a feature named ${feature@Q}" >&2; exit 1; }

  ref="${SIGN_NAMESPACE}/${feature}:latest"

  # A feature whose version did not change is not re-published, so its tag may
  # legitimately not exist yet on a first release. Report it and move on rather
  # than failing the whole release -- but count it, so "signed 0 of 20" cannot
  # pass silently.
  if ! digest=$(crane digest "$ref" 2>/dev/null); then
    echo "  skip ${feature}: ${ref} not found in the registry"
    skipped=$((skipped + 1))
    continue
  fi

  [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || {
    echo "::error::crane returned a malformed digest for ${ref}: ${digest}" >&2; exit 1; }

  # Pin the signature to the digest, never the tag. A tag can move between the
  # signature and what a consumer pulls; a digest cannot.
  uri="${SIGN_NAMESPACE}/${feature}@${digest}"
  echo "  sign ${uri}"

  cosign sign --yes --key env://COSIGN_PRIVATE_KEY "$uri"
  cosign sign --yes "$uri"

  jq -n --arg f "$feature" --arg d "$digest" --arg u "$uri" \
    '{feature: $f, digest: $d, uri: $u}' >> /tmp/signed.jsonl
  signed=$((signed + 1))
done < <(jq -r '.[]' <<<"$FEATURES")

jq -s --arg ns "$SIGN_NAMESPACE" \
  '{namespace: $ns, signed: length, features: .}' \
  /tmp/signed.jsonl > release-manifest.json

echo "signed ${signed} feature(s), skipped ${skipped}"

if [ "$signed" -eq 0 ]; then
  echo "::error::nothing was signed. Either no feature published, or every digest lookup failed." >&2
  exit 1
fi
