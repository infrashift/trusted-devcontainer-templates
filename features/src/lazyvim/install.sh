#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# lazyvim-feature/install.sh
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Maintainer: infrashift.sh
#
# Thin wrapper. All installation logic lives in the two roles.
# The shared runner is provided by the 'bootstrap' feature (see dependsOn).
#
# This is the one feature in the collection that runs the runner twice, because
# its work spans both lanes:
#
#   ansible-role-system   --privileged  system packages (gcc, git, ripgrep, fd)
#   ansible-role-feature  userland      config, plugins, parsers, CLIs in $HOME
#
# Splitting the roles keeps each lane honest: nothing in $HOME is written as
# root, and nothing under /usr is written by the account being provisioned.
set -euo pipefail

# Fail in the shell when a mandatory option resolves empty. Never add a
# `:-fallback` here — that would reintroduce the second source of truth this
# design removes. The *_checksum options are legitimately empty (empty means
# "use the pinned map"), so they keep :- rather than :?.
: "${TREE_SITTER_VERSION:?feature option 'tree_sitter_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${STYLUA_VERSION:?feature option 'stylua_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${SHFMT_VERSION:?feature option 'shfmt_version' resolved empty — devcontainer-feature.json must declare a default}"

/opt/bootstrap/run-feature.sh \
    --role ansible-role-system \
    --privileged

exec /opt/bootstrap/run-feature.sh \
    --role ansible-role-feature \
    -e "_tree_sitter_version=${TREE_SITTER_VERSION}" \
    -e "_tree_sitter_checksum=${TREE_SITTER_CHECKSUM:-}" \
    -e "_stylua_version=${STYLUA_VERSION}" \
    -e "_stylua_checksum=${STYLUA_CHECKSUM:-}" \
    -e "_shfmt_version=${SHFMT_VERSION}" \
    -e "_shfmt_checksum=${SHFMT_CHECKSUM:-}"
