#!/bin/bash
set -euo pipefail

Red="$(tput setaf 1)"
None="$(tput sgr0)"

clone_or_pull() {
    if [ -d "$1" ]; then
        pushd "$1"
        git pull
        popd
    else
        git clone $2
    fi
}


mkdir -p ~/kicad/official_libs
mkdir -p ~/kicad/debian
pushd ~/kicad
clone_or_pull "digikey-kicad-library" "git@github.com:Digi-Key/digikey-kicad-library.git"
pushd official_libs
clone_or_pull "kicad-footprints" "git@github.com:KiCad/kicad-footprints.git"
clone_or_pull "kicad-packages3D" "git@github.com:KiCad/kicad-packages3D.git"
clone_or_pull "kicad-symbols" "git@github.com:KiCad/kicad-symbols.git"
clone_or_pull "kicad-templates" "git@github.com:KiCad/kicad-templates.git"

# make a kicad-libraries dummy package
cat > ~/kicad/debian/kicad-libraries-dummy <<EOF
# Source: <source package name; defaults to package name>
Section: misc
Priority: optional
# Homepage: <enter URL here; no default>
Standards-Version: 3.9.2

Package: kicad-libraries-dummy
# Version: <enter version here; defaults to 1.0>
Maintainer: Mark Furland <mtfurlan@i3detroit.org>
Depends: kicad
Provides: kicad-libraries
Description: fake kicad libraries cause I use git
EOF
pushd ~/kicad/debian
equivs-build kicad-libraries-dummy
sudo dpkg -i ./kicad-libraries-dummy*.deb


echo "${Red}edit ~/.config/kicad/kicad_common to have the EnvironmentVariables section look like${None}"
cat <<EOF

DIGIKEY_KICAD_LIBRARY=/home/mark/kicad/digikey-kicad-library
KICAD_SYMBOL_DIR=/home/mark/kicad/official_libs/kicad-symbols
KISYS3DMOD=/home/mark/kicad/official_libs/kicad-packages3D
KISYSMOD=/home/mark/kicad/official_libs/kicad-footprint
KICAD_PTEMPLATES=/home/mark/kicad/official_libs/kicad-templates
# don't modify these in the file
KIGITHUB=https://github.com/KiCad
KICAD_TEMPLATE_DIR=/usr/share/kicad/template
KICAD_USER_TEMPLATE_DIR=/home/mark/template

EOF

echo "start kicad, open the symbol and footprint library things so it asks you to copy a default lib table"
echo "in the symbol library, add by directory and add all the digikey library stuff"

echo "${Red}add this to the ~/.config/kicad/fp-lib-table${None}"
cat <<EOF
  (lib (name Digi-Key)(type KiCad)(uri \${DIGIKEY_KICAD_LIBRARY}/digikey-footprints.pretty/)(options "")(descr ""))
EOF
