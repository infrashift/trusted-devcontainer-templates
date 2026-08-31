#!/usr/bin/env bash
# Build one template, exercise it, scan it, and sign the evidence with the BUILD
# key.
#
# This script decides nothing. It produces measurements and signs them so that
# review.yml can verify they came from the build actor and were not edited in
# transit. Grading happens there, publishing happens in release.yml.
#
# Required env: TEMPLATE PR_NUM HEAD_SHA BUILD_RUN_ID GITHUB_REPOSITORY
#               COSIGN_PRIVATE_KEY COSIGN_PASSWORD
set -euo pipefail

: "${TEMPLATE:?}" "${HEAD_SHA:?}" "${BUILD_RUN_ID:?}" "${GITHUB_REPOSITORY:?}"
: "${COSIGN_PRIVATE_KEY:?}" "${COSIGN_PASSWORD:?}"

# Re-assert the shape the matrix guard already checked. This script may be run
# by hand, and TEMPLATE reaches a path and an image tag below.
[[ "$TEMPLATE" =~ ^[a-z0-9][a-z0-9-]{0,63}$ ]] || {
  echo "::error::refusing to build a template named ${TEMPLATE@Q}" >&2; exit 1; }
[ -d "src/${TEMPLATE}" ] || { echo "::error::no such template: src/${TEMPLATE}" >&2; exit 1; }

DIR="evidence/${TEMPLATE}"
IMAGE="tdt-build-${TEMPLATE}:${HEAD_SHA:0:12}"
mkdir -p "$DIR"

# One timestamp for the whole leg. Every artefact below carries this exact
# value, so the evidence set is internally consistent and the policy's
# evaluated_at can be compared against it later.
EVALUATED_AT="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

echo "::group::build ${TEMPLATE}"
devcontainer build --workspace-folder "src/${TEMPLATE}" --image-name "$IMAGE"
echo "::endgroup::"

echo "::group::smoke test ${TEMPLATE}"
# devcontainer up --workspace-folder src/<t> mounts ONLY src/<t>, so the
# repo-level test/ tree is unreachable from inside the container under any
# relative path. Bind it in explicitly rather than changing published templates.
devcontainer up --workspace-folder "src/${TEMPLATE}" \
  --mount "type=bind,source=$(pwd)/test,target=/tmp/tdt-test"
devcontainer exec --workspace-folder "src/${TEMPLATE}" \
  bash "/tmp/tdt-test/${TEMPLATE}/test.sh"
echo "::endgroup::"

echo "::group::scan ${TEMPLATE}"
syft "$IMAGE" -o spdx-json="${DIR}/sbom.json"
grype "$IMAGE" -o json > "${DIR}/cve-report.json"
echo "::endgroup::"

# Normalise grype's report into exactly the shape the policy consumes. Doing it
# here, once, means the policy never has to know grype's schema, and a grype
# upgrade that moves a field fails loudly in this jq rather than silently
# producing an empty match list that reads as a clean scan.
jq -e '.matches | type == "array"' "${DIR}/cve-report.json" > /dev/null || {
  echo "::error::grype report has no matches array -- refusing to treat that as a clean scan" >&2
  exit 1
}

