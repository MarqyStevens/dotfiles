# === DOTFILES: ENVIRONMENT & SHELL INTEGRATION ===

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export EDITOR="${EDITOR:-micro}"

# Bitwarden SSH agent (detekuje automaticky Flatpak aj natívnu inštaláciu)
if [ -z "$SSH_AUTH_SOCK" ]; then
    if [ -S "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock" ]; then
        export SSH_AUTH_SOCK="$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
    elif [ -S "$HOME/.bitwarden-ssh-agent.sock" ]; then
        export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
    fi
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
# Starship Prompt
# ==========================================
if command -v starship >/dev/null 2>&1; then
    export starship_precmd_user_func="set_tab_title"
    eval "$(starship init bash)"
fi
