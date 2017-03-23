Urweb-Fviewer
-------------

This repository contains project demonstrating usage of technologies involved in
complex Ur/Web application development:

* Ur/Web compiler [Ur/Web](http://impredicative.com/ur/)
* Git submodules containing Ur/Web libraries including uru3, xmlw and others.
* File `default.nix` containing build rules to be evaluated together with
  [urweb-build](https://github.com/grwlf/urweb-build) base expression by the
  [nix-build](http://nixos.org/nix/) interpreter

Install
-------

0. Install [Nix](http://nixos.org/nix/) package manager
1. Clone [urweb-build](https://github.com/grwlf/urweb-build) base expression,
   setup the NIX\_PATH environment variable
2. Clone the Fviewer repository with submodules
3. Run `nix-build -A nginx`. Symlink named `result` will be created.
4. Run `./result/bin/nginx-fviewer` and navigate http://127.0.0.1:8000/Fviewer/main to view the start page
   Note, the sqlite database `./Fviewer.db` will be created if not exists.

