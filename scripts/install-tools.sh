#!/usr/bin/env bash
# Install pipeline tools at the versions pinned in tools.lock.
#
# Usage: scripts/install-tools.sh opa syft grype gitleaks devcontainer-cli
#
# Never install from an unpinned `latest` URL or a floating action ref. Several
# of these binaries run in the same job as the cosign signing key, so a mutable
# download is a code-execution path into the most privileged step in the
# pipeline. Where upstream publishes a checksum we verify it; where it does not,
# the version is still pinned and that is stated rather than left implied.
set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/../tools.lock"

BIN="${BIN:-/usr/local/bin}"
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)        GOARCH=amd64 ;;
  aarch64|arm64) GOARCH=arm64 ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac

# Checksums are keyed by version AND arch. An unpinned pair fails by name rather
# than silently skipping verification -- the same rule the feature roles follow
# for their downloads.
sha_for() {
  local key="$1"
  case "$key" in
    opa:v1.19.1:amd64)      echo c9f985ce0d345f5484006ade2c695ed9e3f308e4441139e46695c5c182ac0839 ;;
    opa:v1.19.1:arm64)      echo 19dcb5186fd394c32023918c53eaacda55f835abb05e13e0f9a766dd1429494f ;;
    gitleaks:v8.30.1:amd64) echo 551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb ;;
    gitleaks:v8.30.1:arm64) echo e4a487ee7ccd7d3a7f7ec08657610aa3606637dab924210b3aee62570fb4b080 ;;
    *) echo "no pinned checksum for ${key}" >&2; return 1 ;;
  esac
}

verify() {
  local file="$1" key="$2" want got
  want="$(sha_for "$key")" || {
    echo "::error::refusing to install ${key} without a pinned checksum" >&2
    exit 1
  }
  got="$(sha256sum "$file" | cut -d' ' -f1)"
  if [ "$want" != "$got" ]; then
    echo "::error::checksum mismatch for ${key}: want ${want}, got ${got}" >&2
    exit 1
  fi
}

install_opa() {
  local tmp; tmp=$(mktemp -d)
  curl -sSfL --retry 3 -o "$tmp/opa" \
    "https://github.com/open-policy-agent/opa/releases/download/${OPA_VERSION}/opa_linux_${GOARCH}_static"
  verify "$tmp/opa" "opa:${OPA_VERSION}:${GOARCH}"
  install -m 0755 "$tmp/opa" "$BIN/opa"
  rm -rf "$tmp"
  opa version
}

install_gitleaks() {
  local tmp arch; tmp=$(mktemp -d)
  # gitleaks names its 64-bit x86 asset x64, not amd64. arm64 matches.
  case "$GOARCH" in amd64) arch=x64 ;; *) arch="$GOARCH" ;; esac
  curl -sSfL --retry 3 -o "$tmp/g.tar.gz" \
    "https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION#v}_linux_${arch}.tar.gz"
  verify "$tmp/g.tar.gz" "gitleaks:${GITLEAKS_VERSION}:${GOARCH}"
  tar -xzf "$tmp/g.tar.gz" -C "$tmp" gitleaks
  install -m 0755 "$tmp/gitleaks" "$BIN/gitleaks"
  rm -rf "$tmp"
  gitleaks version
}

# syft and grype ship an installer that verifies the release checksum itself,
# fetched at the pinned tag rather than from main. This replaces
# anchore/sbom-action@v0 and anchore/scan-action@v6, both floating major refs.
install_syft() {
  curl -sSfL "https://raw.githubusercontent.com/anchore/syft/${SYFT_VERSION}/install.sh" \
    | sh -s -- -b "$BIN" "${SYFT_VERSION#v}"
  syft version
}

install_grype() {
  curl -sSfL "https://raw.githubusercontent.com/anchore/grype/${GRYPE_VERSION}/install.sh" \
    | sh -s -- -b "$BIN" "${GRYPE_VERSION#v}"
  grype version
}

install_devcontainer_cli() {
  npm install -g "@devcontainers/cli@${DEVCONTAINER_CLI_VERSION}"
  devcontainer --version
}

for tool in "$@"; do
  echo "::group::install $tool"
  case "$tool" in
    devcontainer-cli) install_devcontainer_cli ;;
    *)                "install_${tool}" ;;
  esac
  echo "::endgroup::"
done
