
# Set up Nix for a new user on a system where multi-user nix is
# already installed and working correctly.
# =============================================================


# RRN: Doing this unconditionally is causing some problems for me atm [2014.12.30].
# Putting it under a function for now:
#touch /tmp/hello_world
function go_nix () {
  export NIX_USER_PROFILE_DIR=/nix/var/nix/profiles/per-user/$USER

  mkdir -m 0755 -p $NIX_USER_PROFILE_DIR
  if test "$(stat --printf '%u' $NIX_USER_PROFILE_DIR)" != "$(id -u)"; then
      echo "WARNING: bad ownership on $NIX_USER_PROFILE_DIR" >&2
  fi

  if ! test -L $HOME/.nix-profile; then
      echo "creating $HOME/.nix-profile" >&2
      if test "$USER" != root; then
          ln -s $NIX_USER_PROFILE_DIR/default $HOME/.nix-profile
      else
          # Root installs in the system-wide profile by default.
          ln -s /nix/var/nix/profiles/default $HOME/.nix-profile
      fi
  fi

  export NIX_PROFILES="/nix/var/nix/profiles/default $HOME/.nix-profile"
  export MANPATH=/nix/var/nix/profiles/default/share/man:$MANPATH

  for i in $NIX_PROFILES; do
      export PATH=$i/bin:$PATH
  done


  if [ "$USER" = root -a ! -e $HOME/.nix-channels ]; then
      echo "http://nixos.org/channels/nixpkgs-unstable nixpkgs" \
        > $HOME/.nix-channels
  fi

  #if [ "$USER" != root -a ! -e $HOME/.nix-channels ]; then
  #    nix-channel --add http://nixos.org/channels/nixpkgs-unstable
  #    nix-channel --update
  #fi

  #We have to create a garbage collector root folder for the user, if it does not exists:

  NIX_USER_GCROOTS_DIR=/nix/var/nix/gcroots/per-user/$USER
  mkdir -m 0755 -p $NIX_USER_GCROOTS_DIR
  if test "$(stat --printf '%u' $NIX_USER_GCROOTS_DIR)" != "$(id -u)"; then
      echo "WARNING: bad ownership on $NIX_USER_GCROOTS_DIR" >&2
  fi

# nix-defexpr
# ------------------------------------------------------------
#We must also set the default Nix expression, so that we can conveniently
# install packages from Nix channels:
  
# RRN: Actually, I don't think we need this part [2016.05.19]:
  if [ ! -e $HOME/.nix-defexpr -o -L $HOME/.nix-defexpr ]; then
      echo "creating $HOME/.nix-defexpr" >&2
      rm -f $HOME/.nix-defexpr
      mkdir $HOME/.nix-defexpr
      #nix-env --switch-profile /nix/var/nix/profiles/per-user/$USER/default
      if [ "$USER" != root ]; then
          ln -s /nix/var/nix/profiles/per-user/$USER/channels \
            $HOME/.nix-defexpr/channels
      fi
  fi

  export NIX_PATH=${NIX_PATH:+$NIX_PATH:}nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs


  if [ ! -e $HOME/.nix-defexpr/channels/nixpkgs ]; then
      nix-channel --add https://nixos.org/channels/nixpkgs-unstable
      nix-channel --update
  fi

  #Unprivileged users do not have the rights to build package directly, 
  #since they cannot be trusted. Instead the daemon must do that on behalf 
  #of the user. The following shell code fragment ensures that:
  if test "$USER" != root; then
      export NIX_REMOTE=daemon
  else
      export NIX_REMOTE=
  fi

# SSL_CERT_FILE
# ------------------------------------------------------------
# This is copied from the standard `nix.sh` script that ships with
# nix.  This script subsumes that one, so we have no need of depending
# on it.
  
    # Append ~/.nix-defexpr/channels/nixpkgs to $NIX_PATH so that
  # <nixpkgs> paths work when the user has fetched the Nixpkgs
  # channel.
  export NIX_PATH=${NIX_PATH:+$NIX_PATH:}nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs

  # Set $SSL_CERT_FILE so that Nixpkgs applications like curl work.
  if [ -e /etc/ssl/certs/ca-certificates.crt ]; then # NixOS, Ubuntu, Debian, Gentoo, Arch
      export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
  elif [ -e /etc/ssl/certs/ca-bundle.crt ]; then # Old NixOS
      export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
  elif [ -e /etc/pki/tls/certs/ca-bundle.crt ]; then # Fedora, CentOS
      export SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
  elif [ -e "$NIX_LINK/etc/ssl/certs/ca-bundle.crt" ]; then # fall back to cacert in Nix profile
      export SSL_CERT_FILE="$NIX_LINK/etc/ssl/certs/ca-bundle.crt"
  elif [ -e "$NIX_LINK/etc/ca-bundle.crt" ]; then # old cacert in Nix profile
      export SSL_CERT_FILE="$NIX_LINK/etc/ca-bundle.crt"
  fi

}
