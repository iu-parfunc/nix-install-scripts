#!/bin/bash

# JUST install nix from source.   Can be run standalone, or sourced into another script.

set -xe

source $(dirname $0)/CONSTANTS.sh

# Shorten:
VER=$NIX_VERSION_TO_INSTALL
URL=http://nixos.org/releases/nix/nix-$VER/nix-${VER}.tar.xz
wget $URL
tar xf nix-${VER}.tar.xz
cd nix-${VER}

./bootstrap.sh
./configure --enable-gc
g++ --version
make -j
sudo make install
