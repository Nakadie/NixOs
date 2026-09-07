{
  config,
  ...
}:
{
  services.tailscale = {
    enable = true;

    # OAuth client secret baked into the ISO at /etc/tailscale-oauth.
    # The module auto-starts `tailscaled-autoconnect.service` when this is set.
    authKeyFile = "/etc/tailscale-oauth";
    authKeyParameters = {
      # Ephemeral node: registers with `?ephemeral=true`, keyed to the OAuth client's tags.
      ephemeral = true;
    };

    extraUpFlags = [
      "--ssh"
      "--accept-dns=false"
      # Required with OAuth client secrets: devices registered via OAuth are
      # tag-owned and must advertise one of the tags assigned to the client.
      "--advertise-tags=tag:ssh"
    ];
  };

  # Trust traffic on the tailscale interface so the node is reachable
  # even with the ISO's default firewall.
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
