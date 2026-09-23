#!/bin/bash
# Fa tutto in un colpo: lingua di sistema, pacchetti italiani, menu e barra
# di Omarchy in italiano. Si può rilanciare quante volte si vuole (anche dopo
# un aggiornamento di Omarchy): rifà solo quello che manca.
#
#   italiano.sh           attiva l'italiano
#   italiano.sh --remove  torna all'inglese
#
# Va lanciato dentro la sessione grafica (serve la barra attiva) e chiede la
# password per i comandi sudo.

set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

if [[ ${1:-} == --remove ]]; then
  "$here/menu-it.sh" --remove
  "$here/plugin-it.sh" --remove
  "$here/keybindings-it.sh" --remove
  "$here/notifiche-it.sh" --remove
  sudo localectl set-locale LANG=en_US.UTF-8
  echo
  echo "Inglese impostato. Esci e rientra per applicare tutto."
  exit 0
fi

sudo sed -i 's/^#it_IT.UTF-8/it_IT.UTF-8/' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=it_IT.UTF-8

# Correttore ortografico, sillabazione e sinonimi (LibreOffice e altri)
packages=(hunspell-it hyphen-it mythes-it)
# Interfaccia di LibreOffice (fresh o still, quello installato)
for lo in libreoffice-fresh libreoffice-still; do
  pacman -Q "$lo" &>/dev/null && packages+=("$lo-it")
done
sudo pacman -S --needed --noconfirm "${packages[@]}"

"$here/menu-it.sh"
"$here/plugin-it.sh"
"$here/keybindings-it.sh"
"$here/notifiche-it.sh"
echo
echo "Fatto. Menu (Super+Alt+Space), barra e scorciatoie (Super+K) sono gia' in italiano."
echo "Esci e rientra (o riavvia) per il resto del sistema."
