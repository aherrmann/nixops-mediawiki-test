{
  network.description = "Web server";

  webserver = 
    { config, pkgs, ... }:
    {
      # Webserver
      services.httpd = {
        enable = true;
        adminAddr = "andreash87@gmx.ch";
        documentRoot = "/www";
        extraSubservices =
          [ { serviceType = "mediawiki";
              siteName = "My Wiki";
              extraConfig = ''
                $wgEmailConfirmToEdit = false;
              '';
            }
          ];
      };

      # Database
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql93;
        authentication = pkgs.lib.mkOverride 10 ''
          local mediawiki all ident map=mwusers
          local all all ident
        '';
        identMap = ''
          mwusers root mediawiki
          mwusers wwwrun mediawiki
        '';
      };

      # Firewall
      networking.firewall.allowedTCPPorts = [ 80 ];
    };
}
