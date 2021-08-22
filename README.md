# Dotfiles

## Random tools
* tig: interactive git history viewer
  * apt
* dsf: better git diff
  * https://github.com/so-fancy/diff-so-fancy
* bat: pretty formatted cat
  * https://github.com/sharkdp/bat
* prettyping: A pretty ping
  * https://github.com/denilsonsa/prettyping
* fzf: fuzzy search, does bash history
  * https://github.com/junegunn/fzf
* up: interactively run commands on piped input
  * https://github.com/akavel/up
* fuck: fix whatever it was you fucked up with the last command
  * https://github.com/nvbn/thefuck
* slackcat: send files or test to slack from the command line
  * https://github.com/bcicen/slackcat

## Thinkpad-specific
* https://github.com/teleshoes/tpacpi-bat
* https://github.com/morgwai/tpbat-utils-acpi

## Clock date format
* `dconf-editor`, `org / mate / panel / objects / clock / prefs`
* Change `format` to "custom"
* `custom-format` to
  ```
  %F | %a %b | %T
  ```

## automounting disks
* Disable mate automounting: `gsettings set org.mate.media-handling automount false`
* Install [udiskie](https://github.com/coldfix/udiskie)
  * `sudo apt install udiskie`
  * autostart `udiskie --no-automount`
