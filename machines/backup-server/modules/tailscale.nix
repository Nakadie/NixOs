{
  config,
  ...
}:
{
  services.tailscale = {
    enable = true;

    # OAuth client secret provisioned on the host at /etc/tailscale-oauth.
    # The module auto-starts `tailscaled-autoconnect.service` when this is set.
    # The secret file itself stays out of this public repo (gitignored under
    # /etc/nixos/secrets/); the minimal live image bakes it into the ISO.
    authKeyFile = "/etc/tailscale-oauth";

    extraUpFlags = [
      "--ssh"
      "--accept-dns=false"
      # Required with OAuth client secrets: devices registered via OAuth are
      # tag-owned and must advertise one of the tags assigned to the client.
      "--advertise-tags=tag:ssh"
    ];
  };

  # Trust traffic on the tailscale interface so the node is reachable
  # over the tailnet even with the default firewall.
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
