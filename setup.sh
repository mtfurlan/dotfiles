#!/bin/bash
set -euo pipefail
cd $(dirname "$0")

help() {
  echo "install stuff, setup github keys, download random tools"
  echo "       -u, --update"
  echo "                only update local tools, don't run full setup"
  echo "       -h, --help"
  echo "                display this help"
}

# getopt short options go together, long options have commas
TEMP=`getopt -o uh --long update,help -n 'test.sh' -- "$@"`
if [ $? != 0 ] ; then
    echo "Something wrong with getopt" >&2
    exit 1
fi
eval set -- "$TEMP"

update=false
while true ; do
    case "$1" in
        -u|--update) update=true ; shift ;;
        -h|--help) help ; exit 0 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done


setup_github() {
  read -r -p "Brand new keys? [Y/n] " response
  case "$response" in
    [nN][oO]|[nN])
      echo "Alright setup your own key"
      read -n 1 -s -r -p "Press any key to continue"
      verify_github_remote
      return
      ;;
  esac
  ssh-keygen -N "" -f ~/.ssh/github_rsa
  cat ~/.ssh/github_rsa.pub
  echo "Add that to github"
  read -n 1 -s -r -p "Press any key to continue"
  verify_github_remote
}
verify_github_remote() {
  echo ""
  if ssh -T -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no git@github.com 2>&1 | grep "successfully authenticated" ; then
    read -r -p "You going to fix that key? [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY])
        echo "Alright good luck"
        read -n 1 -s -r -p "Press any key to continue"
        change_dofiles_remote
        ;;
    esac
    return;
  fi
}


if git remote -v | grep https ; then
  read -r -p "Change github remote to not be https? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
        git remote remove origin
        git remote add origin git@github.com:mtfurlan/dotfiles.git
      ;;
  esac
fi

get_github_latest_release() {
  curl -s "$1/releases/latest" | sed 's/.*href=".*tag.\(.*\)">redirected.*/\1/'
}
get_github_latest_release_file() {
  echo "$1/releases/download/$(get_github_latest_release $1)/$2"
}

update_tools() {

  batVersion=$(curl -s https://github.com/sharkdp/bat/releases/latest | sed 's/.*releases\/tag\/v\([0-9.]*\)">redirected.*/\1/')
  batInstalledVersion=$(dpkg -s bat 2>/dev/null | grep Version | sed 's/Version: //') || true

  if [ "$batInstalledVersion" != "$batVersion" ]; then
    echo "VERSION MISMATCH: bat version: $batVersion, installedVersion: $batInstalledVersion"
    if [ "$(uname -m)" == "x86_64" ]; then
      wget -q -O "/tmp/bat_${batVersion}_amd64.deb" "https://github.com/sharkdp/bat/releases/download/v$batVersion/bat_${batVersion}_amd64.deb"
      sudo dpkg -i "/tmp/bat_${batVersion}_amd64.deb"
    else
      echo "can't install bat for this arch, fix setup script"
    fi
  fi

  pushd ~/.fzf
  git pull
  popd

  mkdir -p ~/.local/bin
  wget -q -O ~/.local/bin/up $(get_github_latest_release_file https://github.com/akavel/up up)
  chmod +x ~/.local/bin/up
  wget -q -O ~/.local/bin/diff-so-fancy https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
  chmod +x ~/.local/bin/diff-so-fancy

  pushd ~/src/PathPicker/debian
  git pull
  ./package.sh
  sudo dpkg -i ../fpp_*.deb
  popd
}

install_tools() {
  sudo apt-get install python3-dev python3-pip python3-setuptools jq -y
  sudo pip3 install thefuck yq

  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true
  ~/.fzf/install --completion --key-bindings --no-update-rc

  git clone https://github.com/facebook/PathPicker.git ~/src/PathPicker || true

  update_tools
}


setup() {
  echo "trying to install things"

  if [ -x "$(which apt-get)" ] ; then
    sudo apt-get update
    sudo apt-get install vim-nox tmux git sl silversearcher-ag curl tree bash-completion
  else
    echo "apt-get not installed, fix setup.sh for this platform"
  fi
  if [ ! -f ~/.ssh/github_rsa ]; then
    read -r -p "Setup github keys? [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY])
        setup_github
        ;;
    esac
  fi

  read -r -p "install random tools(thefuck, yq, fzf, up)? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      install_tools
      ;;
  esac

  echo "if it's a thinkpad, do battery management setup"
  echo "    tpacpi-bat: https://github.com/teleshoes/tpacpi-bat"
  echo "    TODO: https://github.com/morgwai/tpbat-utils-acpi"
}


if [ "$update" = true ]; then
  update_tools
else
  setup
fi
