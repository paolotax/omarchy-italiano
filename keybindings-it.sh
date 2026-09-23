#!/bin/bash
# Super+K (elenco scorciatoie) in italiano.
# Aggiunge in ~/.config/hypr/bindings.lua un blocco che fa aprire a Super+K
# omarchy-menu-keybindings-it (che traduce con keybindings-it.tsv).
#
#   keybindings-it.sh           attiva
#   keybindings-it.sh --remove  torna al Super+K originale

set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
conf="$HOME/.config/hypr/bindings.lua"
begin="-- >>> omarchy-italiano: Super+K in italiano"
end="-- <<< omarchy-italiano"

[[ -f $conf ]] || { echo "Non trovo $conf" >&2; exit 1; }

# Toglie l'eventuale blocco precedente
python3 - "$conf" "$begin" "$end" <<'PY'
import sys, re
path, b, e = sys.argv[1:]
text = open(path, encoding="utf-8").read()
text = re.sub(r"\n?" + re.escape(b) + r".*?" + re.escape(e) + r"\n?", "\n", text, flags=re.S)
open(path, "w", encoding="utf-8").write(text.rstrip("\n") + "\n")
PY

if [[ ${1:-} != --remove ]]; then
  # Percorso scritto relativo a HOME, cosi' funziona anche con utenti diversi
  rel=${here#"$HOME"/}
  cat >> "$conf" <<LUA

$begin
hl.unbind("SUPER + K")
o.bind("SUPER + K", "Keybindings", os.getenv("HOME") .. "/$rel/omarchy-menu-keybindings-it")
$end
LUA
  echo "Super+K ora apre le scorciatoie in italiano."
else
  echo "Super+K ripristinato."
fi

if command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1; then
  errors=$(hyprctl configerrors 2>/dev/null | grep -v '^$' || true)
  [[ -z $errors || $errors == "no errors" ]] || echo "Attenzione, errori nella config di Hyprland: $errors"
fi
