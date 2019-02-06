#.bash_profile, executed by login shells
#Also executed by .bashrc, so all shells really


# Check if we support colours
__colour_enabled() {
    local -i colors=$(tput colors 2>/dev/null)
    [[ $? -eq 0 ]] && [[ $colors -gt 2 ]]
}

if __colour_enabled; then
    # define colours
    # Wrap the colour codes between \[ and \], so that
    # bash counts the correct number of characters for line wrapping:
     Red='\[\033[01;31m\]';  BRed='\[\e[1;31m\]'
     Gre='\[\033[01;32m\]';  BGre='\[\e[1;32m\]'
     Yel='\[\e[0;33m\]';  BYel='\[\e[1;33m\]'
     Blu='\[\033[01;34m\]';  BBlu='\[\e[1;34m\]'
     Mag='\[\e[0;35m\]';  BMag='\[\e[1;35m\]'
     Cya='\[\e[0;36m\]';  BCya='\[\e[1;36m\]'
     Whi='\[\e[0;37m\]';  BWhi='\[\e[1;37m\]'
     None='\[\e[0m\]' # Return to default colour
else
     unset Red;  unset BRed
     unset Gre;  unset BGre
     unset Yel;  unset BYel
     unset Blu;  unset BBlu
     unset Mag;  unset BMag
     unset Cya;  unset BCya
     unset Whi;  unset BWhi
     unset None
fi


#allow machine specific config
if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi


export EDITOR=vim
export VISUAL=vim
export PATH=~/bin:~/local/bin:~/.local/bin:/sbin:/usr/sbin:/usr/local/sbin:$PATH

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

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

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


export GIT_PS1_SHOWDIRTYSTATE=1           # '*'=unstaged, '+'=staged
export GIT_PS1_SHOWSTASHSTATE=1           # '$'=stashed
export GIT_PS1_SHOWUNTRACKEDFILES=1       # '%'=untracked
export GIT_PS1_SHOWUPSTREAM="auto"     # 'u='=no difference, 'u+1'=ahead by 1 commit
export GIT_PS1_STATESEPARATOR=" "
export GIT_PS1_DESCRIBE_STYLE="describe"  # detached HEAD style:


if __colour_enabled; then
    export GIT_PS1_SHOWCOLORHINTS=1

    #A way to show if user is in groups wheel, sudo, or adm
    if [[ `groups` =~ wheel|sudo|adm ]]; then
        sudo="\[\e[32m\](s)\[\e[m\]"
    else
        sudo="\[\e[31m\](ns)\[\e[m\]"
    fi

    # http://serverfault.com/a/425657/228348
    hostnamecolor=$(hostname | od | tr ' ' '\n' | awk '{total = total + $1}END{print 30 + (total % 6)}')

    #the first bit just shows the return code if nonzero, in red
    myFancyPS1Start="${debian_chroot:+($debian_chroot)}$Red\${?##0}$Gre\u@\[\e[${hostnamecolor}m\]\h$sudo:$Blu\w$None"
    myFancyPS1End="$None$ "
    PROMPT_COMMAND='__git_ps1 "$myFancyPS1Start" "$myFancyPS1End"'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
    complete -cf sudo
fi

if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
fi

if which diff-so-fancy > /dev/null; then
    export GIT_PAGER="diff-so-fancy | less --tabs=4 -RFX"
else
    export GIT_PAGER="less -R"
fi


# https://github.com/nvbn/thefuck
# defines 'fuck' as a command to fix the last command
if which thefuck >/dev/null; then
    eval $(thefuck --alias)
fi

# -- Improved X11 forwarding through GNU Screen (or tmux).
# http://alexteichman.com/octo/blog/2014/01/01/x11-forwarding-and-terminal-multiplexers/
# If not in screen or tmux, update the DISPLAY cache.
# If we are, update the value of DISPLAY to be that in the cache.
function update-x11-forwarding
{
    if [ -z "$STY" -a -z "$TMUX" ]; then
        echo $DISPLAY > ~/.display.txt
    else
        export DISPLAY=`cat ~/.display.txt`
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

set -o vi
