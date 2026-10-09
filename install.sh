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
