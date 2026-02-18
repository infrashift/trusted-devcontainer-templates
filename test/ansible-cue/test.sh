#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

check "ansible is installed" command -v ansible
check "ansible-playbook is installed" command -v ansible-playbook
check "python3 is installed" command -v python3
check "cue is installed" command -v cue

reportResults
