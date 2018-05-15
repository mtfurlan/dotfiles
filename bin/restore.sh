#!/bin/bash
disableTouchpad.sh
xmodmap ~/.Xmodmap
if [ -x "~/xrandr" ] ; then
  ~/xrandr
fi
