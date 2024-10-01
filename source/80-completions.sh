#!/bin/bash

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # shellcheck disable=SC1091
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        # shellcheck disable=SC1091
        . /etc/bash_completion
    fi
    complete -cf sudo
fi

for file in "$DOTFILES/completions"/*; do
    #shellcheck disable=SC1090
    . "$file"
done
