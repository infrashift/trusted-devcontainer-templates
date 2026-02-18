#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

check "dotnet is installed" command -v dotnet
check "node is installed" command -v node
check "npm is installed" command -v npm
check "pnpm is installed" command -v pnpm

reportResults
