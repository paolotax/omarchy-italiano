#!/bin/bash
# Traduce in italiano le voci del menu Omarchy.
#
# Le traduzioni (solo label/title) sono in menu-it.jsonc accanto a questo script.
# Omarchy azzera i campi non indicati in un override, quindi per ogni voce copiamo
# la riga completa dal menu predefinito installato e sostituiamo solo label/title.
# Il risultato va tra due marcatori in ~/.config/omarchy/extensions/omarchy-menu.jsonc.
#
#   menu-it.sh          applica (o riapplica dopo un aggiornamento di Omarchy)
#   menu-it.sh --remove toglie le traduzioni e torna all'inglese

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
# Omarchy 4 è un pacchetto in /usr/share/omarchy; ~/.local/share/omarchy solo su vecchie installazioni
for dir in "${OMARCHY_PATH:-}" /usr/share/omarchy "$HOME/.local/share/omarchy"; do
  [[ -n $dir && -f $dir/default/omarchy/omarchy-menu.jsonc ]] && break
done
default_menu="$dir/default/omarchy/omarchy-menu.jsonc"
[[ -f $default_menu ]] || { echo "Menu predefinito di Omarchy non trovato" >&2; exit 1; }
user_menu="$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
begin="  // >>> omarchy-italiano — generato da menu-it.sh, non modificare tra i marcatori"
end="  // <<< omarchy-italiano"

mkdir -p "$(dirname "$user_menu")"
[[ -f $user_menu ]] || printf '{\n}\n' >"$user_menu"
cp "$user_menu" "$user_menu.bak-italiano"

python3 - "$here/menu-it.jsonc" "$default_menu" "$user_menu" "$begin" "$end" "${1:-}" <<'PY'
import json, re, sys

translations_path, default_path, user_path, begin, end, mode = sys.argv[1:]
entry = re.compile(r'^\s*"([^"]+)":\s*(\{.*\})\s*,?\s*$')

def entries(path):
    out = {}
    for line in open(path, encoding="utf-8"):
        m = entry.match(line)
        if m:
            out[m.group(1)] = json.loads(m.group(2))
    return out

# Toglie un eventuale blocco precedente
text = open(user_path, encoding="utf-8").read()
# (riconosce anche i marcatori delle versioni precedenti, che citavano il percorso)
text = re.sub(r"\n?  // >>> omarchy-italiano[^\n]*.*?" + re.escape(end) + r"\n?", "\n", text, flags=re.S)

if mode != "--remove":
    defaults = entries(default_path)
    lines, missing = [begin], []
    for id, tr in entries(translations_path).items():
        if id not in defaults:
            missing.append(id)
            continue
        item = dict(defaults[id])
        item.update(tr)
        lines.append(f'  "{id}": {json.dumps(item, ensure_ascii=False, separators=(",", ":"))},')
    lines.append(end)
    text = text.replace("{", "{\n" + "\n".join(lines), 1)
    print(f"Tradotte {len(lines) - 2} voci.")
    if missing:
        print("Voci non più presenti in Omarchy (ignorate):", ", ".join(missing))
else:
    print("Traduzioni rimosse.")

text = re.sub(r"\{\n\n+", "{\n", text)
open(user_path, "w", encoding="utf-8").write(text)
PY
