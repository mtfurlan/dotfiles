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

alias glog="git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
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

alias duc="du --max-depth=1 -ha | sort -rh | sed 's/\.\///' | sed /^0/d"

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

extract () {
    if [ -f "$1" ] ; then
      case $1 in
        *.tar | *.tar.* | *.tgz | *.txf) tar xf     "$1"     ;;
        *.bz2)                           bunzip2    "$1"     ;;
        *.rar)                           unrar x    "$1"     ;;
        *.gz)                            gunzip     "$1"     ;;
        *.tbz2)                          tar xjf    "$1"     ;;
        *.zip)                           unzip      "$1"     ;;
        *.Z)                             uncompress "$1"     ;;
        *.7z)                            7z x       "$1"     ;;
        *.xz)                            unxz -k    "$1"     ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

function dsf {
    diff -u "$@" | diff-so-fancy | less -RF
}

alias gitaddWithoutWhitespace='git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -'

function lyricsGrep {
    find . -type f \( -name "*.flac" -o -name "*.mp3" \) -print0 | xargs -0 exiftool -artist -album -title -lyrics -lyrics-xxx | grep -E -i -B3 "$@"
}

# https://stackoverflow.com/a/29613573
# SYNOPSIS
#   quoteRe <text>
# shellcheck disable=SC1003
quoteRe() { sed -e 's/[^^]/[&]/g; s/\^/\\^/g; $!a\'$'\n''\\n' <<<"$1" | tr -d '\n'; }

# SYNOPSIS
#  quoteSubst <text>
quoteSubst() {
  IFS= read -d '' -r < <(sed -e ':a' -e '$!{N;ba' -e '}' -e 's/[&/\]/\\&/g; s/\n/\\&/g' <<<"$1")
  printf %s "${REPLY%$'\n'}"
}

function unicodePoint {
    # print
    # convert to utf-32 which is the code point
    # print as raw hex
    # each code point to new line
    # print
    echo -n "$*" | iconv -f utf8 -t utf32be  | xxd -p | fold -w8 \
        | perl -C -ne 'chomp; s/^(:?00)+//g; print "U+$_: " . (chr hex "0x$_") . "\n"'
    #TODO: doesn't work for all text?
    #maybe utf32 isn't correct?
}

function battlebots {
    file=$1
    ep=$(basename "$file" | sed 's/.*S\([0-9]\{2\}\)E\([0-9]\{2\}\).*/s\1e\2/')
    tmpfile="/tmp/battlebots_${ep}.mp4"
    ffmpeg -i "$file" "$tmpfile"
    aws s3api put-object --bucket scz --acl public-read --key "$(basename "$tmpfile")" --content-type video/mp4 --body "$tmpfile"
    echo "https://scz.s3.amazonaws.com/battlebots_${ep}.mp4"
}

function replace {
    search=${1:-}
    replace=${2:-}
    ag -l0 "$search" | xargs -0 -l -- sed -i "s/$search/$replace/g"
}

function replaceSimple {
    search=${1:-}
    replace=${2:-}
    ag -l0 "$(quoteRe "$search")" | xargs -0 -l -- sed -i "s/$(quoteRe "$search")/$(quoteSubst "$replace")/g"
}

alias copyToClipboard="xclip -sel clip"

function daysBetween {
    a=${1:-}
    b=${2:-}
    format=${3:-%Y-%m-%d}
    python -c "import datetime; print((datetime.datetime.strptime('$a', '$format') - datetime.datetime.strptime('$b', '$format')).days)"
}
