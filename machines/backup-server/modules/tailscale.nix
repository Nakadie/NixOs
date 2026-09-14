{
  config,
  ...
}:
{
  services.tailscale = {
    enable = true;

    authKeyFile = "/etc/tailscale-oauth";
    authKeyParameters = {
      # Persistent node (this is an installed server, not the live ISO).
      ephemeral = false;
      # Skip the one-time admin approval prompt for this offsite box.
      preauthorized = true;
    };

    extraUpFlags = [
      "--accept-dns=false"
      # Required with OAuth client secrets: devices registered via OAuth are
      # tag-owned and must advertise one of the tags assigned to the client.
      "--advertise-tags=tag:ssh"
    ];
  };

  # OAuth client secret baked into the system at /etc/tailscale-oauth. The
  # module auto-starts `tailscaled-autoconnect.service` when `authKeyFile` is
  # set. Kept out of this public repo (gitignored under /etc/nixos/secrets/).
  environment.etc."tailscale-oauth".source = /etc/nixos/secrets/tailscale-oauth;

  # Trust traffic on the tailscale interface so the node is reachable
  # over the tailnet even with the default firewall.
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];

  # tailscaled-autoconnect can run before DNS/network is up, fail the OAuth
  # token exchange, and then never retry. Order it after the network and retry
  # on failure so the node joins automatically on every boot.
  systemd.services.tailscaled-autoconnect = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };
}
