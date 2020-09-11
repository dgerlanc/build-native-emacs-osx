#!/usr/bin/env bash


BUILD=$(date "+%Y-%m-%d")

ROOT="$HOME/code"
REPO="${ROOT}/emacs-native"

mkdir "$ROOT" >/dev/null 2>/dev/null

if [ ! -d "$REPO" ]; then
    git clone --depth 1 git@github.com:emacs-mirror/emacs.git "$REPO" -b feature/native-comp
else
    cd $REPO && git pull
fi

export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:${PATH}"
export CFLAGS="-I/usr/local/Cellar/gcc/10.2.0/include -O3 -march=native"
export LDFLAGS="-L/usr/local/Cellar/gcc/10.2.0/lib/gcc/10 -I/usr/local/Cellar/gcc/10.2.0/include"
export LIBRARY_PATH="/usr/local/Cellar/gcc/10.2.0/lib/gcc/10:${LIBRARY_PATH:-}"

cd $REPO || exit

git clean -xfd

./autogen.sh

./configure \
     --prefix=/usr/local/opt/gccemacs-${BUILD} \
     --enable-locallisppath=/usr/local/opt/gccemacs-${BUILD}/share/emacs/28.0.50/site-lisp \
     --with-ns \
     --disable-ns-self-contained \
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
make -j4 NATIVE_FULL_AOT=1 BYTE_COMPILE_EXTRA_FLAGS='--eval "(setq comp-speed 2)"'

make install-eln
make install

cd /usr/local/bin || exit
rm emacs
rm emacsclient
ln -s /usr/local/opt/gccemacs-${BUILD}/bin/emacs .
ln -s /usr/local/opt/gccemacs-${BUILD}/bin/emacsclient .

# Rename existing Emacs.app
APP = "/Applications/Emacs.app"
if [ -d "$APP" ]; then
    mv $APP "/Applications/Emacs-$BUILD.app"
fi

# Move Emacs.app to /Applications
if [ -d "${REPO}/nextstep/Emacs.app" ]; then
    mv "${REPO}/nextstep/Emacs.app" "/Applications/"

    cd /Applications/Emacs.app/Contents || exit
    ln -s /usr/local/opt/gccemacs-${BUILD}/lib/emacs/28.0.50/native-lisp .
    ln -s /usr/local/opt/gccemacs-${BUILD}/share/emacs/28.0.50/lisp .
fi
