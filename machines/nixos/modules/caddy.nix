{ config, pkgs, ... }:
let
  simpleProxy = port: ''
    tls internal
    reverse_proxy http://127.0.0.1:${toString port}
  '';
in
{
  services.caddy = {
    # Not ready to use yet — disabled for now. When ready: swap tls internal
    # for real certs (deSEC DNS-01) and add Tailscale split DNS for the names.
    enable = false;
    virtualHosts = {
      "immich.mesh.net" = {
        extraConfig = ''
          tls internal
          reverse_proxy http://127.0.0.1:2283 {
            header_up X-Forwarded-Port {http.request.port}
            header_up X-Forwarded-Proto {http.request.scheme}
            transport http {
              dial_timeout 5s
            }
          }
        '';
      };
      "copyparty.mesh.net".extraConfig = ''
        tls internal
        reverse_proxy http://192.168.8.206:3923
      '';
      "jellyfin.mesh.net".extraConfig = simpleProxy 8096;
      "romm.mesh.net".extraConfig = simpleProxy 8181;
      "komga.mesh.net".extraConfig = simpleProxy 25600;
      "homepage.mesh.net".extraConfig = simpleProxy 3001;
      "beszel.mesh.net".extraConfig = simpleProxy 8090;
      "speedtest.mesh.net".extraConfig = simpleProxy 8081;
    };
  };

  # Only needed while services.caddy is enabled.
  # networking.firewall.allowedTCPPorts = [
  #   80
  #   443
  # ];
}
