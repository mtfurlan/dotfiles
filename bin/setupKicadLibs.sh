#!/bin/bash
set -euo pipefail

clone_or_pull() {
    if [ -d "$1" ]; then
        pushd "$1"
        git pull
        popd
    else
        git clone $2
    fi
}


#mkdir -p ~/kicad/official_libs
#pushd ~/kicad
#clone_or_pull "digikey-kicad-library" "git@github.com:Digi-Key/digikey-kicad-library.git"
#pushd official_libs
#clone_or_pull "kicad-footprints" "git@github.com:KiCad/kicad-footprints.git"
#clone_or_pull "kicad-packages3D" "git@github.com:KiCad/kicad-packages3D.git"
#clone_or_pull "kicad-symbols" "git@github.com:KiCad/kicad-symbols.git"
#clone_or_pull "kicad-templates" "git@github.com:KiCad/kicad-templates.git"

echo "edit ~/.config/kicad/kicad_local to have the EnvironmentVariables section look like"
cat <<EOF

DIGIKEY_KICAD_LIBRARY=/home/mark/kicad/digikey-kicad-library
KICAD_SYMBOL_DIR=/home/mark/kicad/official_libs/kicad-symbols
KIGITHUB=https://github.com/KiCad
KISYS3DMOD=/home/mark/kicad/official_libs/kicad-packages3D
KISYSMOD=/home/mark/kicad/official_libs/kicad-footprint
KICAD_PTEMPLATES=/home/mark/kicad/official_libs/kicad-templates
KICAD_TEMPLATE_DIR=/home/mark/kicad/official_libs/kicad-templates
KICAD_USER_TEMPLATE_DIR=/home/kicad/template

EOF

echo "add this to the ~/.config/kicad/fp-lib-table"
cat <<EOF
  (lib (name Digi-Key)(type KiCad)(uri \${DIGIKEY_KICAD_LIBRARY}/digikey-footprints.pretty/)(options "")(descr ""))
EOF
