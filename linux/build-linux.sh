#!/usr/bin/env bash

set -eu
set -o pipefail

# User Parameters
N_CORES=${1:-4}
VERSION="29.1"

ROOT="$HOME/code"
REPO="${ROOT}/emacs-${VERSION}"

if [ ! -d "$ROOT" ]; then
    echo "Creating ${ROOT}"
    mkdir "$ROOT"
fi

cd $REPO || exit

echo "Running configure"
./configure \
     --prefix="/opt/emacs-${VERSION}" \
     --with-native-compilation \
     --with-x-toolkit=gtk3 \
     --with-cairo \
     --with-threads \
     --with-modules \
     --with-xml2 \
     --with-gnutls \
     --with-libotf \
     --with-json \
     --with-tree-sitter \
     --with-rsvg \
     --with-jpeg \
     --with-png \
     --with-tiff \
     --without-pop
#     --with-xwidgets \

make -j "${N_CORES}"

# This performs full ahead-of-time compilation
# NOTE: comp-speed 3 may introduce dangerous optimizations
# make -j${N_CORES} NATIVE_FULL_AOT=1 BYTE_COMPILE_EXTRA_FLAGS='--eval "(setq comp-speed 2)"'

# make install-eln
# make install
