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
# Nothing here trusts that a step ran. Every artifact is read back out of the
# registry afterwards and verified against the committed public half of the
# release key, because a green cosign exit code proves what a runner did, not
# what a consumer will be able to pull.
#
# Required env: MATRIX VERSION GITHUB_REPOSITORY COSIGN_PRIVATE_KEY COSIGN_PASSWORD
set -euo pipefail

: "${MATRIX:?}" "${VERSION:?}" "${GITHUB_REPOSITORY:?}"
: "${COSIGN_PRIVATE_KEY:?}" "${COSIGN_PASSWORD:?}"

REGISTRY="${REGISTRY:-ghcr.io}"
owner_repo="${GITHUB_REPOSITORY,,}"

# The public half is committed, so this verification needs no secret and can be
# reproduced by anyone against the same artifacts.
RELEASE_PUB=".github/pdp/public-keys/release.pub"
[ -f "$RELEASE_PUB" ] || { echo "::error::missing ${RELEASE_PUB}" >&2; exit 1; }

# devcontainers/action tags each template with the `version` field from its
# devcontainer-template.json, so this is the tag THIS run should have produced.
version="${VERSION#v}"

attested=0

while IFS= read -r template; do
  [ -n "$template" ] || continue
  echo "::group::attest and sign ${template}"

  dir="staged/evidence-${template}/${template}"
  [ -d "$dir" ] || { echo "::error::no staged evidence at ${dir}" >&2; exit 1; }

  # Resolve the digest of what was actually published, and pin every
  # attestation to that digest rather than to a tag. A tag can move between the
  # attestation and the thing a consumer pulls; a digest cannot.
  #
  # Resolved from the RELEASED version, never from :latest. devcontainers/action
  # silently skips a template whose version already exists in the registry, and
  # :latest resolves fine in that case -- so a release that published nothing
  # would re-attest the previous artifact and finish green. Asking for the exact
  # version turns that into a hard failure, and makes the git tag and the
  # template version fields structurally agree.
  ref="${REGISTRY}/${owner_repo}/${template}:${version}"
  if ! digest=$(crane digest "$ref"); then
    echo "::error::${ref} not found. devcontainers/action did not publish ${template} at ${version} -- does src/${template}/devcontainer-template.json declare version ${version}?" >&2
    exit 1
  fi
  [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || {
    echo "::error::crane returned a malformed digest for ${ref}: ${digest}" >&2; exit 1; }
  uri="${REGISTRY}/${owner_repo}/${template}@${digest}"
  echo "  ${uri}"

  cosign attest --yes --key env://COSIGN_PRIVATE_KEY \
    --type spdxjson --predicate "${dir}/sbom.json" "$uri"

  cosign attest --yes --key env://COSIGN_PRIVATE_KEY \
    --type vuln --predicate "${dir}/cve-report.json" "$uri"

  # cosign's --predicate takes the PREDICATE BODY and builds the in-toto
  # Statement itself, binding the subject to $uri. provenance.json is a full
  # Statement, so passing it whole nests a Statement inside the predicate and
  # anyone reading .predicate.buildDefinition finds nothing. Hand over .predicate
  # and let cosign bind the subject to what was actually published.
  pred="${dir}/provenance-predicate.json"
  jq -e '.predicate | select(has("buildDefinition") and has("runDetails"))' \
    "${dir}/provenance.json" > "$pred" || {
    echo "::error::${dir}/provenance.json has no SLSA v1 predicate body" >&2; exit 1; }

  cosign attest --yes --key env://COSIGN_PRIVATE_KEY \
    --type slsaprovenance1 --predicate "$pred" "$uri"

  cosign sign --yes --key env://COSIGN_PRIVATE_KEY "$uri"
  cosign sign --yes "$uri"

  # Read it all back. Everything above proves cosign exited 0 in this runner;
  # only this proves a consumer can pull the artifact and verify it against the
  # committed public key.
  cosign verify --key "$RELEASE_PUB" "$uri" > /dev/null

  for t in spdxjson vuln slsaprovenance1; do
    cosign verify-attestation --key "$RELEASE_PUB" --type "$t" "$uri" > /dev/null || {
      echo "::error::${t} attestation missing or unverifiable for ${uri}" >&2; exit 1; }
  done

  # The shape check the predicate extraction above exists for. A nested Statement
  # still verifies -- the signature is over whatever bytes were sent -- so the
  # only way to catch it is to decode the payload and look for the SLSA fields,
  # and to confirm cosign bound the subject to the artifact we just published.
  cosign verify-attestation --key "$RELEASE_PUB" --type slsaprovenance1 "$uri" \
    | jq -e --arg d "${digest#sha256:}" '
        .payload | @base64d | fromjson
        | (.predicate | has("buildDefinition"))
          and (.subject[0].digest.sha256 == $d)' > /dev/null || {
    echo "::error::published provenance for ${template} is malformed or bound to the wrong subject" >&2
    exit 1; }

  attested=$((attested + 1))
  echo "::endgroup::"
done < <(jq -r '.[].template' <<<"$MATRIX")

# "attested 0 of 5" must never pass silently.
expected=$(jq -r 'length' <<<"$MATRIX")
[ "$attested" -eq "$expected" ] || {
  echo "::error::attested ${attested} template(s) but the matrix held ${expected}" >&2; exit 1; }

echo "OK: ${attested} template(s) attested, verified and dual-signed for ${VERSION}"
