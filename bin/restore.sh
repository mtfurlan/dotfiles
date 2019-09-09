#!/bin/bash
echo "TODO: compare disableTouchpad.sh and xsessionrc"
disableTouchpad.sh
xmodmap ~/.Xmodmap
if [ -x "$HOME/xrandr" ] ; then
  echo "running xrandr"
  $HOME/xrandr
else
  echo "didn't find xrandr config"
fi

# This can help if your window manager doesn't start properly, but that was fixed.
# xfwm4 --replace &
