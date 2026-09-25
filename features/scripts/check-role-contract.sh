#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# features/scripts/check-role-contract.sh
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Enforces the feature role contract (ADR-012 in trusted-devcontainer-features)
# on the repo-local features under features/src. Ported from that repository's
# scripts/check-role-contract.sh; the rules are the same, so a feature can move
# there unchanged. Two additions for features that live outside it:
#
#   * a feature may carry a second role (ansible-role-system) for work that
#     belongs in the privileged lane. It takes no parameters, so it must have
#     the variant and runner-contract asserts and NO parameter bracket.
#   * dependsOn is absolute: "./bootstrap" cannot resolve from this repo, so a
#     relative dependsOn is a violation here. installsAfter MAY name a sibling
#     in this collection as "./<id>" -- the devcontainer CLI fetches every
#     installsAfter reference, so an absolute one to a sibling that is not yet
#     published breaks the local test build. The release rewrites those to the
#     production namespace (features/scripts/rewrite-feature-refs.sh), and a
#     "./<id>" must name a directory that exists under features/src.
#
# The contract's whole value is that a missing or wrong parameter fails loudly and
# by name. That only holds while every role actually follows it, and a role copied
# from SKELETON can drift silently. This script is the thing that notices.
#
# Called by `make check-contract` and by the `contract` CI job. The logic lives
# here and only here: the templates repo duplicated an equivalent check between its
# Makefile and its workflow, and a file then escaped the check entirely.
#
# Pure bash + sed/grep/awk on purpose:
#   * devcontainer-feature.json is JSONC (it opens with // comments), so jq and yq
#     both refuse to parse it.
#   * the base image ships no python3 (Python is uv-managed), so a Python
#     dependency would work in CI and fail in the maintainer container.
#
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 1

FAILED=0
CHECKED=0

violation() { echo "VIOLATION: $*"; FAILED=1; }
ok()        { echo "OK: $*"; }

# Feature dirs that ship an Ansible role.
ROLES=()
for d in features/src/*/; do
    [ -d "${d}ansible-role-feature" ] && ROLES+=("${d%/}")
done
[ "${#ROLES[@]}" -gt 0 ] || { echo "VIOLATION: found no feature roles under features/src"; exit 1; }

# Strip // line comments so the JSONC option block can be read with grep/sed.
strip_jsonc() { sed 's://.*$::' "$1"; }

# Option ids declared in a devcontainer-feature.json.
options_of() {
    strip_jsonc "$1/devcontainer-feature.json" | awk '
        !seen && /"options"[[:space:]]*:/ { seen=1; depth=0; rest=substr($0, index($0,"options"))
            depth += gsub(/\{/,"{",rest); depth -= gsub(/\}/,"}",rest); depth-=1; next }
        seen {
            if (depth == 0 && match($0, /"[A-Za-z_][A-Za-z0-9_]*"[[:space:]]*:/)) {
                id = substr($0, RSTART+1); sub(/".*/, "", id); print id
            }
            depth += gsub(/\{/,"{"); depth += gsub(/\[/,"[")
            depth -= gsub(/\}/,"}"); depth -= gsub(/\]/,"]")
            if (depth < 0) exit
        }'
}

