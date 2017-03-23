{libraries ? {}} :

let

  uwb = (import <urweb-build>) { inherit libraries; };

in with uwb;

rec {

  fviewer = mkExe {
    name = "Fviewer";
    dbms = "sqlite";
    protocol = "fastcgi";

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

  nginx =
    let
      fcgiport="9000";

      cfg = pkgs.writeText "nginx.cfg" ''
        daemon off;
        error_log stderr debug;
        pid /tmp/nginx.pid;

        events {
          worker_connections  768;
        }

        http {

          proxy_temp_path /tmp/nginx-temp;
          client_body_temp_path /tmp/nginx-temp;
          fastcgi_temp_path /tmp/nginx-temp;
          uwsgi_temp_path /tmp/nginx-temp;
          scgi_temp_path /tmp/nginx-temp;

          server {
            error_log stderr debug;
            access_log off;
            root .;

            location / {
              include ${pkgs.nginx}/conf/fastcgi.conf;

              fastcgi_pass  127.0.0.1:${fcgiport};
              fastcgi_index index.php;
            }
          }
        }
      '';
    in
    pkgs.writeShellScriptBin "nginx-fviewer" ''
      test -f ./Fviewer.db || ${fviewer}/mkdb.sh
      ${pkgs.nginx}/bin/nginx -c ${cfg} &
      trap "kill $!" EXIT
      ${pkgs.spawn_fcgi}/bin/spawn-fcgi -p ${fcgiport} -n ${fviewer}/Fviewer.exe
    '';
}




