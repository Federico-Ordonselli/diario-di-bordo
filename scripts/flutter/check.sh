#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."
command -v flutter >/dev/null || { echo 'Flutter SDK non disponibile: impossibile eseguire analyze/test/build.' >&2; exit 1; }
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build linux --release
