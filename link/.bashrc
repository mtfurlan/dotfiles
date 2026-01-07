# If not running interactively, don't do anything
# https://unix.stackexchange.com/a/257613
# basically scp and `ssh $command` do weird shit
[ -z "$PS1" ] && return

# Where the magic happens.
export DOTFILES=~/.dotfiles

# Source all files in "source"
# shellcheck disable=SC2120
function src() {
    local file
    if [[ "$1" ]]; then
        #shellcheck disable=SC1090
        source "$DOTFILES/source/$1.sh"
    else
        for file in "$DOTFILES/source"/*.sh; do
            #shellcheck disable=SC1090
            source "$file"
        done
    fi
}

# Run dotfiles script, then source.
function dotfiles() {
    "$DOTFILES/dotfiles" "$@" && src
}

src
