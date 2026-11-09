#!/usr/bin/env bash
# Genera i runner dalla stessa versione dell'SDK utilizzata per compilare.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
command -v flutter >/dev/null || { echo 'Installa Flutter stable (>=3.35) e aggiungilo al PATH: https://docs.flutter.dev/install' >&2; exit 1; }
cd "$ROOT"
PLATFORMS="${1:-android,ios,linux,macos,windows}"
SCAFFOLD="$(mktemp -d "${TMPDIR:-/tmp}/kh-flutter-scaffold.XXXXXX")"
trap 'rm -rf "$SCAFFOLD"' EXIT
flutter create --no-pub --project-name kh_diario --org it.khdiario --platforms "$PLATFORMS" "$SCAFFOLD"
IFS=',' read -ra TARGETS <<< "$PLATFORMS"
for platform in "${TARGETS[@]}"; do
  case "$platform" in android|ios|linux|macos|windows) ;; *) echo "Piattaforma non supportata: $platform" >&2; exit 1 ;; esac
  if [ ! -d "$ROOT/$platform" ]; then cp -R "$SCAFFOLD/$platform" "$ROOT/$platform"; fi
done
# I selettori file macOS richiedono l'accesso ai file scelti dall'utente.
python3 "$ROOT/scripts/flutter/configure-platforms.py"
flutter pub get
echo 'Runner pronti. Esegui scripts/flutter/check.sh, poi flutter run -d linux.'
