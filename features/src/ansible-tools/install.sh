#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# ansible-tools-feature/install.sh
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Maintainer: infrashift.sh
#
# Thin wrapper. All installation logic lives in ansible-role-feature/.
# The shared runner is provided by the 'bootstrap' feature (see dependsOn).
set -euo pipefail

# Fail in the shell when a mandatory option resolves empty. Never add a
# `:-fallback` here — that would reintroduce the second source of truth this
# design removes.
: "${ANSIBLE_LINT_VERSION:?feature option 'ansible_lint_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${PYTHON_VERSION:?feature option 'python_version' resolved empty — devcontainer-feature.json must declare a default}"

exec /opt/bootstrap/run-feature.sh \
    --role ansible-role-feature \
    -e "_ansible_lint_version=${ANSIBLE_LINT_VERSION}" \
    -e "_anstools_python_version=${PYTHON_VERSION}"
