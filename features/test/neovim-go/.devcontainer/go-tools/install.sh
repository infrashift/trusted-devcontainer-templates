#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# go-tools-feature/install.sh
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
# golangci_lint_checksum is legitimately empty (empty means "use the pinned
# map"), so it keeps :- rather than :?.
: "${GOPLS_VERSION:?feature option 'gopls_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${GOFUMPT_VERSION:?feature option 'gofumpt_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${GOIMPORTS_VERSION:?feature option 'goimports_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${GOMODIFYTAGS_VERSION:?feature option 'gomodifytags_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${IMPL_VERSION:?feature option 'impl_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${DELVE_VERSION:?feature option 'delve_version' resolved empty — devcontainer-feature.json must declare a default}"
: "${GOLANGCI_LINT_VERSION:?feature option 'golangci_lint_version' resolved empty — devcontainer-feature.json must declare a default}"

exec /opt/bootstrap/run-feature.sh \
    --role ansible-role-feature \
    -e "_gopls_version=${GOPLS_VERSION}" \
    -e "_gofumpt_version=${GOFUMPT_VERSION}" \
    -e "_goimports_version=${GOIMPORTS_VERSION}" \
    -e "_gomodifytags_version=${GOMODIFYTAGS_VERSION}" \
    -e "_impl_version=${IMPL_VERSION}" \
    -e "_delve_version=${DELVE_VERSION}" \
    -e "_golangci_lint_version=${GOLANGCI_LINT_VERSION}" \
    -e "_golangci_lint_checksum=${GOLANGCI_LINT_CHECKSUM:-}"
