#!/bin/bash

################################################################################
#  Instantiate a satellite node with nix and our standard environment.
#  The main use case for this are worker nodes 
# 
#  Responds to environment variable:
#   MASTER - host name of MASTER node from which to copy configuration.
################################################################################

set -e

if [ "$MASTER" == "" ]; then
  MASTER=cutter.crest.iu.edu
  echo "Defaulting master node to: $MASTER"
fi
echo "Instantiating satellite/worker node, $HOSTNAME, from master ($MASTER)..."
echo "Running script from `pwd`"
echo ""
set -x
time rsync --delete -vrplt $MASTER:/nix/ /nix/

# --------------------------------------------------------------------------------
# Everything below works, but it is overcomplicated.  It tries to grab
# only the MINIMUM config.  But in many cases it is more efficent to
# just grab everything.
# --------------------------------------------------------------------------------

# if ! [ -e /nix/var ]; then
#   # This handles broken symlink
#   rm -rf /nix/var
#   # This is how we keep the user profiles in shared storage, but not the store:
#   ln -s $HOME/nix_var /nix/var
# fi
# if ! [ -e /nix/store ]; then
#   echo "Now instantiate the core packages we need:"
#   rsync -vrplt $MASTER:/nix/store/*user-environment /nix/store/
#   rsync -vrplt $MASTER:/nix/store/*-nix-*.* /nix/store/
# fi
# --------------------------------------------------------------------------------

# Don't do this anymore.  Just use rsync:
# --------------------------------------------------------------------------------
# scriptroot=`dirname $0`
# # And then we can run the normal installer to make sure we have everything:
# if [ -e $scriptroot/single_user_install_all.sh ]; then
#   cd $scriptroot/
# elif [ -e ./conf-mgmt/nix/single_user_install_all.sh ]; then
#   cd ./conf-mgmt/nix/
# elif [ -e $PBS_O_WORKDIR/conf-mgmt/nix/single_user_install_all.sh ]; then
#   cd $PBS_O_WORKDIR/conf-mgmt/nix/
# else
#   echo "Error, cannot find single_user_install script to run..."
#   exit 1
# fi
# 
# ./single_user_install_all.sh $*

# --------------------------------------------------------------------------------
# Minor, hacks to mark that we're done and sanity-check:
# --------------------------------------------------------------------------------
stamp=`date +"%Y_%m_%d-%H:%M:%S"`
file="$HOME"/update_satellites/"$HOSTNAME"_completed_update_"$stamp"
mkdir -p $HOME/update_satellites/
touch -p $file

# TEMP:
echo "TEMP: checking gcc versions: " >> $file
which -a gcc >> $file
ls ~/.nix-profile/bin/ >> $file

