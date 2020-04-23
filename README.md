# Dotfiles

## Random tools
* https://github.com/kislyuk/yq
* https://github.com/so-fancy/diff-so-fancy
* https://github.com/sharkdp/bat
* https://github.com/denilsonsa/prettyping
* https://github.com/junegunn/fzf
* https://github.com/akavel/up
* https://github.com/nvbn/thefuck
* https://github.com/bcicen/slackcat

## Thinkpad-specific
* https://github.com/teleshoes/tpacpi-bat
* https://github.com/morgwai/tpbat-utils-acpi

## Clock date format
```
%F | %a %b | %T
```

## automounting disks
* Disable mate automounting: `gsettings set org.mate.media-handling automount false`
* Install [udiskie](https://github.com/coldfix/udiskie)
  * `sudo apt install udiskie`
  * autostart `udiskie --no-automount`
