{
  network.description = "Mediawiki server";

  webserver = 
    { config, pkgs, ... }:

    with pkgs.lib;

    {
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
          local mediawiki all ident map=mwusers
          local all all ident
        '';
        identMap = ''
          mwusers root   mediawiki
          mwusers wwwrun mediawiki
        '';
      };

      # Firewall
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
