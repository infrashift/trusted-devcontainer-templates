#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

check "dotnet is installed" command -v dotnet
check "node is installed" command -v node
check "npm is installed" command -v npm
# nodejs 1.6.0 replaces its bundled npm (npm_version, default 12.2.1); the
# separate, now-deprecated npm feature is no longer part of this template.
check "npm is 12.2.1" bash -c '[ "$(npm --version)" = "12.2.1" ]'
check "pnpm is installed" command -v pnpm

reportResults
