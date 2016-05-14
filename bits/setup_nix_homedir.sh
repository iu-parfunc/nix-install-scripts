
# NOTE: this is actually a home directory setup thing, but it depends on nix-channel:
nixChanCmd=`echo /nix/store/*-nix-1*/bin/nix-channel | awk '{ print $1 }' `
if [ "$nixChanCmd" == "" ]; then
  echo "Could not find nix-channel!"
  exit 1
fi
set -x
if ! [ -e $HOME/.nix-defexpr/channels ]; then
  $nixChanCmd --add http://nixos.org/channels/nixpkgs-unstable
  # This creates ~/.nix-defexpr:
  $nixChanCmd --update
fi

if ! [ -e /nix/var/nix/profiles/per-user/$USER/default ]; then
    ln -s /nix/var/nix/profiles/per-user/$USER/channels /nix/var/nix/profiles/per-user/$USER/default
fi
if ! [ -e $HOME/.nix-profile ]; then
    ln -s -f /nix/var/nix/profiles/per-user/$USER/default $HOME/.nix-profile 
fi

# ------------------------------------------------------------
set +x
echo "At this point, nix-env should be ready to run in single-user mode."
# Build the standard one from the channel:
set -x
nixEnvCmd=`echo /nix/store/*-nix-1*/bin/nix-env | awk '{ print $1 }' `
$nixEnvCmd -q
# /nix/store/*-nix-1*/bin/nix-env -f $HOME/.nix-defexpr/ -i nix
# /nix/store/*-nix-1*/bin/nix-env -f $HOME/nixpkgs -i nix

echo "Single-user nix-command completed; loading up environment from nix.sh."
source $HOME/.nix-profile/etc/profile.d/nix.sh

export PATH=$PATH:$HOME/.nix-profile/bin
if [ `which nix-env` == "" ]; then
  echo 'Error, could not fixnd nix-env!'
  exit 1
fi

