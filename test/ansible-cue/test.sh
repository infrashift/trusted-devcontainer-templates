#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

check "ansible is installed" command -v ansible
check "ansible-playbook is installed" command -v ansible-playbook
# The python feature installs CPython into uv's managed store AND puts the
# versioned executable, ~/.local/bin/python3.14, on the PATH (1.7.1). `uv python
# find` alone is not enough: it passed on a 1.7.0 image that had the interpreter
# and no executable, because uv-ruff's tool install had fetched it first
# (trusted-devcontainer-features#22). The shared base ships no python at all.
check "python 3.14 is installed" uv python find 3.14
check "python3.14 is on the PATH" python3.14 --version
check "cue is installed" command -v cue

reportResults
