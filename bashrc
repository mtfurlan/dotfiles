# If not running interactively, don't do anything
# TODO: is this important?
case $- in
    *i*) ;;
      *) return;;
esac

#enable/disable git info in PS1
#override in localrc
git_prompt=true

export EDITOR=vim
export VISUAL=vim
export PATH=~/bin:~/local/bin:~/.local/bin:/sbin:/usr/sbin:/usr/local/sbin:$PATH

# disable history expansion, ecclamation marks are useful sometimes
set +H

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

#vi mode
set -o vi


#allow machine specific config
if [ -r ~/.localrc ]; then
    # shellcheck disable=SC1090
    . ~/.localrc
fi

# Alias
if [ -r ~/.aliasrc ]; then
    # shellcheck disable=SC1090
    . ~/.aliasrc
fi

# fzf
if [ -r ~/.fzf.bash ]; then
    # shellcheck disable=SC1090
    . ~/.fzf.bash
fi

if [ -r ~/.gh-completion ]; then
    # shellcheck disable=SC1090
    . ~/.gh-completion
fi

# https://github.com/nvbn/thefuck
# defines 'fuck' as a command to fix the last command
if builtin type -P "thefuck" &> /dev/null; then
    eval "$(thefuck --alias)"
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"



# number of colors supported
colors=0
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)

    #I dunno why tput colors 2 vs tput colors
    colors=$(tput colors 2>/dev/null)
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


export GIT_PS1_SHOWDIRTYSTATE=1           # '*'=unstaged, '+'=staged
export GIT_PS1_SHOWSTASHSTATE=1           # '$'=stashed
export GIT_PS1_SHOWUNTRACKEDFILES=1       # '%'=untracked
export GIT_PS1_SHOWUPSTREAM="auto"     # 'u='=no difference, 'u+1'=ahead by 1 commit
export GIT_PS1_STATESEPARATOR=" "
export GIT_PS1_DESCRIBE_STYLE="describe"  # detached HEAD style:

# This will limit the number of dirs to show in the PS1
# tom@sanctum:/chroot/apache/usr/local/app-library/lib/App/Library/Class$ PROMPT_DIRTRIM=3
# tom@sanctum:.../App/Library/Class$

export PROMPT_DIRTRIM=5


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

    export GIT_PS1_SHOWCOLORHINTS=1

    # http://serverfault.com/a/425657/228348
    # use color range 130-210
    hostColorIndex=$(hostname | od | tr ' ' '\n' | awk "{total = total + \$1}END{print $hostRangeStart + (total % $hostRange)}")
    hostColor="\[$(tput setaf "$hostColorIndex")\]"

    # debian chroot stuff copied from a debian /etc/skel/.bahsrc
    # \${?##0} shows the return code if nonzero
    # VENV is a function that is either empty or the python virtualenv name
    myFancyPS1Start="${debian_chroot:+($debian_chroot)}$Red\${?##0}$Cya$VENV$Gre\u@$hostColor\h:$Blu\w$None"
    myFancyPS1End="$None$ "

    if [ "$git_prompt" = true ]; then
        PROMPT_COMMAND='__git_ps1 "$myFancyPS1Start" "$myFancyPS1End"'
    else
        PS1="$myFancyPS1Start$myFancyPS1End"
        unset PROMPT_COMMAND
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}$VENV\u@\h:\w\$ '
fi

# enable color support of ls and also add handy aliases
if which dircolors >/dev/null; then
    if [[ -f "$HOME/.dircolors" ]]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

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



# -- Improved X11 forwarding through GNU Screen (or tmux).
# http://alexteichman.com/octo/blog/2014/01/01/x11-forwarding-and-terminal-multiplexers/
# If not in screen or tmux, update the DISPLAY cache.
# If we are, update the value of DISPLAY to be that in the cache.
function update-x11-forwarding
{
    if [ -z "$STY" ] && [ -z "$TMUX" ]; then
        echo "$DISPLAY" > ~/.display.txt
    else
        DISPLAY=$(cat ~/.display.txt)
        export DISPLAY
    fi
}

# This is run before every command.
preexec() {
    # Don't cause a preexec for PROMPT_COMMAND.
    # Beware!  This fails if PROMPT_COMMAND is a string containing more than one command.
    [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return

    update-x11-forwarding

    # Debugging.
    #echo DISPLAY = $DISPLAY, display.txt = `cat ~/.display.txt`, STY = $STY, TMUX = $TMUX
}
trap 'preexec' DEBUG

# try to set terminal title to hostname
setTitle "$(hostname)"
