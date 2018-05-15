#!/bin/bash

echo "trying to install things"

if [ -x "$(which apt-get)" ] ; then
  sudo apt-get install vim-nox tmux git sl silversearcher-ag curl tree
else
  echo "apt-get not installed, fix setup.sh for this platform"
fi
