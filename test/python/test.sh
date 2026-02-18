#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

check "python3 is installed" command -v python3
check "ruff is installed" command -v ruff

reportResults
