#!/usr/bin/env bash
set -e

echo "=== Inštalujem potrebné balíčky (Debian/Ubuntu/RPi) ==="
sudo apt update
sudo apt install -y curl wget git nano micro lftp eza fd-find bat zoxide fzf ripgrep qrencode

echo "=== Nastavujem časové pásmo (Bratislava) ==="
sudo ln -fs /usr/share/zoneinfo/Europe/Bratislava /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata 2>/dev/null || true

echo "=== Inštalujem Starship ==="
if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
fi

"$(dirname "${BASH_SOURCE[0]}")/install.sh"
