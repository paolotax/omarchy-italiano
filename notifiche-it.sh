#!/bin/bash
# Notifiche di Omarchy in italiano.
# Mette la cartella bin/ di questo kit davanti a quella di Omarchy nel PATH,
# sia della sessione grafica sia dei terminali: cosi' il nostro
# omarchy-notification-send (che traduce i testi e poi chiama quello vero)
# viene usato da tutti i comandi di Omarchy.
#
#   notifiche-it.sh           attiva
#   notifiche-it.sh --remove  torna alle notifiche originali
#
# Richiede logout/login (o riavvio): il PATH della sessione si legge all'avvio.

set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
# Il nome deve venire dopo gli env.d di Omarchy, che mettono i suoi bin nel PATH
# ~/.config/uwsm/default e' l'ultimo file letto da /usr/share/uwsm/env.d/10-omarchy,
# quindi la nostra cartella resta davanti a quella di Omarchy (gli env.d utente
# vengono letti PRIMA, e verrebbero scavalcati).
envfile="$HOME/.config/uwsm/default"
oldenvfile="$HOME/.config/uwsm/env.d/99-zz-omarchy-italiano"
bashrc="$HOME/.bashrc"
begin="# >>> omarchy-italiano: notifiche e messaggi"
end="# <<< omarchy-italiano"

# Toglie l'eventuale blocco precedente da .bashrc
strip_block() {
  [[ -f $1 ]] || return 0
  sed -i "\|^${begin}$|,\|^${end}$|d" "$1"
}

rm -f "$oldenvfile"   # versione precedente del kit

if [[ ${1:-} == --remove ]]; then
  strip_block "$envfile"
  strip_block "$bashrc"
  echo "Notifiche originali ripristinate. Esci e rientra per applicare."
  exit 0
fi

mkdir -p "$(dirname "$envfile")"
strip_block "$envfile"
cat >> "$envfile" <<ENV
$begin
export PATH="$here/bin:\$PATH"
$end
ENV

strip_block "$bashrc"
cat >> "$bashrc" <<BRC
$begin
export PATH="$here/bin:\$PATH"
$end
BRC

echo "Notifiche in italiano attivate. Esci e rientra (o riavvia) per applicare."
