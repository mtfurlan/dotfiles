#!/bin/bash

if exists lsd; then
    lstool="lsd --icon never"
else
    lstool="ls"
fi

#shellcheck disable=SC2139
alias ls="$lstool -F --color=auto"
#shellcheck disable=SC2139
alias ll="$lstool -lAhF --color=auto"
#shellcheck disable=SC2139
alias la="$lstool -lAF --color=auto"

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias pj='ps j'

alias df='df -h'

alias glog="git glog"
alias glogm="git glog --first-parent"
alias gpush="git push --force-with-lease"

alias qr='curl -F-=\<- qrenco.de'
alias weather='curl "wttr.in?m&format=4"'
alias weatherGraph='curl v2.wttr.in?m'

alias :e=vim

alias stripExif="mogrify -strip"

alias whatismyip4='curl -4 ifconfig.co 2>/dev/null'
alias whatismyip6='curl -6 ifconfig.co 2>/dev/null'

whatismyip()
{
    ipv4=$(whatismyip4)
    ipv6=$(whatismyip6)
    echo -e "ipv4: $ipv4\nipv6: $ipv6"
}

duc()
{
    du --max-depth=1 -ha "$@" | sort -rh | sed 's/\.\///' | sed '/^0/d'
}

mkcd () { mkdir -p "$@" && cd "$@" || echo "failed to cd '$*'?"; }

gcd()
{
    # based on https://unix.stackexchange.com/a/97958/60480
    local tmp
    tmp=$(mktemp)
    local repo_name

    git clone "$@" 2>&1 | tee "$tmp"
    repo_name=$(awk -F\' '/Cloning into/ {print $2}' "$tmp")
    rm "$tmp"
    printf "changing to directory %s\n" "$repo_name"
    cd "$repo_name" || echo "failed to cd to cloned repo '$repo_name'?"
}

function dsf {
    diff -u "$@" | diff-so-fancy | less -RF
}

alias gitaddWithoutWhitespace='git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -'

function unicodePoint {
    echo "using uniname, please start using that directly(echo -n <stuff> | uniname)"
    echo -n "$*" | uniname
}

function upload-battlebots {
    local file=$1
    local ep
    local tmpfile

    ep=$(basename "$file" | sed 's/.*S\([0-9]\{2\}\)E\([0-9]\{2\}\).*/s\1e\2/')
    tmpfile="/tmp/battlebots_${ep}.mp4"
    ffmpeg -i "$file" "$tmpfile"
    aws s3api put-object --bucket scz --acl public-read --key "$(basename "$tmpfile")" --content-type video/mp4 --body "$tmpfile"
    echo "https://scz.s3.amazonaws.com/battlebots_${ep}.mp4"
}

alias copyToClipboard="xclip -sel clip"

alias udevReload="sudo udevadm control --reload-rules && sudo udevadm trigger"

alias fuck=f

alias utc="TZ=Z date"
