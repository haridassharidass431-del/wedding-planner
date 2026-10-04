#!/usr/bin/env bash
set -Eeuo pipefail

FLUTTER_HOME="${FLUTTER_HOME:-/tmp/flutter}"
export PATH="${FLUTTER_HOME}/bin:${PATH}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found. Running install step..."
  bash ./scripts/install-flutter.sh
fi

flutter config --enable-web
flutter precache --web
flutter pub get
flutter build web --release

if [ ! -d "build/web" ]; then
  echo "Flutter build failed: build/web was not created"
  exit 1
fi

echo "Flutter web build output ready at build/web"
