#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
cd $(dirname "$0")

echo "trying to install things"

if [ -x "$(which apt-get)" ] ; then
  sudo apt-get update
  sudo apt-get install vim-nox tmux git sl silversearcher-ag curl tree
else
  echo "apt-get not installed, fix setup.sh for this platform"
fi

setup_github() {
  read -r -p "Brand new keys? [Y/n] " response
  case "$response" in
    [nN][oO]|[nN])
      echo "Alright setup your own key"
      read -n 1 -s -r -p "Press any key to continue"
      change_dofiles_remote
      return
      ;;
  esac
  ssh-keygen -N "" -f ~/.ssh/github_rsa
  cat ~/.ssh/github_rsa.pub
  echo "Add that to github"
  read -n 1 -s -r -p "Press any key to continue"
  change_dofiles_remote
}
change_dofiles_remote() {
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
  if git remote -v | grep https ; then
    git remote remove origin
    git remote add origin git@github.com:mtfurlan/dotfiles.git
  fi
}

if [ ! -f ~/.ssh/github_rsa ]; then
  read -r -p "Setup github keys? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      setup_github
      ;;
  esac
fi

get_github_latest_release_file() {
  curl -s "$1/releases/latest" | sed "s/.*href=\"\(.*\)\">redirected.*/\1\/$2/"
}

install_tools() {
  sudo apt install python3-dev python3-pip python3-setuptools -y
  sudo pip3 install thefuck yq

  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf || true
  ~/.fzf/install --completion --key-bindings --no-update-rc

  wget -P ~/.local/bin $(get_github_latest_release_file https://github.com/akavel/up up)

  # TODO: update this, make it not run on wrong arch?
  if [ "$(uname -m)" == "x86_64" ]; then
    wget -P /tmp https://github.com/sharkdp/bat/releases/download/v0.10.0/bat_0.10.0_amd64.deb
    sudo dpkg -i /tmp/bat_0.10.0_amd64.deb
  else
    echo "can't install up for this arch, fix setup script"
  fi
}

read -r -p "install random tools(thefuck, yq, fzf, up)? [y/N] " response
case "$response" in
  [yY][eE][sS]|[yY])
    install_tools
    ;;
esac

echo "if it's a thinkpad, do battery management setup"
echo "    tpacpi-bat: https://github.com/teleshoes/tpacpi-bat"
echo "    TODO: https://github.com/morgwai/tpbat-utils-acpi"

