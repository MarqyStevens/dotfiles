# Moderné náhrady za staré unixové príkazy
alias ls='eza --icons --group-directories-first 2>/dev/null || ls --color=auto'
alias ll='eza -la --icons --group-directories-first 2>/dev/null || ls -la --color=auto'
alias cat='bat --style=plain --paging=never 2>/dev/null || cat'
alias grep='rg 2>/dev/null || grep --color=auto'
alias find='fd 2>/dev/null || find'

# Navigácia
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias q='exit'

# Systém a sieť
alias ports='ss -tulpn'
alias myip='hostname -I | awk "{print \$1}"'
alias ftp-bookmarks='lftp -e "bookmark list; exit"'
alias df='df -h'
alias free='free -h'

# Git rýchliky
alias gs='git status'
alias gp='git pull'
alias gpush='git push'
alias gd='git diff'
