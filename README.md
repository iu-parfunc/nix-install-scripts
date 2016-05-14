

A bunch of scripts for installing Nix
=====================================

Various people around the web have rolled their own scripts for
installing nix, and especially for configuring it in multi-user mode
when running it on top of another distro.

This is our attempt.  It is probably not very portable or future
proof.  However, as a sanity check, the included Dockerfile does make
sure that a given release of nix builds in a clean (ubuntu)
environment.

Other related work
------------------

There's also some efforts to build Docker images from nix.

This one, for instance, seems to use the nix binary installer on top
of Debian:

 * https://github.com/datakurre/nix-build-pack-docker

