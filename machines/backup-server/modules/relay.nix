{
  config,
  pkgs,
  ...
}:
let
  # hpserver's Tailscale address lives in a gitignored file (this repo is
  # public). Keys: parentLan/parentTs (hpserver), childTs (this box).
  netdataIps = import /etc/nixos/secrets/netdata-ips.nix;
  hpserver = netdataIps.parentTs;

  listenPort = 8080;
  # The hpserver service this relay forwards to, over the tailnet. Change this
  # to whichever port/API you need (Immich 2283, Jellyfin 8096, Romm 8080...).
  targetPort = 2283;
in
{
  # LAN ingress: the phone calls http://<backup-server-lan-ip>:8080/... and
  # socat tunnels the TCP stream to hpserver's service port over Tailscale.
  # Plain TCP: no TLS, no Host/routing — point it at one service per listener.
  systemd.services.tailscale-relay = {
    description = "Forward TCP :${toString listenPort} to hpserver over Tailscale";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString listenPort},fork,reuseaddr TCP:${hpserver}:${toString targetPort}";
      Restart = "always";
      RestartSec = "3s";
      DynamicUser = true;
    };
  };

  # Open the relay on the LAN. The tailscale interface is already trusted, and
  # 8080 is only meant for same-LAN callers — restrict it further if this box
  # is ever directly internet-facing.
  networking.firewall.allowedTCPPorts = [ listenPort ];
}
