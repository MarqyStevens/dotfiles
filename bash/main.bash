DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ -f "$DOTFILES_DIR/bash/env.bash" ] && source "$DOTFILES_DIR/bash/env.bash"
[ -f "$DOTFILES_DIR/bash/aliases.bash" ] && source "$DOTFILES_DIR/bash/aliases.bash"
[ -f "$DOTFILES_DIR/bash/functions.bash" ] && source "$DOTFILES_DIR/bash/functions.bash"

[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"
