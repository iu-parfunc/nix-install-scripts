

Scripts for installing Nix
==========================

Various people around the web have rolled their own scripts for
installing nix that go beyond the limitations of the recommended
install script (`curl https://nixos.org/nix/install | sh`).  For
example, there's a need for scripts to install nix in multi-user mode
when running it on top of another distro.

This is our attempt.  It is probably not very portable or future
proof.  However, as a sanity check, the included Dockerfile does make
sure that a given release of nix builds in a clean environment.


Related work
------------

Here are some install scripts and/or instructions:

 * https://gist.github.com/joepie91/043a51a7b70be5f50f1d
 * https://gist.github.com/shajra/12d862220ab7cb9782d2a934d4cb489a
 * https://gist.github.com/zefhemel/7300869
 
There are also some efforts to build Docker images from nix.

This one, for instance, seems to use the nix binary installer on top
of Debian:

 * https://github.com/datakurre/nix-build-pack-docker

