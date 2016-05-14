
# This selects some default packages from a default package set we use.

# Source this file, don't run it.
# --------------------------------

# We used to use our own checkout of nixpkgs:
# export NIX_PATH=$HOME/nixpkgs

# Now we just use a mix of different releases, just like we use Stackage LTS versions:
export NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/16.03.tar.gz


# Here it is, the list of packages we expect to be on our Continuous
# integration machines.  Feel free to extend this list with more
# packages that do not conflict with the current ones.
CIPKGS=" stdenv "

# Removed pkgs:
# ghc-7.8.3-wrapper cabal-install-1.20.0.3 \
# ocaml smlnj manticore racket \
# htop
#  gcc-wrapper-4.8.3 gcc-wrapper-4.9.1 \
#  ghc-7.4.2-wrapper
#  libevent-2.0.21 \

# On Cutter we need to install openSSL lib to get some headers:
# CIPKGS+=" openssl "
# errors currently: bad tarball:
# weighttp-0.3

# Cutter worker nodes are really stripped down:
#CIPKGS+=" git cmake time "

# Finally, if we're going to BUILD SOFTWARE against the nix-installed
# libs and headers, we need to create a complete software universe.
#
# Otherwise we run into errors like this one due to mismatches in old
# and new core software like the linker:
#
#     Inconsistency detected by ld.so: dl-close.c: 759: _dl_close: Assertion `map->l_init_called' failed!
#
# CIPKGS+=" coreutils binutils gnused which gnumake automake autoconf bash "
