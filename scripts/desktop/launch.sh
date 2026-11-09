#!/usr/bin/env bash
# App Flutter nativa, dati della precedente app mantenuti in data/.
set -euo pipefail
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
export KH_DATA_DIR="${KH_DATA_DIR:-$ROOT/data}"
BINARY="$ROOT/build/linux/x64/release/bundle/diario_bordo"
if [ ! -x "$BINARY" ]; then
  echo 'Build Flutter assente. Esegui scripts/flutter/bootstrap.sh e flutter build linux --release.' >&2
  command -v notify-send >/dev/null && notify-send 'Diario di Bordo' 'Compila prima la versione Flutter: flutter build linux --release.' || true
  exit 1
fi
exec "$BINARY"
