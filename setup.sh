#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

help() {
  echo "Usage: $0 [OPTION]"
  echo "install stuff, setup github keys, download random tools"
  echo "       -n, --new"
  echo "                new computer"
  echo "       -s, --symlink"
  echo "                symlink rc files"
  echo "           --install-tools"
  echo "                install extra tools like thefuck; gh; fpp;"
  echo "       -u, --update-tools"
  echo "                update tools;"
  echo "           --guest"
  echo "                don't put personal files in"
  echo "       -g, --checkGithub"
  echo "                check/setup github_rsa"
  echo "       -h, --help"
  echo "                display this help"
}

if [ $# -eq 0 ]; then
  echo "no arguments passed"
  help
  exit 1;
fi


# getopt short options go together, long options have commas
TEMP=$(getopt -o nsghu --long new,symlink,update-tools,install-tools,checkGithub,help,guest -n 'test.sh' -- "$@")
# shellcheck disable=SC2181
if [ $? != 0 ] ; then
    echo "Something wrong with getopt" >&2
    exit 1
fi
eval set -- "$TEMP"

new=false
symlink=false
installTools=false
updateTools=false
checkGithub=false
guest=false
while true ; do
    case "$1" in
        -n|--new) new=true ; shift ;;
        -s|--symlink) symlink=true ; shift ;;
        --install-tools) installTools=true ; shift ;;
        -u|--update-tools) updateTools=true ; shift ;;
        --guest) guest=true ; shift ;;
        -g|--checkGithub) checkGithub=true ; shift ;;
        -h|--help) help ; exit 0 ;;
        --) shift ; break ;;
        *) echo "bad arg $1" ; exit 1 ;;
    esac
done


setup_github() {
  read -r -p "Brand new keys? [Y/n] " response
  case "$response" in
    [nN][oO]|[nN])
      echo "Alright setup your own key"
      read -n 1 -s -r -p "Press any key to continue"
      echo ""
      verify_github_remote
      return
      ;;
  esac
  ssh-keygen -N "" -f ~/.ssh/github_rsa
  cat ~/.ssh/github_rsa.pub
  echo "Add that to github"
  read -n 1 -s -r -p "Press any key to continue"
  echo ""
  verify_github_remote
}

verify_github_remote() {
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



change_dofiles_remote() {
  if git remote -v | grep https ; then
    read -r -p "Change github remote to not be https? [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY])
          git remote remove origin
          git remote add origin git@github.com:mtfurlan/dotfiles.git
        ;;
    esac
  fi
}

get_github_latest_release() {
  curl -s "$1/releases/latest" | sed 's/.*href=".*tag.\(.*\)">redirected.*/\1/'
}
get_github_latest_release_file() {
  repoURL=$1
  releaseFilename=$2
  ver=$(get_github_latest_release "$repoURL")
  #remove v from ver in filename because slackcat
  releaseFilename=${releaseFilename/VER/${ver/v/}}
  echo "$repoURL/releases/download/$ver/$releaseFilename"
}

installDebGH() {
  package=$1
  repo=$2
  debString=$3

  echo
  echo "installing or updating $package from github/$repo"

  version=$(curl -s "https://github.com/$repo/releases/latest" | sed 's/.*releases\/tag\/v\([0-9.]*\)">redirected.*/\1/')
  installedVersion=$(dpkg -s "$package" 2>/dev/null | grep Version | sed 's/Version: //') || true

  if [ "$installedVersion" != "$version" ]; then
    echo "VERSION MISMATCH: $package version: $version, installedVersion: $installedVersion"

    #check arch
    case "$(uname -m)" in
      "x86_64")
        arch="amd64" ;;
      *)
        echo "can't install $package for this arch($(uname -m)), fix setup script"
        return 1
        ;;
    esac

    #actually install
    # shellcheck disable=SC2016
    deb=$(echo "$debString" | PKG="$package" VER="$version" ARCH="$arch" envsubst '${PKG} ${VER} ${ARCH}')

    wget -q -O "/tmp/$deb" "https://github.com/$repo/releases/download/v$version/$deb"
    echo "installing $deb"
    sudo dpkg -i "/tmp/$deb"
  fi
}

cloneAndPull() {
  repo=$1
  dir=$2

  echo

  if [ ! -d "$dir" ]; then
    echo "cloning $repo to $dir"
    git clone --depth 1 "$repo" "$dir" >/dev/null
  else
    echo "updating git $dir - $repo"
    pushd "$dir" >/dev/null
    # shellcheck disable=SC2046
    latestTag="$(git describe --tags $(git rev-list --tags --max-count=1) 2>/dev/null || true)"
    if [ -n "$latestTag" ]; then
      echo "checking out '$latestTag'"
      git checkout "$latestTag" &>/dev/null
    else
      curBranch=$(git rev-parse --abbrev-ref HEAD)
      echo "pulling '$curBranch'"
      git pull >/dev/null
    fi
    popd >/dev/null
  fi
}

