# omarchy-italiano

Italian localization kit for [Omarchy](https://omarchy.org): system locale,
Omarchy menu, top bar panels, keybindings list (Super+K), notifications and
on-screen messages. It also installs the Italian spell checker, hyphenation
and thesaurus, plus the Italian LibreOffice UI when LibreOffice is installed.

Omarchy has no built-in translation system. This kit works through user
overrides, so it never touches Omarchy's own files, and it can be re-applied
after updates or removed completely.

```bash
git clone https://github.com/paolotax/omarchy-italiano ~/.local/share/omarchy-italiano
~/.local/share/omarchy-italiano/italiano.sh
```

The rest of this README is in Italian.

---

## Cosa traduce

| Parte | Script | Dizionario |
|---|---|---|
| Lingua di sistema (`it_IT.UTF-8`) e pacchetti italiani | `italiano.sh` | — |
| Menu di Omarchy (Super+Alt+Space) | `menu-it.sh` | `menu-it.jsonc` |
| Pannelli della barra (orologio a 24 ore, rete, batteria, bluetooth, meteo, audio, schermo) | `plugin-it.sh` | `plugin-it.json` |
| Elenco scorciatoie (Super+K) | `keybindings-it.sh` | `keybindings-it.tsv` |
| Notifiche e messaggi a schermo (OSD) di Omarchy | `notifiche-it.sh` | `notifiche-it.tsv`, `notifiche-it.sed` |

`italiano.sh` lancia tutti gli altri script. Ognuno si può anche usare da solo,
e con `--remove` si toglie.

## Requisiti

- Omarchy 4 (pacchetto in `/usr/share/omarchy`). Le installazioni più vecchie
  in `~/.local/share/omarchy` dovrebbero funzionare, ma non sono testate.
- `python3` e `git`, già presenti in Omarchy.

## Installazione

Apri un terminale (Super+Invio) **dentro la sessione grafica**, perché la barra
deve essere attiva, e lancia:

```bash
git clone https://github.com/paolotax/omarchy-italiano ~/.local/share/omarchy-italiano
~/.local/share/omarchy-italiano/italiano.sh
```

Lo script chiede la password per i comandi `sudo`: genera il locale e installa
`hunspell-it`, `hyphen-it`, `mythes-it` e il pacchetto italiano di LibreOffice.
Alla fine esci e rientra, oppure riavvia.

> Lascia la cartella dove l'hai clonata: Super+K e le notifiche usano gli
> script direttamente da lì.

Per controllare: `locale` deve mostrare `LANG=it_IT.UTF-8` e `date` deve dare
la data in italiano.

## Aggiornare

Dopo un aggiornamento di Omarchy, o per avere le traduzioni nuove:

```bash
cd ~/.local/share/omarchy-italiano && git pull && ./italiano.sh
```

Lo script si può rilanciare quante volte vuoi: rifà solo quello che manca. Le
voci di menu che non esistono più in Omarchy vengono ignorate e segnalate.

## Disinstallare

```bash
~/.local/share/omarchy-italiano/italiano.sh --remove
```

Poi esci e rientra. Il locale torna a `en_US.UTF-8`. I pacchetti italiani
restano installati e non danno fastidio.

## Come funziona

Omarchy non ha un sistema di traduzioni, perché i testi sono scritti nel
codice. Il kit usa solo i punti di personalizzazione dell'utente, e ogni
modifica sta tra due marcatori `omarchy-italiano`, così `--remove` la toglie in
modo pulito:

- **menu**: override in `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Per
  ogni voce copia la riga completa dal menu predefinito e cambia solo
  label/title.
- **barra**: clona i plugin in `~/.config/omarchy/plugins/` con
  `omarchy plugin clone` e ne sostituisce i testi.
- **Super+K**: nuovo binding in `~/.config/hypr/bindings.lua`, che traduce
  l'elenco al volo.
- **notifiche**: mette `bin/` davanti nel `PATH` (in `~/.config/uwsm/default` e
  in `~/.bashrc`). I wrapper `omarchy-notification-send` e `omarchy-osd`
  traducono il testo e poi chiamano il comando originale.

## Contribuire

Se trovi una scritta ancora in inglese, apri una issue con il testo esatto e il
punto in cui compare. Se preferisci, manda direttamente una pull request, in
genere basta una riga nel dizionario giusto:

- **voce di Super+K**: `keybindings-it.tsv` (`inglese<TAB>italiano`). Vale subito.
- **notifica o messaggio a schermo**: `notifiche-it.tsv`, oppure
  `notifiche-it.sed` se il testo contiene numeri, nomi o orari. Vale subito.
- **scritta della barra**: `plugin-it.json`, poi `./plugin-it.sh`.
- **voce di menu**: `menu-it.jsonc`, poi `./menu-it.sh`.

Le notifiche delle altre app (browser e simili) non passano da Omarchy e non
riguardano questo kit.

## Limiti noti

- "Launching <app>..." (la finestrella che compare quando apri un'app) è nel
  codice della shell (`shell/services/AppLibrary.qml`) e non in un plugin,
  quindi il kit non riesce a tradurlo.
- Dopo gli aggiornamenti di Omarchy possono comparire voci nuove in inglese,
  finché non vengono aggiunte ai dizionari.

Licenza MIT. Progetto non ufficiale, non affiliato a Omarchy.
