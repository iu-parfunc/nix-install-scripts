# This (partial) file is included from other files to install nix.

# ------------------------------------------------------------
# System-wide nix global setup, requires sudo
# This choses an installer to run, and runs it.
# ------------------------------------------------------------

function install_binary_distro() {
  sudo chown `whoami` /nix
  echo "Beginning the nix installer..."
  # This runs nix-store --init
  # It's pretty weak on setting up profiles though:
  # I've seen errors like this from the install script [2016.05.14]:
  #     error: opening lock file ‘/nix/var/nix/profiles/per-user/rrnewton/default.lock’: No such file or directory
  curl https://nixos.org/nix/install | sh
  echo "Completed the official nix installer.  Now for extra setup..."
}

if ! [ -d /nix ]; then
  echo "Using sudo to create /nix"
  sudo mkdir /nix
  # For the duration of this installer, we give all of nix to the current user:
  sudo chown $(whoami) /nix
fi

MY_PROF_DIR=/nix/var/nix/profiles/per-user/$(whoami)

# To work around that error in the install script, do this first:
if ! [ -d "$MY_PROF_DIR" ]; then
  mkdir -p "$MY_PROF_DIR"
fi

if ! [ -d /nix/store ]; then
  install_binary_distro
else
  echo "Because /nix/store exists, we assume the install has completed already."
fi
