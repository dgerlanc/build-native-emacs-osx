#!/usr/bin/env bash

set -euo pipefail

# User Parameters
# TODO: Default to all cores
N_CORES=${1:-4}

BUILD=$(date "+%Y-%m-%d")

ROOT="$HOME/code"
REPO="${ROOT}/emacs-native"

if [ ! -d "$ROOT" ]; then
    echo "Creating ${ROOT}"
    mkdir "$ROOT"
fi

if [ ! -d "$REPO" ]; then
    echo "Cloning git repo"
    git clone --depth 1 git@github.com:emacs-mirror/emacs.git "$REPO" -b feature/native-comp
else
    echo "Updating git repo"
    cd $REPO && git pull
fi

cd $REPO || exit

echo "Cleaning $REPO"
git clean -xfd

export CFLAGS="-O3 -march=native"

./autogen.sh # all

echo "Running configure"
./configure \
     --prefix=/usr/local/opt/gccemacs-${BUILD} \
     --with-nativecomp \
     --with-cairo \
     --with-threads \
     --with-modules \
     --with-xml2 \
     --with-gnutls \
     --with-libotf \
     --with-json \
     --with-rsvg \
     --with-jpeg \
     --with-png \
     --with-tiff

# comp-speed 3 may introduce dangerous optimizations
make -j${N_CORES} NATIVE_FULL_AOT=1 BYTE_COMPILE_EXTRA_FLAGS='--eval "(setq comp-speed 2)"'

make install-eln
make install

