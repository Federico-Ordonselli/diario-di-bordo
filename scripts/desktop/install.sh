#!/usr/bin/env bash
# Installa il collegamento nel menu applicazioni e sulla Scrivania.
set -eu
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
chmod +x "$ROOT/scripts/desktop/launch.sh"

entry() {
  cat <<EOF
[Desktop Entry]
Type=Application
Name=Diario di Bordo
GenericName=Tracker di completamento
Comment=Diario 100% e sintesi (tracker non ufficiale)
Exec="$ROOT/scripts/desktop/launch.sh"
Icon=$ROOT/assets/branding/icon.svg
Terminal=false
Categories=Game;
Keywords=diario;tracker;sintesi;checklist;
StartupWMClass=io.github.federicoordonselli.diariobordo
EOF
}

APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESK="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
mkdir -p "$APPS"
entry >"$APPS/diario-bordo.desktop"
chmod +x "$APPS/diario-bordo.desktop"
if [ -d "$DESK" ]; then
  entry >"$DESK/diario-bordo.desktop"
  chmod +x "$DESK/diario-bordo.desktop"
fi
command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" 2>/dev/null || true
echo "Collegamento installato: $APPS/diario-bordo.desktop${DESK:+ e $DESK/diario-bordo.desktop}"
