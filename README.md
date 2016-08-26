Urweb-Fviewer
-------------

This repository contains project demonstrating usage of technologies involved in
complex Ur/Web application development:

* Ur/Web compiler [Ur/Web](http://impredicative.com/ur/)
* Git submodules containing Ur/Web libraries including uru3, xmlw and others.
* File `build.nix` containing build rules to be evaluated with
  [urweb-build](https://github.com/grwlf/urweb-build) base expression and
  [nix-build](http://nixos.org/nix/) interpreter

Install
-------

0. Install [Nix](http://nixos.org/nix/) package manager
1. Clone [urweb-build](https://github.com/grwlf/urweb-build) base expression,
   setup the NIX\_PATH environment variable
2. Clone the Fviewer repository with submodules
3. Run `nix-build build.nix`

