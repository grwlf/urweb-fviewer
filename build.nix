{libraries ? {}} :

let

  uwb = (import <urweb-build>) { inherit libraries; };

in with uwb;

rec {

  oilprice = mkExe {
    name = "Fviewer";
    dbms = "sqlite";

    libraries = {
      xmlw = external ./lib/urweb-xmlw;
      soup = external ./lib/urweb-soup;
      prelude = external ./lib/urweb-prelude;
      bootstrap = external ./lib/uru3/Bootstrap;
      uru = external ./lib/uru3/Uru;
      bootstrap-misc = external ./lib/uru3/BootstrapMisc;
      monad-pack = external ./lib/urweb-monad-pack;
    };

    statements = [
      (set "allow mime text/javascript")
      (set "allow mime text/css")
      (set "allow mime image/jpeg")
      (set "allow mime image/png")
      (set "allow mime image/gif")
      (set "allow mime application/octet-stream")
      (set "allow url https://github.com/grwlf/urweb-fviewer*")

      (sys "list")
      (sys "char")
      (sys "string")
      (sys "option")
      (src ./Fviewer.ur ./Fviewer.urs)
    ];
  };

}




