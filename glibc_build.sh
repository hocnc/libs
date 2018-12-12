#!/bin/bash

SRC="./glibc_src"
BUILD="./glibc_build"
VERSION="./glibc_versions"

if [[ $# < 2 ]]; then
    echo "Usage: $0 version #make-threads <-disable-tcache>"
    exit 1
fi


# Get glibc source
if [ -d "$SRC/glibc-$1" ]; then
    echo "Source glibc was dowloaded"
else
    mkdir -p "$SRC"
    cd "$SRC"
    wget "https://ftp.gnu.org/gnu/glibc/glibc-$1.tar.xz"
    tar -xf "glibc-$1.tar.xz"
    rm "glibc-$1.tar.xz"
fi

cd -

# Check glibc version
if [ -d "$VERSION/$1" ]; then
    echo "Glib version was built"
    exit 1
fi

# Build
if [ $# == 3 ] && [ "$3" = "-disable-tcache" ]; then
    TCACHE_OPT="--disable-experimental-malloc"
    SUFFIX="-no-tcache"
else
    TCACHE_OPT=""
    SUFFIX=""
fi

mkdir -p "$BUILD"
cd "$BUILD" && rm -rf ./*
../"$SRC/glibc-$1"/configure --prefix=/usr "$TCACHE_OPT" CFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -Wno-uninitialized" CXXFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -Wno-uninitialized"
make -j "$2" 
cd -

# Copy to version folder
mkdir -p "$VERSION/$1"
cp "$BUILD/libc.so" "$VERSION/$1/libc.so.6"
cp "$BUILD/elf/ld.so" "$VERSION/$1/ld-$1.so"