echo "== role contract =="
for r in "${ROLES[@]}"; do
    name="$(basename "$r")"
    role="$r/ansible-role-feature"
    tasks="$role/tasks/main.yml"
    CHECKED=$((CHECKED+1))

    # 1. defaults/main.yml must declare nothing. Role defaults are outranked by the
    #    extra-vars install.sh passes, so any key here is either dead code or a
    #    decoy that only wins when the wiring is already broken.
    if grep -qE '^[A-Za-z_]' "$role/defaults/main.yml" 2>/dev/null; then
        violation "$name: defaults/main.yml declares a variable (must be empty)"
    fi

    # 2. Both asserts must bracket the role.
    grep -q '_securedevcontainer_compatibility_list' "$tasks" \
      || violation "$name: missing the variant (bootstrap) assert"
    grep -q 'runner contract was satisfied' "$tasks" \
      || violation "$name: missing the runner-contract assert"

    # 3/4. Options, the parameter bracket, and install.sh must agree in BOTH
    #      directions -- this is what catches an option added without an assert,
    #      or a variable renamed on one side only.
    mapfile -t opts < <(options_of "$r")
    bracket_vars="$(sed -n '/Assert that every required role parameter was supplied/,/success_msg/p' "$tasks" \
                    | grep -oE '_[a-z0-9_]+ is defined' | awk '{print $1}' | sort -u)"
    passed_vars="$(grep -oE -- '-e "_[a-z0-9_]+=' "$r/install.sh" 2>/dev/null \
                    | sed 's/-e "//; s/=$//' | sort -u)"

    if [ "${#opts[@]}" -eq 0 ]; then
        grep -q 'required role parameter was supplied' "$tasks" \
          && violation "$name: declares no options but has a parameter-bracket assert"
    else
        grep -q 'required role parameter was supplied' "$tasks" \
          || violation "$name: declares ${#opts[@]} option(s) but has no parameter-bracket assert"
        for v in $passed_vars; do
            grep -qx "$v" <<<"$bracket_vars" \
              || violation "$name: install.sh passes -e $v but the parameter bracket never asserts it"
        done
        for v in $bracket_vars; do
            grep -qx "$v" <<<"$passed_vars" \
              || violation "$name: parameter bracket asserts $v but install.sh never passes it"
        done
    fi

    # 5. Every option must carry a default -- that default is the single source of truth.
    for o in "${opts[@]}"; do
        strip_jsonc "$r/devcontainer-feature.json" \
          | sed -n "/\"$o\"[[:space:]]*:/,/}/p" | grep -q '"default"' \
          || violation "$name: option '$o' has no default"
    done

    # 6. Mandatory options fail in the shell; only *_checksum may be empty.
    for o in "${opts[@]}"; do
        env_var="$(tr '[:lower:]' '[:upper:]' <<<"$o")"
        if [[ "$o" == *checksum* ]]; then
            grep -q "\${${env_var}:-" "$r/install.sh" 2>/dev/null \
              || violation "$name: checksum option '$o' should use \${${env_var}:-} (empty is legal)"
        else
            grep -q "\${${env_var}:?" "$r/install.sh" 2>/dev/null \
              || violation "$name: mandatory option '$o' has no \${${env_var}:?...} guard in install.sh"
        fi
    done

    # 7. Never mask a runner-injected variable. `_target_arch | default('amd64')`
    #    reads as defensive but converts a broken runner into an amd64 binary
    #    installed on arm64 that then passes its own amd64 checksum.
    if grep -nE '_target_(arch|user_home|username)[[:space:]]*\|[[:space:]]*default\(' \
         "$role"/*/main.yml 2>/dev/null | grep -v '^\s*#' | grep -q .; then
        violation "$name: masks a runner-injected variable with | default(...)"
    fi

    # 8. Every download is verified. The three tasks that fetch a checksums FILE
    #    are exempt: they are what verification is resolved from, so they cannot
    #    verify themselves.
    url_violations="$(awk -v n="$name" '
        /^- name:/ { task=$0; sub(/^- name: /,"",task) }
        /ansible\.builtin\.get_url:/ { inurl=1; has=0; next }
        inurl && /^[[:space:]]+checksum:/ { has=1 }
        inurl && (/^- name:/ || /^\.\.\./) {
            if (!has && task !~ /checksums file/) print n ": get_url without checksum: -> " task
            inurl=0
        }
        END { if (inurl && !has && task !~ /checksums file/) print n ": get_url without checksum: -> " task }
    ' "$tasks")"
    if [ -n "$url_violations" ]; then
        while IFS= read -r line; do violation "$line"; done <<<"$url_violations"
    fi

    # 9. Secondary roles (the privileged half of a two-lane feature) take no
    #    parameters: both asserts, empty defaults, no parameter bracket.
    for extra in "$r"/ansible-role-*/; do
        extra="${extra%/}"
        [ "$extra" = "$role" ] && continue
        ename="$name/$(basename "$extra")"
        grep -qE '^[A-Za-z_]' "$extra/defaults/main.yml" 2>/dev/null \
          && violation "$ename: defaults/main.yml declares a variable (must be empty)"
        grep -q '_securedevcontainer_compatibility_list' "$extra/tasks/main.yml" \
          || violation "$ename: missing the variant (bootstrap) assert"
        grep -q 'runner contract was satisfied' "$extra/tasks/main.yml" \
          || violation "$ename: missing the runner-contract assert"
        grep -q 'required role parameter was supplied' "$extra/tasks/main.yml" \
          && violation "$ename: a secondary role takes no parameters, but has a parameter bracket"
        grep -q -- "--role $(basename "$extra")" "$r/install.sh" \
          || violation "$ename: install.sh never runs this role"
    done

    # 10. dependsOn must be absolute and digest-pinned. "./bootstrap" resolves
    #     only inside trusted-devcontainer-features.
    deps="$(strip_jsonc "$r/devcontainer-feature.json" | sed -n '/"dependsOn"/,/}/p')"
    if grep -qE '"\./' <<<"$deps"; then
        violation "$name: dependsOn uses a relative ./ reference"
    fi
    if grep -oE '"ghcr\.io/[^"]+"' <<<"$deps" | grep -vqE '@sha256:[0-9a-f]{64}"$'; then
        violation "$name: dependsOn is not digest-pinned"
    fi

    # 11. A relative installsAfter must name a sibling that exists.
    for ref in $(strip_jsonc "$r/devcontainer-feature.json" | sed -n '/"installsAfter"/,/]/p' \
                   | grep -oE '"\./[a-z0-9-]+"' | tr -d '"' | sed 's|^\./||'); do
        [ -d "features/src/$ref" ] || violation "$name: installsAfter ./$ref names no feature under features/src"
    done

    ok "$name"
done

echo
if [ "$FAILED" -ne 0 ]; then
    echo "Role contract violated. See ADR-012 (Parameter contract)."
    echo "Fix: restore the invariant in the file(s) named above."
    exit 1
fi
echo "Role contract satisfied across $CHECKED roles."