jq --arg now "$EVALUATED_AT" --arg t "$TEMPLATE" '{
  evaluated_at: $now,
  template_id: $t,
  scan: { status: "ran", tool: "grype" },
  matches: [ .matches[] | {
    id:        .vulnerability.id,
    severity:  .vulnerability.severity,
    package:   .artifact.name,
    version:   .artifact.version,
    # grype emits fix.state as an EMPTY STRING when it has nothing to say -- it
    # does not omit the field, which is what this previously assumed. jq'"'"'s //
    # only substitutes for null or false, so "" passed straight through and
    # tripped FIX_STATE_UNKNOWN in the policy. Seven findings per template did
    # exactly that, and the resulting FAIL was invisible behind a FAIL the CVE
    # counts explained on their own.
    fix_state: (if ((.vulnerability.fix.state // "") | length) == 0
                then "unknown" else .vulnerability.fix.state end),
    # WHERE the finding lives, so an exception can be scoped to the artifact its
    # justification actually describes. Without this the policy can only match on
    # CVE id, and a stdlib CVE waived for one Go binary is silently waived in
    # every Go binary -- which is exactly what EXC-2026-0001 was doing.
    location:  ((.artifact.locations // [])[0].path // ""),
    # grype'"'"'s artifact type, which is what distinguishes a package we install
    # from a dependency vendored inside one. See the remediation section of the
    # policy.
    type:      (.artifact.type // "unknown")
  } ]
}' "${DIR}/cve-report.json" > "${DIR}/scan-input.json"

# Assert the normalised vocabulary before the policy ever sees it. A grype
# release that adds a fix state should fail HERE, naming the value, rather than
# arriving as one policy violation per finding.
UNKNOWN_STATES=$(jq -r '[.matches[].fix_state] | map(select(. as $s | ["fixed","not-fixed","wont-fix","unknown"] | index($s) | not)) | unique | join(", ")' "${DIR}/scan-input.json")
if [ -n "$UNKNOWN_STATES" ]; then
    echo "::error::grype reported fix state(s) outside the known set: ${UNKNOWN_STATES}" >&2
    echo "::error::Update the fix_states set in .github/pdp/policies.rego and the mapping above." >&2
    exit 1
fi

echo "CVE summary for ${TEMPLATE}:"
jq -r '[.matches[].severity] | group_by(.) | map("  \(.[0]): \(length)") | .[]' "${DIR}/scan-input.json"

# SLSA provenance for the build itself.
#
# Resolved out of the heredoc so a failure here is a failure of this script and
# not a silently empty digest interpolated into signed evidence.
IMAGE_ID="$(docker image inspect "$IMAGE" --format '{{.Id}}' | sed 's/sha256://')"
[[ "$IMAGE_ID" =~ ^[0-9a-f]{64}$ ]] || {
  echo "::error::malformed image id for ${IMAGE}: ${IMAGE_ID}" >&2; exit 1; }

# This file is a full in-toto Statement, because that is what it is as EVIDENCE:
# a signed claim about the image this build produced. What gets published is a
# different subject -- the template artifact in the registry -- so publish-attest.sh
# hands cosign only the `predicate` body and lets cosign bind it to that subject.
# The image digest would be lost in that hand-off, so it is recorded a second
# time under runDetails.byproducts, which travels with the predicate.
cat > "${DIR}/provenance.json" <<EOF
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [ { "name": "${TEMPLATE}", "digest": { "sha256": "${IMAGE_ID}" } } ],
  "predicateType": "https://slsa.dev/provenance/v1",
  "predicate": {
    "buildDefinition": {
      "buildType": "https://github.com/infrashift/trusted-devcontainer-templates/build/v1",
      "externalParameters": {
        "source": { "uri": "git+https://github.com/${GITHUB_REPOSITORY}@${HEAD_SHA}", "digest": { "sha1": "${HEAD_SHA}" } },
        "templateId": "${TEMPLATE}"
      },
      "resolvedDependencies": [ { "uri": "src/${TEMPLATE}/.devcontainer/devcontainer.json" } ]
    },
    "runDetails": {
      "builder": { "id": "https://github.com/${GITHUB_REPOSITORY}/actions/runs/${BUILD_RUN_ID}" },
      "metadata": { "invocationId": "${BUILD_RUN_ID}", "startedOn": "${EVALUATED_AT}" },
      "byproducts": [ { "name": "container-image", "digest": { "sha256": "${IMAGE_ID}" } } ]
    }
  }
}
EOF

# Assert the output, not that the heredoc ran: this file is about to be signed
# and then split apart at publish time, so both halves must be well formed here.
jq -e '.predicate | has("buildDefinition") and has("runDetails")' \
  "${DIR}/provenance.json" > /dev/null || {
  echo "::error::provenance.json for ${TEMPLATE} is not a well-formed SLSA v1 statement" >&2
  exit 1; }

# A manifest binding this evidence set to the commit and run that produced it.
# review.yml verifies the signature over THIS file, so a swapped scan-input.json
# changes the checksum and fails verification.
(cd "$DIR" && sha256sum sbom.json cve-report.json scan-input.json provenance.json > checksums.sha256)

jq -n --arg t "$TEMPLATE" --arg sha "$HEAD_SHA" --arg run "$BUILD_RUN_ID" \
      --arg now "$EVALUATED_AT" --arg pr "${PR_NUM:-}" \
      --arg sums "$(cat "${DIR}/checksums.sha256")" \
  '{template: $t, headSha: $sha, buildRunId: $run, pullRequest: $pr,
    producedAt: $now, checksums: $sums}' > "${DIR}/evidence-manifest.json"

echo "::group::sign evidence with the build key"
for f in sbom.json cve-report.json scan-input.json provenance.json checksums.sha256 evidence-manifest.json; do
  cosign sign-blob --yes --key env://COSIGN_PRIVATE_KEY \
    --output-signature "${DIR}/${f}.sig" "${DIR}/${f}"
done
echo "::endgroup::"

echo "OK: evidence for ${TEMPLATE} produced and signed"
