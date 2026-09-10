#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-utils/test-utils.sh"

checkCommon

check "java is installed" command -v java
check "javac is installed" command -v javac
check "mvn is installed" command -v mvn
check "mvn runs against the JDK" mvn --version
check "gradle is installed" command -v gradle
check "gradle runs against the JDK" gradle --version

reportResults
