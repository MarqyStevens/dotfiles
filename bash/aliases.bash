# Moderné náhrady za staré unixové príkazy
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'
    alias la='ls -a --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=plain --paging=never'
fi

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
fi

alias grep='grep --color=auto'

# Navigácia
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias q='exit'

# Systém a sieť
alias ports='ss -tulpn'
alias myip='hostname -I | awk "{print \$1}"'
alias ftp-bookmarks='lftp -e "bookmark list; exit"'
alias tv='adb connect 192.168.0.215:5555'
alias df='df -h'
alias free='free -h'

# Git rýchliky
alias gs='git status'
alias gp='git pull'
alias gpush='git push'
alias gd='git diff'

# Pi & Hardvér diagnostika (iba ak existuje vcgencmd)
if command -v vcgencmd >/dev/null 2>&1; then
    alias pi-health='vcgencmd measure_temp && vcgencmd measure_clock arm && vcgencmd get_throttled'
fi

# Hardvérové 1080p streamovanie (nízka záťaž procesora)
if command -v mpv >/dev/null 2>&1; then
    alias play='mpv --ytdl-format="bestvideo[height<=1080]+bestaudio/best"'
fi

# AI nástroje
alias agy-boost='agy --boost'
