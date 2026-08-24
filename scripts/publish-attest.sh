#!/usr/bin/env bash
# Attach SBOM, CVE and provenance attestations to each published template and
# sign it twice: once with the sovereign RELEASE key, once keylessly through
# Fulcio/Rekor.
#
# Two signatures answer two different questions. The keyed one proves it came
# from this organisation's release actor and can be verified offline against a
# committed public key. The keyless one puts a transparency-log entry in Rekor
# that a third party can audit without holding any of our keys.
#
# Required env: MATRIX VERSION GITHUB_REPOSITORY COSIGN_PRIVATE_KEY COSIGN_PASSWORD
set -euo pipefail

: "${MATRIX:?}" "${VERSION:?}" "${GITHUB_REPOSITORY:?}"
: "${COSIGN_PRIVATE_KEY:?}" "${COSIGN_PASSWORD:?}"

REGISTRY="${REGISTRY:-ghcr.io}"
owner_repo="${GITHUB_REPOSITORY,,}"

while IFS= read -r template; do
  [ -n "$template" ] || continue
  echo "::group::attest and sign ${template}"

  dir="staged/evidence-${template}/${template}"
  [ -d "$dir" ] || { echo "::error::no staged evidence at ${dir}" >&2; exit 1; }

  # Resolve the digest of what was actually published, and pin every
  # attestation to that digest rather than to a tag. A tag can move between the
  # attestation and the thing a consumer pulls; a digest cannot.
  ref="${REGISTRY}/${owner_repo}/${template}:latest"
  digest=$(crane digest "$ref")
  [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || {
    echo "::error::crane returned a malformed digest for ${ref}: ${digest}" >&2; exit 1; }
  uri="${REGISTRY}/${owner_repo}/${template}@${digest}"
  echo "  ${uri}"

  cosign attest --yes --key env://COSIGN_PRIVATE_KEY \
    --type spdxjson --predicate "${dir}/sbom.json" "$uri"

  cosign attest --yes --key env://COSIGN_PRIVATE_KEY \
    --type vuln --predicate "${dir}/cve-report.json" "$uri"

  cosign attest --yes --key env://COSIGN_PRIVATE_KEY \
    --type slsaprovenance1 --predicate "${dir}/provenance.json" "$uri"

  cosign sign --yes --key env://COSIGN_PRIVATE_KEY "$uri"
  cosign sign --yes "$uri"

  echo "::endgroup::"
done < <(jq -r '.[].template' <<<"$MATRIX")

echo "OK: all templates attested and dual-signed for ${VERSION}"
