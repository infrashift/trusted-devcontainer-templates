#!/usr/bin/env bash
# Verify one template's build evidence, evaluate the CVE policy against it, and
# sign the resulting verdict with the REVIEW key.
#
# The build actor produced these measurements and signed them. This script's
# first job is to prove they are the same bytes -- verified against the build
# actor's committed PUBLIC key, so a forged or edited evidence set cannot reach
# the policy at all. Only then does it grade.
#
# Required env: TEMPLATE HEAD_SHA BUILD_RUN_ID REVIEW_RUN_ID GITHUB_REPOSITORY
#               COSIGN_PRIVATE_KEY COSIGN_PASSWORD
set -euo pipefail

: "${TEMPLATE:?}" "${HEAD_SHA:?}" "${BUILD_RUN_ID:?}" "${REVIEW_RUN_ID:?}"
: "${COSIGN_PRIVATE_KEY:?}" "${COSIGN_PASSWORD:?}"

[[ "$TEMPLATE" =~ ^[a-z0-9][a-z0-9-]{0,63}$ ]] || {
  echo "::error::refusing to review a template named ${TEMPLATE@Q}" >&2; exit 1; }

DIR="evidence/${TEMPLATE}"
BUILD_PUB=".github/pdp/public-keys/build.pub"

[ -f "$BUILD_PUB" ] || {
  echo "::error::${BUILD_PUB} is missing. The review actor cannot verify build evidence without it." >&2
  echo "::error::See SETUP-ENVIRONMENTS.md -- the three keypairs must be generated and their public halves committed." >&2
  exit 1
}

# --- 1. Verify every signed artefact against the BUILD public key -----------
echo "::group::verify build signatures"
for f in sbom.json cve-report.json scan-input.json provenance.json checksums.sha256 evidence-manifest.json; do
  [ -f "${DIR}/${f}" ]     || { echo "::error::missing evidence: ${DIR}/${f}" >&2; exit 1; }
  [ -f "${DIR}/${f}.sig" ] || { echo "::error::missing signature: ${DIR}/${f}.sig" >&2; exit 1; }
  cosign verify-blob --key "$BUILD_PUB" --signature "${DIR}/${f}.sig" "${DIR}/${f}" \
    || { echo "::error::signature verification FAILED for ${f}" >&2; exit 1; }
  echo "  verified ${f}"
done
echo "::endgroup::"

# --- 2. Verify the checksums the manifest committed to ---------------------
# The signature proves the manifest is the build actor's. This proves the files
# alongside it are the ones that manifest describes.
echo "::group::verify evidence checksums"
(cd "$DIR" && sha256sum -c checksums.sha256) || {
  echo "::error::evidence checksums do not match; the set was modified after signing" >&2; exit 1; }
echo "::endgroup::"

# --- 3. Confirm the evidence belongs to THIS commit and build --------------
# Without this, a valid, correctly signed evidence set from a different commit
# would verify perfectly and grade something nobody asked about.
M="${DIR}/evidence-manifest.json"
got_sha=$(jq -r '.headSha' "$M")
got_run=$(jq -r '.buildRunId' "$M")
got_tpl=$(jq -r '.template' "$M")
[ "$got_sha" = "$HEAD_SHA" ]      || { echo "::error::evidence is for commit ${got_sha}, expected ${HEAD_SHA}" >&2; exit 1; }
[ "$got_run" = "$BUILD_RUN_ID" ]  || { echo "::error::evidence is from build run ${got_run}, expected ${BUILD_RUN_ID}" >&2; exit 1; }
[ "$got_tpl" = "$TEMPLATE" ]      || { echo "::error::evidence is for template ${got_tpl}, expected ${TEMPLATE}" >&2; exit 1; }

# --- 4. Evaluate the policy ------------------------------------------------
# evaluated_at is stamped by the review actor, not read from a clock inside the
# policy, so this decision replays identically later.
EVALUATED_AT="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
jq --arg now "$EVALUATED_AT" '.evaluated_at = $now' "${DIR}/scan-input.json" > /tmp/policy-input.json

opa eval \
  --data .github/pdp/policies.rego \
  --data .github/pdp/exceptions.yaml \
  --input /tmp/policy-input.json \
  --format json 'data.tdt.pdp.decision' \
| jq -e '.result[0].expressions[0].value' > /tmp/decision.json

# jq -e exits non-zero on null/false, so a policy that failed to load or a rule
# that came back undefined is a hard failure, never a silent pass.

jq -n \
  --slurpfile d /tmp/decision.json \
  --arg t "$TEMPLATE" --arg sha "$HEAD_SHA" \
  --arg brun "$BUILD_RUN_ID" --arg rrun "$REVIEW_RUN_ID" \
  --arg pr "${PR_NUM:-}" --arg now "$EVALUATED_AT" \
  '{ template: $t, headSha: $sha, buildRunId: $brun, reviewRunId: $rrun,
     pullRequest: $pr, reviewedAt: $now,
     verdict: $d[0].verdict, counts: $d[0].counts,
     violations: $d[0].violations, blocking: $d[0].blocking,
     waived: $d[0].waived, exceptions_applied: $d[0].exceptions_applied }' \
  > review-verdict.json

cosign sign-blob --yes --key env://COSIGN_PRIVATE_KEY \
  --output-signature review-verdict.json.sig review-verdict.json

VERDICT=$(jq -r '.verdict' review-verdict.json)
jq -r '.violations[]? | "  X \(.code): \(.message)"' review-verdict.json
jq -r '.blocking[]?   | "  X \(.id) \(.severity) in \(.package) (fix: \(.fix_state))"' review-verdict.json
jq -r '.waived[]?     | "  ~ \(.id) waived by \(.waiver_id) until \(.waiver_expires)"' review-verdict.json

echo "verdict for ${TEMPLATE}: ${VERDICT}"
# The verdict is recorded and signed either way. A FAIL is reported to the PR by
# review.yml's summary job rather than thrown away by a non-zero exit here.