update_tools() {
  sudo pip3 install --upgrade thefuck yq

  # shellcheck disable=SC2016
  installDebGH bat 'sharkdp/bat' '${PKG}_${VER}_${ARCH}.deb'
  # shellcheck disable=SC2016
  installDebGH gh 'cli/cli' '${PKG}_${VER}_linux_${ARCH}.deb'
  gh completion > ~/.gh-completion

  cloneAndPull https://github.com/junegunn/fzf.git ~/src/fzf
  ~/src/fzf/install --completion --key-bindings --no-update-rc >/dev/null

  cloneAndPull https://github.com/mtfurlan/rpisetup.git ~/src/rpisetup
  mkdir -p ~/.local/bin
  ln -s ~/src/rpisetup/rpisetup ~/.local/bin/rpisetup 2>/dev/null || true

  mkdir -p ~/.local/bin
  wget -q -O ~/.local/bin/up "$(get_github_latest_release_file https://github.com/akavel/up up)"
  chmod +x ~/.local/bin/up
  wget -q -O ~/.local/bin/diff-so-fancy https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
  chmod +x ~/.local/bin/diff-so-fancy


  #check arch
  case "$(uname -m)" in
    "x86_64")
      arch="amd64" ;;
    *)
      echo "can't install $package for this arch($(uname -m)), fix setup script"
      return 1
      ;;
  esac

  wget -q -O ~/.local/bin/slackcat "$(get_github_latest_release_file "https://github.com/bcicen/slackcat" "slackcat-VER-linux-$arch")"
  chmod +x ~/.local/bin/slackcat
}

install_tools() {
  sudo apt-get install python3-dev python3-pip python3-setuptools jq -y

  cloneAndPull https://github.com/facebook/PathPicker.git ~/src/PathPicker
  pushd ~/src/PathPicker/debian >/dev/null
  ./package.sh
  sudo dpkg -i ../fpp_*.deb
  popd >/dev/null

  update_tools
}


new_computer() {
  echo "updating and installing things from apt"

  if command -v apt-get >/dev/null ; then
    if ! grep --quiet non-free /etc/apt/sources.list; then
      echo "/etc/apt/sources.list doesn't have nonfree"
      echo "exit when you're happy"
      bash --rcfile <(echo "PS1='subshell > '") -i
    fi
    sudo apt-get update
    sudo apt-get install vim-nox tmux git sl silversearcher-ag curl tree bash-completion rcm rename wget
  else
    echo "apt-get not installed, fix setup.sh for this platform"
  fi
}

# checks for ~/.ssh_github_rsa, and will change the dotfile remote to be git not https
check_github() {
  if [ ! -f ~/.ssh/github_rsa ]; then
    read -r -p "Setup github keys? [y/N] " response
    case "$response" in
      [yY][eE][sS]|[yY])
        setup_github
        ;;
    esac
  else
    verify_github_remote
  fi
}

ask_install_tools() {
  if [ "$installTools" = true ]; then
    return
  fi
  read -r -p "install extra tools(thefuck, yq, fzf, up)? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      installTools=true
      ;;
  esac
}

symlinks() {
  echo "making symlinks with rcup from rcm"
  # use rcm, do a dry run
  # so this is overly complex, but whatever.
  # I want to do things like symlink parts of the .vim dir, but not all parts, link the bin dir but without a dot, and exclude setup.sh and README

  # vim dir intended symlinks:
  #   /home/mark/.vim/bundle/Vundle.vim:/home/mark/.dotfiles/vim/bundle/Vundle.vim
  #   /home/mark/.vim/filetype.vim:/home/mark/.dotfiles/vim/filetype.vim
  #   /home/mark/.vim/ftdetect:/home/mark/.dotfiles/vim/ftdetect
  #   /home/mark/.vim/ftplugin:/home/mark/.dotfiles/vim/ftplugin
  #   /home/mark/.vim/spell:/home/mark/.dotfiles/vim/spell
  #   /home/mark/.vim/syntax:/home/mark/.dotfiles/vim/syntax
  # I want to only link Vundle, so all other plugins aren't in version control.
  # Should probably update vundle someday.
  # Everything else, like spelling and extra filetype plugins I want in version control

  # this probably assumes it's in the ~/.dotfiles dir

  # "guest" mode because I keep using this on pis I hand out
  # dont' link ssh config or git config.
  if [ "$guest" = true ]; then
    link_exclude="-x ssh -x gitconfig"
  else
    link_exclude=""
  fi

  # shellcheck disable=SC2086
  SYMLINK_DIRS="vim/bundle/Vundle.vim $(find vim -maxdepth 1 -type d | grep -v bundle | tail -n +2) bin" lsrc -U bin -x setup.sh -x README.md $link_exclude
  read -r -p "that look good? [Y/n] " response
  case "$response" in
    [yY][eE][sS]|[yY]|"")
      ;; # don't exit, script continues
    *)
      echo "good luck, bye"
      exit 1;;
  esac
  # shellcheck disable=SC2086
  SYMLINK_DIRS="vim/bundle/Vundle.vim $(find vim -maxdepth 1 -type d | grep -v bundle | tail -n +2) bin" rcup -v -U bin -x setup.sh -x README.md $link_exclude
}

## execution starts here
if [ "$new" = true ]; then
  echo "new computer"
  new_computer

  symlink=true
  checkGithub=true

  ask_install_tools

  echo "if it's a thinkpad, do battery management setup"
  echo "    tpacpi-bat: https://github.com/teleshoes/tpacpi-bat"
  echo "    TODO: https://github.com/morgwai/tpbat-utils-acpi"

fi

if [ "$installTools" = true ]; then
  install_tools
fi
if [ "$updateTools" = true ]; then
  update_tools
fi
if [ "$symlink" = true ]; then
  symlinks
fi
if [ "$checkGithub" = true ]; then
  check_github
fi
