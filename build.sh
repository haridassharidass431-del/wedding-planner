#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "Build failed at line $LINENO: $BASH_COMMAND" >&2' ERR

FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
export PATH="$FLUTTER_HOME/bin:$PATH"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found. Installing the stable Flutter SDK..."
  if [ -e "$FLUTTER_HOME" ]; then
    echo "Flutter install location exists but is not usable: $FLUTTER_HOME" >&2
    exit 1
  fi
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter installation failed: flutter is not available on PATH" >&2
  exit 1
fi

echo "Using Flutter: $(flutter --version | head -n 1)"
flutter config --enable-web
flutter precache --web
flutter pub get
flutter build web --release

if [ ! -d "build/web" ]; then
  echo "Flutter build failed: build/web was not created" >&2
  exit 1
fi

rm -rf dist
mkdir -p dist
cp -R build/web/. dist/

echo "Flutter web output copied to dist/"
