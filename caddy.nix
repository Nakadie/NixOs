{ config, pkgs, ... }:
{
  services.caddy = {
    enable = false;
    # Explicitly set the ports if you are having conflicts
    # Or keep it blank if you want to fix the conflict identified by 'ss'
    # virtualHosts."copyparty.mesh.net" = {
    #   extraConfig = ''
    #     tls internal
    #     reverse_proxy 192.168.8.206:3923
    #   '';
    # };
    # virtualHosts."immich.mesh.net" = {
    #   extraConfig = ''
    #     tls internal
    #     reverse_proxy http://192.168.8.206:2283
    #   '';
    # };
    # virtualHosts."immich.mesh.net" = {
    #   extraConfig = ''
    #     tls internal
    #     reverse_proxy http://100.106.36.215:2283
    #   '';
    # };
    virtualHosts = {
      "*.mesh.net" = {
        extraConfig = ''
          tls internal

          # Matches subdomains like immich.mesh.net -> Immich backend port
          @immich host immich.mesh.net
          handle @immich {
              reverse_proxy http://127.0.0.1:2283 {
                  header_up X-Forwarded-Port {http.request.port}
                  header_up X-Forwarded-Proto {http.request.scheme}
                  # Immich requires large upload limits for mobile assets
                  transport http {
                      dial_timeout 5s
                  }
              }
          }
        '';
      };
    };
  };
}
