#!/bin/bash

# Test utility functions for devcontainer template tests

_PASS=0
_FAIL=0
_RESULTS=()

# check <label> <command...>
# Run a command and record pass/fail
check() {
    local label="$1"
    shift
    if "$@" > /dev/null 2>&1; then
        _PASS=$((_PASS + 1))
        _RESULTS+=("PASS: ${label}")
    else
        _FAIL=$((_FAIL + 1))
        _RESULTS+=("FAIL: ${label}")
    fi
}

# checkCommon
# Verify common expectations shared across all templates
checkCommon() {
    check "user is dev" test "$(whoami)" = "dev"
    check "uid is 1001" test "$(id -u)" = "1001"
    check "gid is 1001" test "$(id -g)" = "1001"
    check "git is installed" command -v git
    check "git-lfs is installed" command -v git-lfs
    check "grype is installed" command -v grype
    check "syft is installed" command -v syft
    check "jq is installed" command -v jq
    check "yq is installed" command -v yq
    check "uv is installed" command -v uv
}

# reportResults
# Print results and exit with appropriate code
reportResults() {
    echo ""
    echo "=== Test Results ==="
    for r in "${_RESULTS[@]}"; do
        echo "  ${r}"
    done
    echo ""
    echo "Passed: ${_PASS}  Failed: ${_FAIL}"

    if [ "${_FAIL}" -gt 0 ]; then
        exit 1
    fi
    exit 0
}
