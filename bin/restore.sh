#!/bin/bash
disableTouchpad.sh
xmodmap ~/.Xmodmap
if [ -x "$HOME/xrandr" ] ; then
  echo "running xrandr"
  $HOME/xrandr
else
  echo "didn't find xrandr"
fi
xfwm4 --replace &
