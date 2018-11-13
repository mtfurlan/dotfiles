#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
cd $(dirname "$0")

echo "trying to install things"

if [ -x "$(which apt-get)" ] ; then
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


echo "run 'pip install yq' to get the sshScanSubnet function"
echo "run 'npm i -g diff-so-fancy' for git diff to work better"
