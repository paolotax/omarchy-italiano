#!/bin/bash
# Traduce in italiano i plugin della barra di Omarchy (orologio/calendario,
# rete, batteria, bluetooth, meteo, audio, schermo).
#
# La shell di Omarchy non ha traduzioni: i testi sono scritti nel codice.
# Per ogni plugin elencato in plugin-it.json lo script:
#   1. lo clona in ~/.config/omarchy/plugins/ (omarchy plugin clone), oppure,
#      se il clone esiste già, lo riallinea alla versione installata di Omarchy
#      (eventuali modifiche fatte a mano nel clone vengono sovrascritte);
#   2. sostituisce i testi inglesi con quelli italiani.
# Imposta anche l'orologio della barra a 24 ore.
#
#   plugin-it.sh          applica (o riapplica dopo un aggiornamento di Omarchy)
#   plugin-it.sh --remove torna ai plugin originali di Omarchy

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
for dir in "${OMARCHY_PATH:-}" /usr/share/omarchy "$HOME/.local/share/omarchy"; do
  [[ -n $dir && -d $dir/shell/plugins ]] && break
done
[[ -d $dir/shell/plugins ]] || { echo "Plugin di Omarchy non trovati" >&2; exit 1; }

python3 - "$here/plugin-it.json" "$dir/shell/plugins" "$HOME/.config/omarchy" "${1:-}" <<'PY'
import glob, json, os, shutil, subprocess, sys, time

translations_path, builtin_root, config, mode = sys.argv[1:]
translations = {k: v for k, v in json.load(open(translations_path, encoding="utf-8")).items() if not k.startswith("_")}
plugins_dir = os.path.join(config, "plugins")
shell_json = os.path.join(config, "shell.json")

def manifest(path):
    try:
        return json.load(open(os.path.join(path, "manifest.json"), encoding="utf-8"))
    except (OSError, ValueError):
        return {}

def builtin_dir(id):
    for m in glob.glob(os.path.join(builtin_root, "**", "manifest.json"), recursive=True):
        if manifest(os.path.dirname(m)).get("id") == id:
            return os.path.dirname(m)

def clone_dir(id):
    for d in sorted(glob.glob(os.path.join(plugins_dir, "*"))):
        if (manifest(d).get("omarchy") or {}).get("clonedFrom") == id:
            return d

def wait_shell():
    # Ogni clone fa riscansionare i plugin alla barra: se la incalziamo
    # smette di rispondere e il clone successivo fallisce.
    for _ in range(60):
        if subprocess.run(["omarchy-shell", "shell", "ping"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
            return
        time.sleep(0.5)
    sys.exit("La barra di Omarchy non risponde: lancia lo script dentro la sessione grafica")

def clone(id):
    for attempt in range(3):
        wait_shell()
        if subprocess.run(["omarchy", "plugin", "clone", id], stdout=subprocess.DEVNULL).returncode == 0:
            return clone_dir(id)
        time.sleep(2)
    sys.exit(f"{id}: clone non riuscito")

def edit_shell(fn):
    data = json.load(open(shell_json, encoding="utf-8"))
    for section in data.get("bar", {}).get("layout", {}).values():
        for widget in section:
            fn(widget)
    with open(shell_json, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")

if mode == "--remove":
    for id in translations:
        d = clone_dir(id)
        if not d:
            continue
        clone_id = manifest(d)["id"]
        edit_shell(lambda w: w.update(id=id) if w.get("id") == clone_id else None)
        shutil.rmtree(d)
        print(f"{id}: ripristinato l'originale")
    sys.exit()

for id, files in translations.items():
    src = builtin_dir(id)
    if not src:
        print(f"{id}: non più presente in Omarchy, saltato")
        continue
    d = clone_dir(id)
    if d:
        # Riallinea il clone alla versione installata, tenendo il suo manifest
        for name in os.listdir(src):
            if name == "manifest.json":
                continue
            s, t = os.path.join(src, name), os.path.join(d, name)
            if os.path.isdir(s):
                shutil.copytree(s, t, dirs_exist_ok=True)
            else:
                shutil.copy2(s, t)
    else:
        d = clone(id)

    done, missing = 0, []
    for name, pairs in files.items():
        path = os.path.join(d, name)
        text = open(path, encoding="utf-8").read()
        for old, new in pairs:
            if old in text:
                text = text.replace(old, new)
                done += 1
            elif new not in text:
                missing.append(old)
        open(path, "w", encoding="utf-8").write(text)
    print(f"{id}: {done} testi tradotti")
    for old in missing:
        print(f"   non trovato (forse cambiato in Omarchy): {old}")

def clock_24h(w):
    if w.get("id", "").endswith(".clock"):
        w["format"] = "dddd HH:mm"
        w["formatAlt"] = "d MMMM 'S'ww yyyy"
edit_shell(clock_24h)
PY

# La barra non rilegge da sola i file dei plugin: riavviala per vedere le modifiche
omarchy-restart-shell >/dev/null || echo "Riavvia la barra con: omarchy-restart-shell"
