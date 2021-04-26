#!/usr/bin/env bash

set -euo pipefail

# User Parameters
# TODO: Default to all cores
N_CORES=${1:-4}

BUILD=$(date "+%Y-%m-%d")

ROOT="$HOME/code"
REPO="${ROOT}/emacs"

if [ ! -d "$ROOT" ]; then
    echo "Creating ${ROOT}"
    mkdir "$ROOT"
fi

if [ ! -d "$REPO" ]; then
    git clone --depth 1 git@github.com:emacs-mirror/emacs.git "$REPO" -b master
else
    cd $REPO && git pull
fi

export PATH="/opt/homebrew/gnu-sed/libexec/gnubin:${PATH}"
export CFLAGS="-O3" # -march=native"

cd $REPO || exit

git clean -xfd

./autogen.sh

./configure \
     --with-ns \
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

make -j${N_CORES}

make install

