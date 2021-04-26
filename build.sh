#!/usr/bin/env bash

set -euo pipefail

# User Parameters
# TODO: Default to all cores
N_CORES=${1:-4}

BUILD=$(date "+%Y-%m-%d")

ROOT="$HOME/code"
REPO="${ROOT}/emacs-native"
BREW_ROOT="/opt/homebrew"

if [ ! -d "$ROOT" ]; then
    echo "Creating ${ROOT}"
    mkdir "$ROOT"
fi

if [ ! -d "$REPO" ]; then
    git clone --depth 1 git@github.com:emacs-mirror/emacs.git "$REPO" -b feature/native-comp
else
    cd $REPO && git pull
fi

# TODO: Make gcc location user-configurable
export PATH="$BREW_ROOT/opt/gnu-sed/libexec/gnubin:${PATH}"
export CFLAGS="-I$BREW_ROOT/Cellar/gcc/10.2.0/include -O3"
export LDFLAGS="-L$BREW_ROOT/Cellar/gcc/10.2.0/lib/gcc/10 -I$BREW_ROOT/Cellar/gcc/10.2.0/include"
export LIBRARY_PATH="$BREW_ROOT/Cellar/gcc/10.2.0/lib/gcc/10:${LIBRARY_PATH:-}"

cd $REPO || exit

git clean -xfd

./autogen.sh

./configure \
     --with-ns \
     --with-native-compilation \
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
