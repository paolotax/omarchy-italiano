# Caricato dentro una copia al volo di omarchy-menu-keybindings (vedi omarchy-menu-keybindings-it)
eval "$(declare -f output_binding_records | sed '1s/^output_binding_records/_kb_records_en/')"
output_binding_records() {
  _kb_records_en | awk -F '\t' -v OFS='\t' -v tsv="$KB_IT_TSV" '
    BEGIN { while ((getline l < tsv) > 0) { if (l ~ /^#/) continue; split(l, p, "\t"); if (p[2] != "") tr[p[1]] = p[2] } }
    {
      if (match($1, /→ /)) {
        d = substr($1, RSTART + RLENGTH)
        if (d in tr) $1 = substr($1, 1, RSTART + RLENGTH - 1) tr[d]
      }
      print
    }'
}
