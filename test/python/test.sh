#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

# The python feature installs into uv's MANAGED store, not onto PATH, so
# `command -v python3` asserts something the feature never promised -- and the
# shared base ships no python at all. `uv python find` is the contract the
# feature repo's own tests use; matching it keeps one definition of "installed"
# across both repos.
check "python 3.13 is installed" uv python find 3.13
check "ruff is installed" command -v ruff

reportResults
