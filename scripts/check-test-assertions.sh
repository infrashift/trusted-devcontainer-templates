#!/usr/bin/env bash
# Assert that each template's smoke test checks for the version that template
# actually requests.
#
# test/<t>/test.sh is a FOURTH copy of the version contract -- after the feature's
# declared default, the feature repo's ROLE_ARGS, and this repo's explicit option
# values. It drifted the moment python moved to 3.13: the container had 3.13, the
# test asked for 3.12, and `Build python` failed with "FAIL: python 3.12 is
# installed" -- which reads like the feature broke rather than like the test was
# stale.
#
# Guards the direction that actually bites. A test asserting a version nobody
# installs fails loudly, but only after a full container build.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

fail=0
checked=0

for tmpl in src/*/.devcontainer/devcontainer.json; do
    name=$(basename "$(dirname "$(dirname "$tmpl")")")
    test_file="test/${name}/test.sh"
    [ -f "$test_file" ] || continue

    # The python version this template requests, if it requests one explicitly.
    want=$(python3 - "$tmpl" <<'PYEOF' 2>/dev/null || true
import json, sys
doc = json.load(open(sys.argv[1]))
for ref, opts in (doc.get("features") or {}).items():
    if ref.split("@")[0].rsplit("/", 1)[-1] == "python":
        v = (opts or {}).get("target_version")
        if v:
            print(v)
PYEOF
)
    [ -n "$want" ] || continue

    # Every version the test asserts via `uv python find`.
    while IFS= read -r got; do
        [ -n "$got" ] || continue
        checked=$((checked + 1))
        if [ "$got" != "$want" ]; then
            echo "::error::${test_file} asserts python ${got}, but ${tmpl} requests ${want}" >&2
            fail=1
        fi
    done < <(grep -oE 'uv python find [0-9.]+' "$test_file" | awk '{print $4}')
done

[ "$checked" -gt 0 ] || { echo "::error::checked 0 assertions; refusing to call that a pass" >&2; exit 1; }
[ "$fail" -eq 0 ] || exit 1
echo "OK: ${checked} smoke-test python assertion(s) match the version their template requests"
