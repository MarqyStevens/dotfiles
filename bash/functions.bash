# === DOTFILES: SHELL FUNCTIONS & TOOLS ===

# Kontrola webu (HTTP status + odozva)
checkweb() { 
    curl -sIL -o /dev/null -w "Status: %{http_code}\nOdozva: %{time_total}s\n" "${1:-google.com}"
}

# QR kód priamo do terminálu
qr() { 
    if command -v qrencode >/dev/null 2>&1; then
        qrencode -t ANSI256 "$*"
    else
        echo "qrencode nie je nainštalovaný"
    fi
}

# Nastavenie titulku karty v termináli
set_tab_title() { 
    echo -ne "\033]0;${PWD##*/}\007"
}

# fe: Fuzzy edit súboru cez micro/editor
fe() {
    local file
    local fd_cmd="fd"
    command -v fdfind >/dev/null 2>&1 && fd_cmd="fdfind"
    file=$($fd_cmd --type f --hidden --follow --exclude .git 2>/dev/null | fzf --query="$1" --preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}')
    [ -n "$file" ] && "${EDITOR:-micro}" "$file"
}

# fcd: Fuzzy cd do priečinka
fcd() {
    local dir
    local fd_cmd="fd"
    command -v fdfind >/dev/null 2>&1 && fd_cmd="fdfind"
    dir=$($fd_cmd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --query="$1" --preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null' --preview-window=right:50%:wrap)
    [ -n "$dir" ] && cd "$dir"
}

# frg: Interaktívne ripgrep vyhľadávanie v obsahu súborov s náhľadom bat a skokom na riadok
frg() {
    if ! command -v rg >/dev/null 2>&1 || ! command -v fzf >/dev/null 2>&1; then
        echo "Vyžaduje ripgrep (rg) a fzf."
        return 1
    fi
    local initial_query="${*:-}"
    local rg_cmd="rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git'"
    IFS=: read -ra selected < <(
        fzf --ansi --disabled --query "$initial_query" \
            --bind "start:reload:$rg_cmd {q}" \
            --bind "change:reload:sleep 0.1; $rg_cmd {q} || true" \
            --delimiter : \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null' \
            --preview-window 'right,60%,border-bottom,+{2}+3/3,~3'
    )
    if [ -n "${selected[0]}" ]; then
        "${EDITOR:-micro}" "+${selected[1]}" "${selected[0]}"
    fi
}

# ==========================================
# Victor the Cleaner (Fleet Maintenance)
# Prečisťuje journalctl, Flatpak runtimes, package cache a coredumpy
# ==========================================
victor() {
    echo -e "\033[1;31m==> [VICTOR LE NETTOYEUR: DISSOLVING DEAD WEIGHT] <==\033[0m"

    # 1. Systemd journal - orež na 500M
    if command -v journalctl >/dev/null 2>&1; then
        echo -e "\033[1;34m[*] Choking systemd journal logs to 500M...\033[0m"
        sudo journalctl --vacuum-size=500M 2>/dev/null || journalctl --vacuum-size=500M 2>/dev/null || true
    fi

    # 2. Flatpak runtimes (odstráni nepoužívané runtimes a SDKs)
    if command -v flatpak >/dev/null 2>&1; then
        echo -e "\033[1;34m[*] Pouring acid on dead Flatpak runtimes...\033[0m"
        flatpak uninstall --unused -y 2>/dev/null || true
    fi

    # 3. Fedora Squad (DNF5 / DNF)
    if command -v dnf >/dev/null 2>&1; then
        echo -e "\033[1;34m[*] Sweeping Fedora DNF cache & orphaned packages...\033[0m"
        sudo dnf autoremove -y 2>/dev/null && sudo dnf clean all 2>/dev/null || true

    # 4. Debian Squad (Debian Testing, Pi 400, Pixel Container)
    elif command -v apt >/dev/null 2>&1; then
        echo -e "\033[1;34m[*] Purging Debian orphaned debs & APT archives...\033[0m"
        sudo apt autoremove --purge -y 2>/dev/null && sudo apt clean 2>/dev/null || true
    fi

    # 5. Core dumps (zmaže crash dumpy z disku)
    if [ -d "/var/lib/systemd/coredump" ]; then
        echo -e "\033[1;34m[*] Scrubbing crash core dumps from disk...\033[0m"
        sudo rm -f /var/lib/systemd/coredump/* 2>/dev/null || true
    fi

    echo -e "\033[1;32m[✓] Target neutralized. Crime scene clean. Shaders untouched.\033[0m"
}
