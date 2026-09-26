#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# java-tools-feature/install.sh
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
#
# The checksums are legitimately empty (empty means "use the pinned map"), so
# they keep :- rather than :?.
: "${JDTLS_VERSION:?feature option 'jdtls_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${JDTLS_BUILD:?feature option 'jdtls_build' resolved empty — devcontainer-feature.json must declare a default}"
: "${LOMBOK_VERSION:?feature option 'lombok_version' resolved empty — devcontainer-feature.json must declare a default}"

exec /opt/bootstrap/run-feature.sh \
    --role ansible-role-feature \
    -e "_jdtls_version=${JDTLS_VERSION}" \
    -e "_jdtls_build=${JDTLS_BUILD}" \
    -e "_jdtls_checksum=${JDTLS_CHECKSUM:-}" \
    -e "_lombok_version=${LOMBOK_VERSION}" \
    -e "_lombok_checksum=${LOMBOK_CHECKSUM:-}"
