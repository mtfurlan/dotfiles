#!/bin/sh

# defines 'f' as a command to fix the last command
if exists pay-respects ; then
    eval "$(pay-respects bash --alias --nocnf)"
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# fzf
if [ -r ~/.fzf.bash ]; then
    # shellcheck disable=SC1090
    . ~/.fzf.bash
fi

# enable color support of ls and also add handy aliases
if exists dircolors ; then
    if [ -f "$HOME/.dircolors" ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi
