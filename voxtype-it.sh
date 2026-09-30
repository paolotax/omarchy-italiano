#!/bin/bash
# Mette la dettatura vocale (Voxtype) in italiano.
#
# Il modello predefinito di Omarchy (Whisper base.en) capisce solo l'inglese.
# Lo script passa al motore Parakeet v3 (multilingue, riconosce da solo la
# lingua): senza GPU è molto più veloce di Whisper con un modello multilingue
# (su un i5 del 2013 circa 1 secondo invece di 10). Serve la versione ONNX di
# Voxtype, che si attiva con sudo, e il modello int8 (circa 650 MB).
# Se Voxtype non è installato non fa niente: rilancialo dopo averlo installato.
#
#   voxtype-it.sh          applica
#   voxtype-it.sh --remove torna a Whisper in inglese

set -euo pipefail

model=parakeet-tdt-0.6b-v3-int8

if ! command -v voxtype &>/dev/null || [[ ! -f $HOME/.config/voxtype/config.toml ]]; then
  echo "Voxtype non installato, salto la dettatura."
  exit 0
fi

onnx_active() { voxtype info variants 2>/dev/null | grep -q '^ *Next launch: *ONNX'; }

if [[ ${1:-} == --remove ]]; then
  voxtype config set engine whisper >/dev/null
  onnx_active && sudo voxtype setup onnx --disable
else
  onnx_active || sudo voxtype setup onnx --enable
  [[ -d $HOME/.local/share/voxtype/models/$model ]] ||
    voxtype setup --download --model "$model" --no-post-install
  voxtype config set engine parakeet >/dev/null
  voxtype config set parakeet.model "$model" >/dev/null
fi

systemctl --user try-restart voxtype 2>/dev/null || true
