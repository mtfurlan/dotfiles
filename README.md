# Dotfiles

These are my dotfiles

It is currently a heavily modified version of
[cowboy/dotfiles](https://github.com/cowboy/dotfiles)

TODO:
* https://github.com/steven-omaha/pacdef

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

## manual config stuff
### mate clock date format
* `dconf-editor`, `org / mate / panel / objects / clock / prefs`
* Change `format` to "custom"
* `custom-format` to
  ```
  %F | %a %b | %T
  ```

### automounting disks
* Disable mate automounting: `gsettings set org.mate.media-handling automount false`
* Install [udiskie](https://github.com/coldfix/udiskie)
  * `sudo apt install udiskie`
  * autostart `udiskie --no-automount`

## Other dotfile managers
### my history
* 2015 [cowboy/dotfiles](https://github.com/cowboy/dotfiles)
* 2017 [justone/dfm](https://github.com/justone/dfm)
  * perl script inside repo, I don't really remember much about it
* 2018 started adding on my own init bash scripts
* 2019 [thoughtbot/rcm](https://github.com/thoughtbot/rcm)
  * worked but controlling exactly what got linked was annoying
  * I was installing via apt which was annoying
* 2024 back to cowboy/dotfiles but modified

### not tried
* https://github.com/one-bash/one.bash
  * interesting plugin system for aliases that maybe have help?
