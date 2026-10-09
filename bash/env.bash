export PATH="$HOME/.local/bin:$PATH"
export EDITOR="micro"

if command -v zoxide >/dev/null 2>&1; then 
    eval "$(zoxide init bash)"
fi

if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash 2>/dev/null
fi

if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

if command -v starship >/dev/null 2>&1; then
    export starship_precmd_user_func="set_tab_title"
    eval "$(starship init bash)"
fi
