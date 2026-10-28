#!/usr/bin/env bash
# Fail if user-facing documentation tells anyone to verify with a key the
# pipeline does not sign with.
#
# Every user doc said `cosign verify --key cosign-release.pub` for two months
# after the three-key rotation replaced that key. Verification with it fails, so
# a user who followed the docs concluded the release was not genuine -- or, more
# likely, stopped checking. Nothing compared the docs against the scripts that
# actually sign.
#
# The keys are read from the scripts, not restated here, so a future rotation
# that edits the scripts but not the docs fails this check:
#   release key  -> publish-attest.sh   (template signature and attestations)
#   build key    -> review-template.sh  (evidence blobs, verified by Review)
#   review key   -> verify-verdicts.sh  (review verdict)
set -euo pipefail

KEY_DIR=".github/pdp/public-keys"

key_from() { # <script> <VAR>: basename of the key path the script assigns to VAR
  local v
  v=$(sed -nE "s/^${2}=\"?([^\"]+)\"?$/\1/p" "$1" | head -n1)
  [ -n "$v" ] || { echo "error: no ${2}= assignment in $1" >&2; exit 1; }
  basename "$v"
}
RELEASE_KEY=$(key_from scripts/publish-attest.sh RELEASE_PUB)
BUILD_KEY=$(key_from scripts/review-template.sh BUILD_PUB)
REVIEW_KEY=$(key_from scripts/verify-verdicts.sh REVIEW_PUB)

DOCS=(README.md SETUP-ENVIRONMENTS.md)
while IFS= read -r f; do DOCS+=("$f"); done < <(
  find docs/src -type f \( -name '*.md' -o -name '*.mdx' -o -name '*.astro' \) | sort)

fail=0

# 1. Every key path a doc names must exist.
while IFS=: read -r f line ref; do
  key=$(basename "$ref")
  if [ ! -f "${KEY_DIR}/${key}" ]; then
    echo "error: ${f}:${line} names ${KEY_DIR}/${key}, which does not exist" >&2
    fail=1
  fi
done < <(grep -noE "public-keys/[A-Za-z0-9._-]+\.pub" "${DOCS[@]}" || true)

# 2. Every keyed cosign verify uses the key that signs what it verifies.
# Shell continuations are joined first, so a command split over lines with `\`
# is read whole.
for f in "${DOCS[@]}"; do
  while IFS= read -r cmd; do
    sub=$(sed -nE 's/.*cosign (verify-blob|verify-attestation|verify)[[:space:]].*/\1/p' <<<"$cmd")
    key=$(sed -nE 's/.*--key[ =]+([^ `"]+).*/\1/p' <<<"$cmd")
    [ -n "$key" ] || continue # keyless: nothing to check
    key=$(basename "$key")
    case "$sub" in
      verify|verify-attestation) want="$RELEASE_KEY" ;;
      verify-blob)
        # An evidence blob is the Build-Actor's; a verdict is the Review-Actor's.
        if grep -q 'review-verdict' <<<"$cmd"; then want="$REVIEW_KEY"; else want="$BUILD_KEY"; fi ;;
    esac
    if [ "$key" != "$want" ]; then
      echo "error: ${f}: \`cosign ${sub} --key ${key}\` -- the pipeline signs this with ${want}" >&2
      fail=1
    fi
  done < <(sed -e ':a' -e '/\\$/N; s/\\\n//; ta' "$f" | grep -oE 'cosign (verify-blob|verify-attestation|verify)[[:space:]][^`]*' || true)
done

[ "$fail" -eq 0 ] && echo "OK: docs verify with ${RELEASE_KEY} (templates), ${BUILD_KEY} (evidence), ${REVIEW_KEY} (verdicts)"
exit "$fail"
