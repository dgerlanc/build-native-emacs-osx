#!/usr/bin/env bash

# native-comp optimization
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:${PATH}"
export CFLAGS="-I/usr/local/Cellar/gcc/10.2.0/include -O3 -march=native"
export LDFLAGS="-L/usr/local/Cellar/gcc/10.2.0/lib/gcc/10 -I/usr/local/Cellar/gcc/10.2.0/include"
export LIBRARY_PATH="/usr/local/Cellar/gcc/10.2.0/lib/gcc/10:${LIBRARY_PATH:-}"

cd ~/code/emacs-native || exit

git clean -xfd

./autogen.sh

make clean

./configure \
     --prefix=/usr/local/opt/gccemacs \
     --enable-locallisppath=/usr/local/share/emacs/28.0.50/site-lisp \
     --with-ns \
     --with-nativecomp \
     --disable-ns-self-contained \
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

# missing freetype, otf

# comp-speed 3 may introduce dangerous optimizations
make -j4 BYTE_COMPILE_EXTRA_FLAGS='--eval "(setq comp-speed 2)"'

# # Ensure /usr/local/opt/gccemacs exists
rm -rf /usr/local/opt/gccemacs
mkdir /usr/local/opt/gccemacs

# # Ensure the directory to which we will dump Emacs exists and has the correct
# # permissions set.
# libexec=/usr/local/libexec/emacs/28.0.50
# if [ ! -d $libexec ]; then
#   sudo mkdir -p $libexec
#   sudo chown $USER $libexec
# fi

make install

# cd /usr/local/bin || exit
# rm emacs
# rm emacsclient
# ln -s /usr/local/opt/gccemacs/bin/emacs .
# ln -s /usr/local/opt/gccemacs/bin/emacsclient .

# rm -rf "/Applications/Emacs.app"
# mv nextstep/Emacs.app "/Applications/"


# cd /Applications/Emacs.app/Contents || exit
# ln -s /usr/local/opt/gccemacs/share/emacs/28.0.50/lisp .
