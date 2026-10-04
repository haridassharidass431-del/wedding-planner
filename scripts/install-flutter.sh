#!/usr/bin/env bash
set -Eeuo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.5}"
FLUTTER_HOME="${FLUTTER_HOME:-/tmp/flutter}"
export PATH="${FLUTTER_HOME}/bin:${PATH}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter SDK ${FLUTTER_VERSION}..."
  mkdir -p /tmp
  curl -L --fail "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o /tmp/flutter.tar.xz
  rm -rf "${FLUTTER_HOME}"
  tar -xJf /tmp/flutter.tar.xz -C /tmp
fi

flutter --version
