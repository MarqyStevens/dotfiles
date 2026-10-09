#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "🚀 Prelinkovávam dotfiles z: $DOTFILES_DIR"

mkdir -p "$HOME/.local/bin" "$HOME/.config/micro" "$HOME/.config/lftp"

for script in "$DOTFILES_DIR/bin/"*; do
    if [ -f "$script" ]; then
        name="$(basename "$script")"
        ln -sf "$script" "$HOME/.local/bin/$name"
    fi
done

ln -sf "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES_DIR/config/micro/settings.json" "$HOME/.config/micro/settings.json"
ln -sf "$DOTFILES_DIR/config/lftp/rc" "$HOME/.config/lftp/rc"

if command -v batcat >/dev/null 2>&1 && [ ! -f "$HOME/.local/bin/bat" ]; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if ! grep -q "DOTFILES_DIR" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# === MODULAR DOTFILES ===" >> "$HOME/.bashrc"
    echo "if [ -f \"$DOTFILES_DIR/bash/main.bash\" ]; then" >> "$HOME/.bashrc"
    echo "    source \"$DOTFILES_DIR/bash/main.bash\"" >> "$HOME/.bashrc"
    echo "fi" >> "$HOME/.bashrc"
    echo "✅ Dotfiles zaregistrované v ~/.bashrc"
fi

echo "🎉 Inštalácia dokončená!"

# Zapojenie zdieľaného SSH configu
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if ! grep -q "dotfiles/config/ssh/config" "$HOME/.ssh/config" 2>/dev/null; then
    TMP_SSH="$HOME/.ssh/config.tmp"
    echo "Include $DOTFILES_DIR/config/ssh/config" | cat - "$HOME/.ssh/config" 2>/dev/null > "$TMP_SSH" || echo "Include $DOTFILES_DIR/config/ssh/config" > "$TMP_SSH"
    mv "$TMP_SSH" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
fi
