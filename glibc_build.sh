#!/bin/bash

SRC="./glibc_src"
BUILD="./glibc_build"
VERSION="./glibc_versions"

if [[ $# < 2 ]]; then
    echo "Usage: $0 version #make-threads <-disable-tcache>"
    exit 1
fi


# Get glibc source
if [ -d "$SRC/$1" ]; then
    cd "$SRC/$1"
    git pull --all
else
    git clone git://sourceware.org/git/glibc.git "$SRC/$1"
    cd "$SRC/$1"
    git pull --all
fi

# Checkout release
git rev-parse --verify --quiet "remotes/origin/release/$1/master"
if [[ $? != 0 ]]; then
    echo "Error: Glib version does not seem to exists"
    exit 1
fi

git checkout "remotes/origin/release/$1/master"
cd -

# Build
if [ $# == 3 ] && [ "$3" = "-disable-tcache" ]; then
    TCACHE_OPT="--disable-experimental-malloc"
    SUFFIX="-no-tcache"
else
    TCACHE_OPT=""
    SUFFIX=""
fi

mkdir -p "$BUILD/$1"
cd "$BUILD/$1" && rm -rf ./*
../../"$SRC/$1"/configure --prefix=/usr "$TCACHE_OPT" CFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -Wno-uninitialized" CXXFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -Wno-uninitialized"
make -j "$2" 
cd -

# Copy to version folder
mkdir -p "$VERSION/$1"
cp "$BUILD/$1/libc.so" "$VERSION/$1/libc-$SUFFIX.so"
cp "$BUILD/$1/elf/ld.so" "$VERSION/$1/ld-$SUFFIX.so"
