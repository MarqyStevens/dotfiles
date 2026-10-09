checkweb() { curl -sIL -o /dev/null -w "Status: %{http_code}\nOdozva: %{time_total}s\n" "${1:-google.com}"; }
qr() { qrencode -t ANSI256 "$*"; }
fe() { local f; f=$(fd --type f --hidden --exclude .git 2>/dev/null | fzf --query="$1"); [ -n "$f" ] && "$EDITOR" "$f"; }
fcd() { local d; d=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --query="$1"); [ -n "$d" ] && cd "$d"; }
set_tab_title() { echo -ne "\033]0;${PWD##*/}\007"; }
