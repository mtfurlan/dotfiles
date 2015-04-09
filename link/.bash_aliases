alias ls='ls -F --color=auto'
alias ll='ls -lAhF --color=auto'
alias la='ls -lAF --color=auto'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias pj='ps j'

alias df='df -h'

alias tmux='tmux -2'

alias spurge="curl -F 'sprunge=<-' http://sprunge.us"

alias fuck='sudo $(history -p \!\!)'

mkcd () { mkdir -p "$@" && cd "$@"; }
