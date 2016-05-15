# This (partial) file is included from other files to install nix.

# ------------------------------------------------------------
# Local, home directory setup, mutates ~/.profile
# ------------------------------------------------------------

  export NIX_BUILD_CORES=0
  export NIX_IGNORE_SYMLINK_STORE=1

# WARNING: assumes if nix.sh is present, it's set up right:
  if ! grep nix.sh $HOME/.profile; then
    cat <<EOF >> $HOME/.profile
if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
EOF
  fi
  if ! grep NIX_BUILD_CORES $HOME/.profile; then
    cat <<EOF >> $HOME/.profile
# Added by iu-parfunc lab_infrastructure install_everything.sh script:
export NIX_BUILD_CORES=0
export NIX_IGNORE_SYMLINK_STORE=1
EOF
  # export NIX_CONF_DIR=$HOME
  # export NIX_PATH="ssh-config-file=$HOME/nixpkgs/ssh/:$NIX_PATH"
  # export NIX_LINK=$HOME/.nix-profile/
  fi

# fi


# [2016.05.01] Skip this step.  For now we just use releases:
#
# Set it up with our common fork+upstream config.  To my knowledge,
# git submodules cannot directly do this:
# (cd $HOME/nixpkgs; git remote add upstream git@github.com:NixOS/nixpkgs.git || echo ok)
