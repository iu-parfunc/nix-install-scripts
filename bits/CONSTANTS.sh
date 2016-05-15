
# This selects some default packages from a default package set we use.
# Source this file, don't run it.
# --------------------------------

# Record the parfunc group's current "standard" version of the nix pkg
# manager that we expect people to use.

# Source me from other scripts.

export NIX_VERSION_TO_INSTALL=1.11.2

# ---------------------------------------

# Now we just use a mix of different releases, just like we use Stackage LTS versions:
# export NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/16.03.tar.gz

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
#
# CIPKGS+=" coreutils binutils gnused which gnumake automake autoconf bash "
