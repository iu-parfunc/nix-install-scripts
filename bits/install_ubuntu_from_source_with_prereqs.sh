#!/bin/bash

# Install Prereqs on Ubuntu THEN install from source.

set -xe

# May need to add this to PKG_CONFIG_PATH for libcrypto.pc:
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig/

sudo apt-get install -y wget xz-utils curl patch bzip2 libbz2-dev libcurl3-dev \
   autoconf automake pkg-config gcc g++ make \
   libssl-dev libcrypto++-dev \
   sqlite3 libsqlite3-dev liblzma-dev libgc-dev \
   libdbd-sqlite3-perl libwww-curl-perl

DIR=$(dirname $0)
source $DIR/install_from_source.sh
