# === DOTFILES: ENVIRONMENT & SHELL INTEGRATION ===

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
[ -d "/usr/lib/ccache" ] && export PATH="/usr/lib/ccache:$PATH"
export EDITOR="${EDITOR:-micro}"

# Bitwarden SSH agent (použije živý Flatpak/natívny socket, inak fallback na systémový openssh_agent)
_bw_sock_alive() {
    [ -S "$1" ] || return 1
    if command -v python3 >/dev/null 2>&1; then
        python3 -c 'import socket,sys; s=socket.socket(socket.AF_UNIX,socket.SOCK_STREAM); s.settimeout(0.2); s.connect(sys.argv[1]); s.close()' "$1" 2>/dev/null
    elif command -v ss >/dev/null 2>&1; then
        ss -xlH 2>/dev/null | grep -Fq "$1"
    else
        return 0
    fi
}

if _bw_sock_alive "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"; then
    export SSH_AUTH_SOCK="$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
elif _bw_sock_alive "$HOME/.bitwarden-ssh-agent.sock"; then
    export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
else
    _openssh_sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/openssh_agent"
    if { [ -z "${SSH_AUTH_SOCK:-}" ] || ! _bw_sock_alive "$SSH_AUTH_SOCK"; } && _bw_sock_alive "$_openssh_sock"; then
        export SSH_AUTH_SOCK="$_openssh_sock"
    fi
    unset _openssh_sock
fi
unset -f _bw_sock_alive

# Bitwarden CLI in-memory session loader (RAMFS tmpfs)
if [ -z "$BW_SESSION" ]; then
    _BW_SESS_FILE="/run/user/$(id -u 2>/dev/null || id -u)/bw_session"
    if [ -f "$_BW_SESS_FILE" ]; then
        export BW_SESSION="$(cat "$_BW_SESS_FILE")"
    fi
    unset _BW_SESS_FILE
fi

# Zoxide (inteligentné cd)
if command -v zoxide >/dev/null 2>&1; then 
    eval "$(zoxide init bash)"
fi

# ==========================================
# Fuzzy Search (fzf) - Multiplatform Setup
# ==========================================
if command -v fzf >/dev/null 2>&1; then
    # 1. Skúsime moderný fzf --bash (v0.48+)
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    # 2. Fallback pre Fedora / RHEL
    elif [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
        source /usr/share/fzf/shell/key-bindings.bash 2>/dev/null
    # 3. Fallback pre Debian / Ubuntu / Raspbian
    elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash 2>/dev/null
    # 4. Fallback pre git inštaláciu (Pixel / standalone)
    elif [ -f "$HOME/.fzf.bash" ]; then
        source "$HOME/.fzf.bash" 2>/dev/null
    fi

    # Nastavenie fd pre FZF (rešpektuje .gitignore, ignoruje .git)
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
    elif command -v fdfind >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fdfind --type f --strip-cwd-prefix --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fdfind --type d --strip-cwd-prefix --hidden --follow --exclude .git'
    fi

    export FZF_DEFAULT_OPTS="--height 45% --layout=reverse --border --info=inline --bind 'ctrl-/:toggle-preview'"

    # Preview pre súbory (bat)
    if command -v bat >/dev/null 2>&1; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}' --preview-window=right:60%:wrap"
    fi

    # Preview pre adresáre (eza)
    if command -v eza >/dev/null 2>&1; then
        export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null' --preview-window=right:50%:wrap"
    fi
fi

# ==========================================
# Starship Prompt (s fallbackom pre kontajnery bez starshipu)
# ==========================================
if command -v starship >/dev/null 2>&1; then
    export starship_precmd_user_func="set_tab_title"
    eval "$(starship init bash)"
elif [ -n "$CONTAINER_ID" ]; then
    if [[ "$CONTAINER_ID" == *"debian"* ]]; then
        C_COLOR="\[\e[31m\]"
    elif [[ "$CONTAINER_ID" == *"fedora"* ]]; then
        C_COLOR="\[\e[34m\]"
    elif [[ "$CONTAINER_ID" == *"ubuntu"* ]]; then
        C_COLOR="\[\e[38;5;208m\]"
    else
        C_COLOR="\[\e[32m\]"
    fi
    C_RESET="\[\e[0m\]"
    PS1="📦[\u@${C_COLOR}${CONTAINER_ID}${C_RESET} \W]\$ "
fi
