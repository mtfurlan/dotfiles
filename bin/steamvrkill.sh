#!/bin/bash
# https://github.com/ValveSoftware/SteamVR-for-Linux/issues/577#issuecomment-1627614326
read -r -p "gonna kill something, cool [y/N] " response
case "$response" in
  [yY][eE][sS]|[yY]|'')
      xkill -id "$(xwininfo | sed -n 's/xwininfo: Window id: \([^ ]*\).*/\1/p')"
    ;;
esac
