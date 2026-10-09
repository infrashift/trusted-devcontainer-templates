#!/usr/bin/env bash
# Assert that every repo-local feature depends on exactly the bootstrap the
# feature test templates in this repository pin.
#
# WHY
#
# The features here declare dependsOn by absolute, digest-pinned reference to
# ghcr.io/infrashift/trusted-devcontainer-features/bootstrap. A template lists
# bootstrap too. When the two digests differ the devcontainer CLI treats them as
# two different features, installs both, and the second install fails on the
# venv the first one created -- the failure scripts/pin-features.sh describes
# for the java template. That check reads PUBLISHED metadata, so it only sees
# these features once they are released; this one reads the source, so the
# mismatch is caught on the pull request that introduces it.
#
# When `make pin-features` moves the templates to a new bootstrap, every feature
# here must move with it -- and, because its source changed, bump its version.
#
# AGAINST THE FEATURE TEST TEMPLATES, NOT THE PUBLISHED ONES (2026-10-09). The
# feature test templates (features/test/*) build these features FROM SOURCE, so
# they are what this source-level check must agree with. The published
# templates (src/*) pin these features BY DIGEST, i.e. their PUBLISHED
# metadata, and scripts/pin-features.sh --check already asserts that every
# dependsOn a published template pulls in names that template's bootstrap.
# Comparing the source to src/* as well made a bootstrap move impossible once a
# published template pinned a repo-local feature: the features must name the new
# bootstrap before they can be released, and src/* cannot name it until they
# are -- so no pull request could pass both checks (bootstrap 1.6.0 -> 1.6.1,
# CVE-2026-19445/-19553). The move is now two pull requests: the features and
# their test templates, released by release-features.yml; then
# `make pin-features` for src/*.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1

BOOT_REF="ghcr.io/infrashift/trusted-devcontainer-features/bootstrap"

# Every feature test template: they build the features from source.
mapfile -t CONFIGS < <(find features/test -path '*/.devcontainer/devcontainer.json' | sort)
mapfile -t PINS < <(grep -hoE "${BOOT_REF}@sha256:[0-9a-f]{64}" "${CONFIGS[@]}" | sort -u)

case "${#PINS[@]}" in
    0) echo "::error::no devcontainer.json pins ${BOOT_REF}; refusing to call that a pass" >&2; exit 1 ;;
    1) want="${PINS[0]}" ;;
    *) echo "::error::the feature test templates pin ${#PINS[@]} different bootstraps; run make pin-features:" >&2
       printf '  %s\n' "${PINS[@]}" >&2; exit 1 ;;
esac

fail=0
checked=0
for f in features/src/*/devcontainer-feature.json; do
    name=$(basename "$(dirname "$f")")
    # JSONC: drop // comments, then read dependsOn's keys.
    mapfile -t deps < <(sed 's://.*$::' "$f" | python3 -c '
import json, sys
for k in (json.load(sys.stdin).get("dependsOn") or {}):
    print(k)')
    if [ "${#deps[@]}" -eq 0 ]; then
        echo "::error::${name}: declares no dependsOn; every feature must depend on ${want}" >&2
        fail=1; continue
    fi
    for d in "${deps[@]}"; do
        checked=$((checked + 1))
        if [ "$d" != "$want" ]; then
            echo "::error::${name}: dependsOn ${d}, but the feature test templates pin ${want}" >&2
            fail=1
        fi
    done
done

[ "$checked" -gt 0 ] || { echo "::error::checked 0 dependsOn references; refusing to call that a pass" >&2; exit 1; }
[ "$fail" -eq 0 ] || exit 1
echo "OK: all ${checked} feature dependsOn reference(s) name the bootstrap the feature test templates pin (${want##*@})"
