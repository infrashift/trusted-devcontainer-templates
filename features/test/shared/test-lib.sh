#!/usr/bin/env bash
set -euo pipefail
_PASS=0; _FAIL=0; _FAILURES=""
check() {
    local label="$1"; shift
    echo -n "  TEST: ${label}... "
    if output=$("$@" 2>&1); then echo "PASS"; _PASS=$((_PASS+1))
    else echo "FAIL"; echo "    Output: ${output}"; _FAIL=$((_FAIL+1)); _FAILURES="${_FAILURES}\n  - ${label}"; fi
}
# check_fails <label> <expected-substring> <cmd...>
#
# Asserts the command FAILS *and* that its output contains the expected text.
# Both halves matter: a negative test that only checks the exit code passes for
# the wrong reason the moment the failure moves somewhere else.
#
# Note check()/check_fails() run the command via "$@" with no shell, so pipelines
# and redirections must be wrapped in `bash -c`.
check_fails() {
    local label="$1" want="$2"; shift 2
    echo -n "  TEST: ${label}... "
    if output=$("$@" 2>&1); then
        echo "FAIL (command unexpectedly succeeded)"
        _FAIL=$((_FAIL+1)); _FAILURES="${_FAILURES}\n  - ${label} (did not fail)"
    elif [[ "${output}" != *"${want}"* ]]; then
        echo "FAIL (failed, but not with the expected message)"
        echo "    Wanted: ${want}"
        echo "    Output: ${output}"
        _FAIL=$((_FAIL+1)); _FAILURES="${_FAILURES}\n  - ${label} (wrong failure)"
    else
        echo "PASS"; _PASS=$((_PASS+1))
    fi
}

report_results() {
    echo ""; echo "Results: ${_PASS}/$((_PASS+_FAIL)) passed, ${_FAIL} failed"
    [ "${_FAIL}" -gt 0 ] && { echo -e "Failures:${_FAILURES}"; exit 1; }; exit 0
}
