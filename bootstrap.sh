#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "⚡ BOOTSTRAP: Inicializácia nového stroja do flotily..."

# 1. Detekcia a inštalácia systémových balíčkov
if command -v dnf >/dev/null 2>&1; then
    echo "📦 Detekovaná Fedora / RHEL rodina (DNF)..."
    sudo dnf install -y curl wget git nano micro lftp eza bat ripgrep fd-find fzf zoxide qrencode || true
elif [ -n "$TERMUX_VERSION" ] || command -v pkg >/dev/null 2>&1; then
    echo "📦 Detekovaný Android / Termux (PKG)..."
    pkg update -y
    pkg install -y curl wget git nano micro lftp eza bat ripgrep fd fzf zoxide starship openssh libqrencode || true
elif command -v apt >/dev/null 2>&1; then
    echo "📦 Detekovaný Debian / Ubuntu / Raspbian (APT)..."
    sudo apt update
    sudo apt install -y curl wget git nano micro lftp eza fd-find bat zoxide fzf ripgrep qrencode || true
elif command -v pacman >/dev/null 2>&1; then
    echo "📦 Detekovaný Arch Linux (Pacman)..."
    sudo pacman -S --noconfirm curl wget git nano micro lftp eza bat ripgrep fd fzf zoxide starship || true
else
    echo "⚠️  Neznámy balíčkovací manažér. Nainštaluj si základné balíčky manuálne."
fi

# 2. Nastavenie časového pásma (Bratislava) na systémoch s systemd / timedatectl
if command -v timedatectl >/dev/null 2>&1; then
    sudo timedatectl set-timezone Europe/Bratislava 2>/dev/null || true
elif [ -f /usr/share/zoneinfo/Europe/Bratislava ] && [ -w /etc/localtime ]; then
    ln -fs /usr/share/zoneinfo/Europe/Bratislava /etc/localtime 2>/dev/null || true
fi

# 3. Inštalácia Starship (ak ešte nie je v PATH)
if ! command -v starship >/dev/null 2>&1; then
    echo "🚀 Inštalujem Starship prompt do ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi

# 4. Inštalácia AdwaitaMono Nerd Font (ak chýba)
if ! fc-list : family 2>/dev/null | grep -qi "AdwaitaMono Nerd Font"; then
    echo "🔤 Inštalujem AdwaitaMono Nerd Font..."
    mkdir -p "$HOME/.local/share/fonts/AdwaitaMono"
    if curl -fLo /tmp/AdwaitaMono.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/AdwaitaMono.tar.xz 2>/dev/null; then
        tar -xf /tmp/AdwaitaMono.tar.xz -C "$HOME/.local/share/fonts/AdwaitaMono" 2>/dev/null || true
        rm -f /tmp/AdwaitaMono.tar.xz
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true
        fi
        echo "✅ AdwaitaMono Nerd Font nainštalovaný."
    fi
fi

# Termux podpora pre font
if [ -n "$TERMUX_VERSION" ] || [ -d "$HOME/.termux" ]; then
    mkdir -p "$HOME/.termux"
    if [ -f "$HOME/.local/share/fonts/AdwaitaMono/AdwaitaMonoNerdFont-Regular.ttf" ]; then
        cp -f "$HOME/.local/share/fonts/AdwaitaMono/AdwaitaMonoNerdFont-Regular.ttf" "$HOME/.termux/font.ttf"
        termux-reload-settings 2>/dev/null || true
    fi
fi

# 5. Spustenie prelinkovania konfigurácií
"$DOTFILES_DIR/install.sh"

echo "🎉 Hotovo! Zadaj: source ~/.bashrc"
