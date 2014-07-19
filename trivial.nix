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

      # Firewall
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
