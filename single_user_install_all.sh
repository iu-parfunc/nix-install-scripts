#!/bin/bash
set -xe

# This script is run from the lab_infrastructure repo:
REL=`dirname $0`
TOP=`(cd $REL; pwd)`

unset NIX_REMOTE

source $TOP/bits/our_package_set.sh

source $TOP/bits/setup_nix_local.sh
source $TOP/bits/setup_nix_global.sh
# source $TOP/bits/setup_nix_homedir.sh

echo "\nEverything looks good ($HOSTNAME).  Now the standard packages we expect:"
echo "============================================\n"
set -x

echo "NIX_PATH should be set: $NIX_PATH"

# Always use the latest packackages from our submodule
# time nix-env -f '<nixpkgs>' -i --cores 8 --max-jobs 20 $CIPKGS $*
