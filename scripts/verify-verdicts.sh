#!/usr/bin/env bash
# Verify every review verdict against the REVIEW public key before anything is
# published.
#
# The release actor trusts the review actor's SIGNATURE, not the review job's
# exit code. A green job is a claim about what happened in a runner; a signature
# over a verdict is evidence. This runs before the first push, so a template
# whose verdict is missing, unsigned, or not PASS stops the whole release rather
# than leaving a partial publish behind.
#
# Required env: MATRIX (the JSON matrix)
set -euo pipefail

: "${MATRIX:?}"
REVIEW_PUB=".github/pdp/public-keys/review.pub"

[ -f "$REVIEW_PUB" ] || {
  echo "::error::${REVIEW_PUB} is missing. The release actor cannot verify review verdicts without it." >&2
  echo "::error::See SETUP-ENVIRONMENTS.md." >&2
  exit 1
}

fail=0
count=0

while IFS= read -r template; do
  [ -n "$template" ] || continue
  count=$((count + 1))
  v="verdicts/review-${template}/review-verdict.json"

  if [ ! -f "$v" ] || [ ! -f "${v}.sig" ]; then
    echo "::error::no signed verdict for ${template}; refusing to publish" >&2
    fail=1
    continue
  fi

  if ! cosign verify-blob --key "$REVIEW_PUB" --signature "${v}.sig" "$v" >/dev/null 2>&1; then
    echo "::error::verdict for ${template} is not signed by the review key" >&2
    fail=1
    continue
  fi

  verdict=$(jq -r '.verdict' "$v")
  got_tpl=$(jq -r '.template' "$v")
  if [ "$got_tpl" != "$template" ]; then
    echo "::error::verdict filed under ${template} is actually for ${got_tpl}" >&2
    fail=1
    continue
  fi
  if [ "$verdict" != "PASS" ]; then
    echo "::error::${template} verdict is ${verdict}; refusing to publish" >&2
    fail=1
    continue
  fi
  echo "  verified PASS: ${template}"
done < <(jq -r '.[].template' <<<"$MATRIX")

[ "$count" -gt 0 ] || { echo "::error::matrix was empty; nothing to verify, refusing to publish" >&2; exit 1; }

if [ "$fail" -eq 0 ]; then
  echo "OK: ${count} verdict(s) verified against the review key"
else
  exit 1
fi
