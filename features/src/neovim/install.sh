#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# neovim-feature/install.sh
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Maintainer: infrashift.sh
#
# Thin wrapper. All installation logic lives in ansible-role-feature/.
# The shared runner is provided by the 'bootstrap' feature (see dependsOn).
set -euo pipefail

# Fail in the shell when a mandatory option resolves empty: the role's assert
# cannot tell "unset" from "empty string", and an empty version silently builds
# a malformed download URL. Never add a `:-fallback` here — that would
# reintroduce the second source of truth this design removes.
#
# target_checksum is legitimately empty (empty means "use the pinned map"), so
# it keeps :- rather than :?.
: "${TARGET_VERSION:?feature option 'target_version' resolved empty — devcontainer-feature.json must declare a default}"

exec /opt/bootstrap/run-feature.sh \
    --role ansible-role-feature \
    -e "_nvim_version=${TARGET_VERSION}" \
    -e "_nvim_checksum=${TARGET_CHECKSUM:-}"
