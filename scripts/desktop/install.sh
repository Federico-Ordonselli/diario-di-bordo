#!/usr/bin/env bash
# Installa il collegamento nel menu applicazioni e sulla Scrivania.
set -eu
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
chmod +x "$ROOT/scripts/desktop/launch.sh"

entry() {
  cat <<EOF
[Desktop Entry]
Type=Application
Name=Diario KH
GenericName=Tracker Kingdom Hearts Final Mix
Comment=Diario 100% e sintesi di Kingdom Hearts Final Mix
Exec="$ROOT/scripts/desktop/launch.sh"
Icon=$ROOT/assets/branding/icon.svg
Terminal=false
Categories=Game;
Keywords=kingdom hearts;kh1;sintesi;checklist;
StartupWMClass=it.khdiario.app
EOF
}

APPS="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESK="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
mkdir -p "$APPS"
entry >"$APPS/kh-diario.desktop"
chmod +x "$APPS/kh-diario.desktop"
if [ -d "$DESK" ]; then
  entry >"$DESK/kh-diario.desktop"
  chmod +x "$DESK/kh-diario.desktop"
fi
command -v update-desktop-database >/dev/null && update-desktop-database "$APPS" 2>/dev/null || true
echo "Collegamento installato: $APPS/kh-diario.desktop${DESK:+ e $DESK/kh-diario.desktop}"
