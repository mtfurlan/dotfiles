#!/usr/bin/env bash

# this is intended to be sourced to get functions

get_github_latest_release() {
  curl -s "$1/releases/latest" | sed 's/.*href=".*tag.\(.*\)">redirected.*/\1/'
}
get_github_latest_release_file() {
  repoURL=$1
  releaseFilename=$2
  remove_v=${3:-false}
  ver=$(get_github_latest_release "$repoURL")
  #do we remove v from ver in filename
  if [ "$remove_v" = true ]; then
    ver=${ver/v/}
  fi
  releaseFilename=${releaseFilename/VER/$ver}
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
    pushd "$dir" >/dev/null || die "failed to pusd $dir for cloneAndPull $repo"
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
    popd >/dev/null || die "failed to popd cloneAndPull $repo"
  fi
}
