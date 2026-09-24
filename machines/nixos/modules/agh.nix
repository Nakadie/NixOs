{ config, pkgs, ... }:

{
  services.adguardhome = {
    # Not ready to use yet — disabled for now.
    enable = false;
    host = "0.0.0.0";
    port = 3000; # Management interface port
    mutableSettings = true;
    settings = {
      dns = {
        bind_hosts = [
          "0.0.0.0"
          "127.0.0.1"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    53
    3000
    88
  ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
