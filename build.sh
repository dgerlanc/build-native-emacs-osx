#!/usr/bin/env bash

set -euo pipefail

# User Parameters
# TODO: Default to all cores
N_CORES=${1:-4}
GCC_VERSION="11.2.0"  # TODO: Scan for this if not provided
GCC_MAJOR_VERSION="11"  # TODO: Derive from GCC_VERSION

BUILD=$(date "+%Y-%m-%d")

ROOT="$HOME/code"
REPO="${ROOT}/emacs-28"
BREW_ROOT="/opt/homebrew"

if [ ! -d "$ROOT" ]; then
    echo "Creating ${ROOT}"
    mkdir "$ROOT"
fi

if [ ! -d "$REPO" ]; then
    git clone --depth 1 git@github.com:emacs-mirror/emacs.git "$REPO" -b emacs-28
else
    cd $REPO && git pull
fi

# TODO: Make gcc location user-configurable
export PATH="$BREW_ROOT/opt/gnu-sed/libexec/gnubin:${PATH}"
export CFLAGS="-I$BREW_ROOT/Cellar/gcc/$GCC_VERSION/include -O3"
export LDFLAGS="-L$BREW_ROOT/Cellar/gcc/$GCC_VERSION/lib/gcc/$GCC_MAJOR_VERSION -I$BREW_ROOT/Cellar/gcc/$GCC_VERSION/include"
export LIBRARY_PATH="$BREW_ROOT/Cellar/gcc/$GCC_VERSION/lib/gcc/$GCC_MAJOR_VERSION:${LIBRARY_PATH:-}"

cd $REPO || exit

git clean -xfd

./autogen.sh

./configure \
     --prefix=/usr/local/opt/gccemacs-${BUILD} \
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
