#!/bin/bash
set -xe

# This script currently assumes sudo and uses standard nix builders.
# So it doesn't need to worry about using a group account
# NIXUSR=parfunc
# NIXGRP=beehive

# This script is run from the lab_infrastructure repo:
REL=`dirname $0`
TOP=`(cd $REL; pwd)`

unset NIX_REMOTE

echo "Running local nix homedir setup:"
source $TOP/bits/setup_nix_local.sh

# Temporarily put the user in control of the nix dirs:
set -x
sudo chown -R $USER /nix/store /nix/var || echo ok
set +x

echo "Now proceeding with global setup."

if ! [ -d /nix/store ]; then
  echo "In multi-user install mode, but no /nix/store so running the basic setup:"
  source $TOP/bits/setup_nix_global.sh
fi

# A third step:
source $TOP/bits/setup_nix_homedir.sh

# ----------------------------------------
echo
echo "Now we change the single-user install into a multi-user one..."

# After this point we should have actually run the installer,
# but /nix/* is owned by the current user.
# ----------------------------------------

# Kill previous daemons, if any:
sudo killall nix-daemon || echo ok
  # x=`ps | grep nix-daemon | wc -l`
  # if [ "$x" == 0 ]; then

echo
echo "Now we set up the special group and build users..."

idbase=470
if ! grep nixbld: /etc/group; then
#  sudo addgroup --gid 30000 nixbld
  echo "Did not find group nixbld, so creating."
  sudo groupadd --gid $idbase nixbld
fi

NBUILDERS=15
#for ((i=1; i<=$NBUILDERS; i++));
for i in $(seq -f "%02g" 1 15);
do
  user=nixbld"$i"
  if ! grep $user /etc/passwd; then
    echo "Did not find user $user, so creating."
    set -x
    # Non-portable: --disabled-password
#    sudo adduser $user --gid $idbase \
#     --uid $((idbase + i)) --no-create-home --home /var/empty --shell /noshell \
#     -c "Nix build user $i"
##      --gecos "Nix build user $i" $user
    sudo useradd -c "Nix build user $n" \
      -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(which nologin)" \
      nixbld"$i";
    sudo usermod -a -G nixbld nixbld"$i"
    set +x
  fi
done

# With those groups we can now setup proper permissions:
# ------------------------------------------------------
echo "Now changing the installation to multi-user mode..."
  set -x
  sudo chown -R root.nixbld /nix/store
  sudo chmod 1775 /nix/store

  # If there ARE preexisting profile directories, set up ownership properly.
  perUserProfs=
  perUserRoots=
  if [ -e /nix/var/nix/profiles/per-user/ ];
  then perUserProfs=`ls /nix/var/nix/profiles/per-user/`; fi
  if [ -e /nix/var/nix/gc-roots/per-user/ ];
  then perUserRoots=`ls /nix/var/nix/gc-roots/per-user/`; fi

  sudo chown -R root.nixbld /nix/var
  sudo chmod ugo+rX -R /nix/var
  sudo mkdir -p /nix/var/nix/profiles/per-user
  sudo mkdir -p /nix/var/nix/gcroots/per-user
  sudo chmod 1777 /nix/var/nix/profiles/per-user
  sudo chmod 1777 /nix/var/nix/gcroots/per-user
  sudo chmod g+w /nix/var/nix/profiles
  for dir in $perUserProfs ; do
      sudo chown -R $dir /nix/var/nix/profiles/per-user/$dir
  done
  for d in $perUserRoots ; do
      sudo chown -R $dir /nix/var/nix/gc-roots/per-user/$dir
  done
  set +x


DAEMON=`ls /nix/store/*nix*/bin/nix-daemon | head -n1`

echo "Expecting to run this daemon: $DAEMON"

if ! [ -e /etc/nix/nix.conf ]; then
    set -x
    sudo mkdir -p /etc/nix/
    echo "build-users-group = nixbld" | sudo tee /etc/nix/nix.conf
    sudo chmod ugo+rX /etc/nix /etc/nix/nix.conf
    set +x
fi

if ! grep $DAEMON /etc/rc.local; then
    echo "Did not find this exact version of the daemon in /etc/rc.local: $DAEMON"
#    TMPRC=`tempfile`
#    grep -v nix-daemon /etc/rc.local > $TMPRC
#    ^ This is hard to update automatically because it should end with "exit 0"
    echo "Please add nix-daemon invocation to rc.local....  Press a key to continue."
    read
fi


set +x
echo; echo "/nix/ should be set up in multi-user mode.  Now try to start the daemon."
echo "============================================"
set -x
sudo $DAEMON &
echo "Is it running?"
ps aux | grep -i nix-daemon

set +x
echo; echo "The multi-user install is done, but let's set up our ~/.nix-profile and test it."
echo "============================================"
set -x

export NIX_REMOTE=daemon

# Grab our default settings:
source $TOP/bits/our_package_set.sh



# If the symlink has broken for our .nix-profile (or if it points to
# the global rather than the per-user location), then we fix it here:
rm -f ~/.nix-profile
# if ! [ -e ~/.nix-profile/bin ]; then
#  echo ".nix-profile isn't there or is broken."
  if [ -e  /nix/var/nix/profiles/per-user/$USER/default ]; then
    set -x
    ln -s -f /nix/var/nix/profiles/per-user/$USER/default $HOME/.nix-profile
    nixEnvCmd=`echo /nix/store/*-nix-1*/bin/nix-env | awk '{ print $1 }' `
    # $nixEnvCmd -iA nixpkgs.bash
    nix-channel --update
    set +x
  else
    echo "ERROR: ~/.nix-profile not present but /nix/var/nix/profiles/per-user/$USER/default not preset yet either!"
    exit 1
  fi
# fi


set +x
echo; echo "Everything looks good ($HOSTNAME).  Now the big install:"
echo "============================================"
set -x


# TODO: Add something like this and make it globally accessible:

# From https://gist.github.com/joepie91/043a51a7b70be5f50f1d 
nix-setup-user() {
        TARGET_USER="$1"
        SYMLINK_PATH="/home/$TARGET_USER/.nix-profile"
        PROFILE_DIR="/nix/var/nix/profiles/per-user/$TARGET_USER"

        echo "Creating profile $PROFILE_DIR..."
        echo "Profile symlink: $SYMLINK_PATH"

        rm "$SYMLINK_PATH"
        mkdir -p "$PROFILE_DIR"
        chown "$TARGET_USER:$TARGET_USER" "$PROFILE_DIR"

        ln -s "$PROFILE_DIR/profile" "$SYMLINK_PATH"
        chown -h "$TARGET_USER:$TARGET_USER" "$SYMLINK_PATH"

        echo "export NIX_REMOTE=daemon" >> "/home/$TARGET_USER/.bashrc"
        echo ". /usr/local/etc/profile.d/nix.sh" >> "/home/$TARGET_USER/.bashrc"

        su -lc "cd; . /usr/local/etc/profile.d/nix.sh; NIX_REMOTE=daemon nix-channel --update" "$TARGET_USER"
}




