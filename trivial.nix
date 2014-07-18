{
  network.description = "Mediawiki server";

  webserver = 
    { config, pkgs, ... }:

    with pkgs.lib;

    let

      # Unpack Mediawiki and put the config file in its root directory.
      mediawikiRoot = pkgs.stdenv.mkDerivation rec {
        name = "mediawiki-1.15.5";

        src = pkgs.fetchurl {
          url = "http://download.wikimedia.org/mediawiki/1.15/${name}.tar.gz";
          sha256 = "1d8afbdh3lsg54b69mnh6a47psb3lg978xpp277qs08yz15cjf7q";
        };

        buildPhase = "true";

        installPhase =
          ''
            mkdir -p $out
            cp -r * $out
          '';
      };

    in

    {
      # Packages
      environment.systemPackages = [ pkgs.postgresql ];

      # Webserver
      services.httpd = {
        enable = true;
        adminAddr = "andreash87@gmx.ch";
        extraSubservices = singleton
          { serviceType = "mediawiki";
            siteName = "Example Wiki";
          };
      };

      # Database
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql;
        authentication = ''
          local all root ident
          local mediawiki mediawiki ident map=mediawiki-map
        '';
        identMap = ''
          mediawiki-map root   mediawiki
          mediawiki-map wwwrun mediawiki
        '';
      };

      # Setup scripts
      jobs.init_mediawiki_db = {
        task = true;
        startOn = "started postgresql";
        script = ''
          mkdir -p /var/lib/psql-schemas
          if ! [ -e /var/lib/psql-schemas/mediawiki-created ]; then
            ${pkgs.postgresql}/bin/createuser --no-superuser --no-createdb --no-createrole mediawiki
            ${pkgs.postgresql}/bin/createdb mediawiki -O mediawiki
            ( echo 'CREATE LANGUAGE plpgsql;'
              cat ${mediawikiRoot}/maintenance/postgres/tables.sql
              echo 'CREATE TEXT SEARCH CONFIGURATION public.default ( COPY = pg_catalog.english );'
              echo COMMIT
            ) | ${pkgs.postgresql}/bin/psql -U mediawiki mediawiki
            touch /var/lib/psql-schemas/mediawiki-created
          fi
        '';
      };

      # Firewall
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
