
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
        ln -s $NIX_USER_PROFILE_DIR/profile $HOME/.nix-profile
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

#We must also set the default Nix expression, so that we can conveniently
# install packages from Nix channels:


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
#Unprivileged users do not have the rights to build package directly, 
#since they cannot be trusted. Instead the daemon must do that on behalf 
#of the user. The following shell code fragment ensures that:

if test "$USER" != root; then
    export NIX_REMOTE=daemon
else
    export NIX_REMOTE=
fi

if [ ! -e $HOME/.nix-defexpr/channels/nixpkgs ]; then
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable
    nix-channel --update
fi
}
