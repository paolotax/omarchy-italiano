# Notifiche con valori variabili (sed -E). Ogni riga: s/inglese/italiano/
s/^(.+) installed$/\1 installato/
s/^(.+) is now the default browser$/Ora il browser predefinito è \1/
s/^(.+) is now the default editor$/Ora l'editor predefinito è \1/
s/^(.+) is now the default terminal$/Ora il terminale predefinito è \1/
s/^Battery is down to (.+)$/Batteria scesa al \1/
s/^Created screenshot directory: (.+)$/Creata la cartella degli screenshot: \1/
s/^Mirroring enabled \((.+)\)$/Duplicazione dello schermo attiva su \1/
s/^No plugin to (.+)$/Nessun plugin da \1/
s/^No saved width found for (.+) on workspace (.+)$/Nessuna larghezza salvata per \1 sul workspace \2/
s/^Saved width for (.+) on workspace (.+)$/Larghezza salvata per \1 sul workspace \2/
s/^Screen recording directory does not exist: (.+)$/La cartella delle registrazioni non esiste: \1/
s/^Sent to (.+)$/Inviato a \1/
s/^Timezone is now set to (.+)$/Fuso orario impostato su \1/
s/^Transcoded to (.+) (.+)$/Convertito in \1 \2/
s/^Workspace layout set to (.+)$/Layout del workspace impostato su \1/
s/^Taildrop transfer failed$/Trasferimento Taildrop non riuscito/
# Promemoria
s/^([0-9]+)-min reminder in /Promemoria di \1 min fra /
s/^Reminder set for ([0-9]+) minutes$/Promemoria fra \1 minuti/
s/^(.+) in ([0-9]+) minutes$/\1 fra \2 minuti/
s/^You'"'"'ll be reminded at (.+)$/Ti avviso alle \1/
s/^(.+) in ([0-9]+m [0-9]+s|[0-9]+m|[0-9]+s) \(([0-9]{1,2}:[0-9]{2})\)$/\1 fra \2 (\3)/
