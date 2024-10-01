#!/bin/bash

# number of colors supported
colors=0
if exists tput ; then
    if tput setaf 1 >&/dev/null; then
        colors=$(tput colors 2>/dev/null)
    fi
elif [[ "$TERM" == *"256color"* ]]; then
    colors=256
fi


# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


# stuff to make python virtual envs work with the fancy git ps1 fuckery
# disable the default virtualenv prompt change
export VIRTUAL_ENV_DISABLE_PROMPT=1

# based on https://stackoverflow.com/a/20026992/2423187
function virtualenv_info
{
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Strip out the path and just leave the env name
        echo "(${VIRTUAL_ENV##*/})"
    fi
}
VENV="\$(virtualenv_info)";


# This will limit the number of dirs to show in the PS1
# tom@sanctum:/chroot/apache/usr/local/app-library/lib/App/Library/Class$ PROMPT_DIRTRIM=3
# tom@sanctum:.../App/Library/Class$
export PROMPT_DIRTRIM=5


# this doesn't work it causes line wrap weirdness
# but not depending on tput was something I wanted once
#color() {
#    #printf '\e[38;5;%dm' $1
#}

if [[ $colors -ge 8 ]]; then
    if [[ $colors -ge 256 ]]; then
        Red="\[$(tput setaf 1)\]"
        Gre="\[$(tput setaf 10)\]"
        Blu="\[$(tput setaf 12)\]"
        Cya="\[$(tput setaf 14)\]"
        hostRangeStart=130
        hostRange=80
    else # 8 color
        Red="\[$(tput setaf 1)\]"
        Gre="\[$(tput setaf 2)\]"
        Blu="\[$(tput setaf 4)\]"
        Cya="\[$(tput setaf 6)\]"
        hostRangeStart=1
        hostRange=7
    fi
    None="\[$(tput sgr0)\]"


    # http://serverfault.com/a/425657/228348
    # use color range 130-210
    hostColorIndex=$(hostname | od | tr ' ' '\n' | awk "{total = total + \$1}END{print $hostRangeStart + (total % $hostRange)}")
    hostColor="\[$(tput setaf "$hostColorIndex")\]"

    # debian chroot stuff copied from a debian /etc/skel/.bahsrc
    # \${?##0} shows the return code if nonzero
    # VENV is a function that is either empty or the python virtualenv name
    myFancyPS1Start="${debian_chroot:+($debian_chroot)}$Red\${?##0}$Cya$VENV$Gre\u@$hostColor\h:$Blu\w$None"
    myFancyPS1End="$None\$ "

    if exists __git_ps1 ; then
        export GIT_PS1_SHOWCOLORHINTS=1
        export GIT_PS1_SHOWDIRTYSTATE=1           # '*'=unstaged, '+'=staged
        export GIT_PS1_SHOWSTASHSTATE=1           # '$'=stashed
        export GIT_PS1_SHOWUNTRACKEDFILES=1       # '%'=untracked
        export GIT_PS1_SHOWUPSTREAM="auto"        # 'u='=no difference, 'u+1'=ahead by 1 commit
        export GIT_PS1_STATESEPARATOR=" "
        export GIT_PS1_DESCRIBE_STYLE="describe"  # detached HEAD style:
        PROMPT_COMMAND='__git_ps1 "$myFancyPS1Start" "$myFancyPS1End"'
    else
        PS1="$myFancyPS1Start$myFancyPS1End"
        unset PROMPT_COMMAND
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}$VENV\u@\h:\w\$ '
fi
